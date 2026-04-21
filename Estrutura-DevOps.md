# Estrutura DevOps Senior — Ambiente Corporativo do Zero

## Comparação da Construção deste projeto em um ambiente Corporativo
Antes de escrever qualquer linha de código, um DevOps Senior pensa em três pilares:

1. **Separação de responsabilidades** — cada coisa no seu lugar, cada pipeline com um propósito
2. **Segurança por padrão** — nunca como afterthought
3. **Rastreabilidade** — qualquer pessoa do time consegue entender o que foi feito, quando e por quê

---

## Fase 0 — Antes de criar qualquer recurso

Em um ambiente corporativo real, antes de abrir o terminal, existe:

### Definição de contas AWS (Multi-Account Strategy)

```
AWS Organization
├── Management Account     → billing, SCPs, nada roda aqui
├── Security Account       → GuardDuty, Security Hub, logs centralizados
├── Shared Services Account → ECR, Route53, Certificate Manager
└── Workload Accounts
    ├── dev                → ambiente de desenvolvimento
    ├── staging            → homologação
    └── prod               → produção
```

> No seu laboratório você usa uma conta única — o que é correto para estudo.
> Em produção corporativa, workloads nunca rodam na mesma conta que o billing.

### Definição de repositórios (separação por domínio)

Em vez de um único repositório com tudo, o padrão corporativo é:

```
github.com/empresa/
├── infra-platform/        → Terraform base: VPC, EKS, RDS, IAM
├── infra-apps/            → Helm charts de todas as aplicações
├── service-back-java/     → APENAS o código do backend Java
├── service-front-py/      → APENAS o código do frontend Python
├── service-go/            → APENAS o código do microsserviço Go
└── gitops-config/         → ArgoCD ApplicationSets, valores por ambiente
```

**Por quê separado?** Porque times diferentes têm permissões diferentes:
- Time de plataforma → acessa `infra-platform`
- Time de dev → acessa apenas o repositório do seu serviço
- Ninguém acessa `gitops-config` diretamente — só o ArgoCD

> No seu projeto, você optou por um monorepo (tudo em `ppeks/`), que é válido
> para laboratório e times pequenos. Muitas empresas também usam monorepo
> (Google, Meta) — o importante é a separação interna de pastas e pipelines.

---

## Fase 1 — Fundação de Segurança (IAM / OIDC)

### O que você já tem (correto ✅)
```
role/github-carina-devops-pipe → assume via OIDC (sem chaves de acesso)
```

### Como seria corporativo

```hcl
# Múltiplas roles com mínimo privilégio
iam/
├── role-github-infra.tf      → só pode criar/destruir infra (EKS, RDS, VPC)
├── role-github-deploy.tf     → só pode fazer kubectl apply e helm upgrade
├── role-github-ecr.tf        → só pode fazer push no ECR
└── role-github-readonly.tf   → só leitura, para pipelines de validação
```

**Princípio do menor privilégio:**

| Pipeline | Role | Permissões |
|---|---|---|
| `1_img_*.yaml` (build) | `role-github-ecr` | ECR push apenas |
| `3_infra_eks.yaml` | `role-github-infra` | EKS, VPC, IAM |
| `5_deploy_*.yaml` | `role-github-deploy` | EKS describe/apply, SSM read |
| Leitura de outputs | `role-github-readonly` | S3 read (tfstate) |

> No seu projeto, uma única role faz tudo. Funciona, mas em produção
> corporativa o comprometimento de uma pipeline não deve comprometer toda a infra.

### Branch Protection (obrigatório em produção)

```yaml
# Configuração no GitHub (Settings → Branches)
main:
  required_pull_request_reviews:
    required_approving_review_count: 2
  required_status_checks:
    - terraform-validate
    - security-scan
  enforce_admins: true
  restrictions:
    push: []          # ninguém faz push direto na main
```

---

## Fase 2 — Estrutura de Repositório Corporativo

### Como seria o seu `ppeks/` em padrão corporativo

```
infra-platform/                    ← repositório separado de infra
├── .github/
│   └── workflows/
│       ├── 1_plan.yaml            ← apenas terraform plan (em PRs)
│       ├── 2_apply_eks.yaml       ← apply do EKS (merge na main)
│       ├── 3_apply_rds.yaml       ← apply do RDS
│       └── 4_apply_lambda.yaml    ← apply do Lambda
│
├── environments/
│   ├── dev/
│   │   ├── eks.tfvars
│   │   └── rds.tfvars
│   └── prod/
│       ├── eks.tfvars
│       └── rds.tfvars
│
├── modules/
│   ├── network/                   ← igual ao seu ✅
│   ├── cluster/                   ← igual ao seu ✅
│   ├── managed-node-group/        ← igual ao seu ✅
│   ├── alb-controller/            ← igual ao seu ✅
│   ├── rds/                       ← transformar pasta rds/ em módulo
│   └── lambda/                    ← novo módulo
│
└── stacks/
    ├── eks/
    │   ├── main.tf                ← chama módulos
    │   ├── providers.tf
    │   └── backend.tf             ← tfstate no S3 + DynamoDB lock
    └── rds/
        ├── main.tf
        └── backend.tf
```

### O detalhe crítico: DynamoDB para lock do tfstate

```hcl
# backend.tf — padrão corporativo
terraform {
  backend "s3" {
    bucket         = "tfstate-ppeks"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true          # ← criptografia obrigatória
    dynamodb_table = "tfstate-lock" # ← evita apply simultâneo (race condition)
  }
}
```

> Sem o DynamoDB lock, duas pipelines rodando ao mesmo tempo podem corromper
> o tfstate. Em produção isso é crítico.

---

## Fase 3 — Pipeline Corporativa (GitFlow)

### Fluxo de uma mudança em produção

```
developer → feature branch
    ↓
    PR aberto → pipeline roda:
        ✅ terraform validate
        ✅ terraform plan (output no PR como comentário)
        ✅ tfsec / checkov (security scan)
        ✅ tflint (linting)
    ↓
    Code review (2 aprovações)
    ↓
    Merge na main → pipeline roda:
        ✅ terraform apply (ambiente dev)
    ↓
    Tag de release → pipeline roda:
        ✅ terraform apply (ambiente prod)
```

### Como seria o `3_infra_eks.yaml` corporativo

```yaml
name: "EKS Infrastructure"

on:
  pull_request:
    paths: ['stacks/eks/**', 'modules/**']
  push:
    branches: [main]
    paths: ['stacks/eks/**', 'modules/**']

jobs:
  validate:
    name: Validate & Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.8.3

      - name: Configure AWS credentials (readonly)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: "arn:aws:iam::749000351410:role/github-readonly"
          aws-region: "us-east-1"

      - name: Terraform Init
        run: cd stacks/eks && terraform init

      - name: Terraform Validate
        run: cd stacks/eks && terraform validate

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

      - name: Security Scan (tfsec)
        uses: aquasecurity/tfsec-action@v1.0.0

      - name: Terraform Plan
        id: plan
        run: cd stacks/eks && terraform plan -out=plan.tfplan -no-color
        continue-on-error: true

      - name: Post Plan no PR
        uses: actions/github-script@v7
        with:
          script: |
            const output = `#### Terraform Plan 📖
            \`\`\`${{ steps.plan.outputs.stdout }}\`\`\``;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            });

  apply:
    name: Terraform Apply
    needs: validate
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: production    # ← requer aprovação manual no GitHub
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials (infra role)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: "arn:aws:iam::749000351410:role/github-infra"
          aws-region: "us-east-1"

      - name: Terraform Apply
        run: cd stacks/eks && terraform apply -auto-approve
```

---

## Fase 4 — GitOps com ArgoCD (padrão corporativo)

### O fluxo que você já usa é o correto ✅

```
developer faz push do código
    ↓
pipeline de imagem (1_img_*.yaml):
    - build da imagem
    - push no ECR
    - atualiza tag no values.yaml   ← você já faz isso!
    - commit com [skip ci]          ← você já faz isso!
    ↓
ArgoCD detecta mudança no values.yaml
    ↓
ArgoCD aplica automaticamente no EKS
```

### ApplicationSet corporativo (múltiplos ambientes)

```yaml
# gitops-config/applicationset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: ppeks-services
  namespace: argocd
spec:
  generators:
    - matrix:
        generators:
          - list:
              elements:
                - service: service1_back_java
                - service: service2_front_py
                - service: service3_go
          - list:
              elements:
                - env: dev
                  namespace: ppeks-dev
                - env: prod
                  namespace: ppeks-prod
  template:
    metadata:
      name: "{{service}}-{{env}}"
    spec:
      project: ppeks
      source:
        repoURL: https://github.com/carina-pereira-devops/ppeks
        targetRevision: HEAD
        path: "charts/{{service}}"
        helm:
          valueFiles:
            - "values.yaml"
            - "values-{{env}}.yaml"   # valores por ambiente
      destination:
        server: https://kubernetes.default.svc
        namespace: "{{namespace}}"
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

---

## Fase 5 — Segurança em Camadas (Defense in Depth)

### Camadas que um ambiente corporativo implementa

```
Camada 1 — AWS Organizations / SCPs
    └── Impede recursos em regiões não autorizadas
    └── Impede desabilitar CloudTrail

Camada 2 — IAM (você já tem ✅)
    └── OIDC sem chaves de acesso estáticas
    └── Roles com mínimo privilégio

Camada 3 — Rede
    └── VPC com subnets privadas (você já tem ✅)
    └── Security Groups restritivos (você já tem ✅)
    └── RDS em subnet privada, sem acesso público
    └── EKS nodes em subnets privadas (você já tem ✅)

Camada 4 — Kubernetes (RBAC)
    └── Namespaces por equipe/ambiente
    └── NetworkPolicies (quem pode falar com quem)
    └── Pod Security Standards (non-root, read-only filesystem)
    └── Secrets via External Secrets Operator (SSM → K8s Secret)

Camada 5 — Imagens
    └── ECR Image Scanning habilitado
    └── Imagens base não-root
    └── Distroless ou Alpine (superfície mínima)

Camada 6 — Runtime
    └── Falco (detecção de comportamento anômalo)
    └── OPA/Kyverno (políticas de admission)

Camada 7 — Auditoria
    └── CloudTrail em todas as regiões
    └── AWS Config (drift detection)
    └── GuardDuty (threat detection)
```

---

## Comparativo: Seu Projeto Atual vs. Corporativo

| Prática | Seu projeto atual | Corporativo | Prioridade |
|---|---|---|---|
| OIDC sem chaves estáticas | ✅ | ✅ | Crítico |
| Tfstate no S3 | ✅ | ✅ | Crítico |
| DynamoDB lock no tfstate | ❌ | ✅ | Alta |
| Terraform modules | ✅ | ✅ | Alta |
| destroy_config.json | ✅ criativo | ❌ usa environments | Média |
| Branch protection + PR | ❌ | ✅ | Alta |
| Terraform plan no PR | ❌ | ✅ | Alta |
| Security scan (tfsec) | ❌ | ✅ | Alta |
| Múltiplas roles IAM | ❌ (1 role faz tudo) | ✅ | Média |
| GitOps com ArgoCD | ✅ (planejado) | ✅ | Alta |
| Values por ambiente | ❌ | ✅ | Média |
| ECR Image Scanning | ❌ | ✅ | Média |
| NetworkPolicies K8s | ❌ | ✅ | Média |
| External Secrets Operator | ❌ (usa SSM direto) | ✅ | Média |
| Multi-account AWS | ❌ | ✅ | Baixa (lab) |

---

## Roadmap sugerido para o seu laboratório

### Agora (V1) — o que você está fazendo
- ✅ EKS funcionando
- ✅ RDS funcionando
- ✅ ALB Controller
- 🔄 Deploy dos microsserviços (Java, Python, Go)
- 🔄 OTel Collector + Prometheus

### Próximo passo (V2) — boas práticas de pipeline
- Adicionar `dynamodb_table` no backend do tfstate
- Adicionar `terraform plan` como comentário nos PRs
- Adicionar `tfsec` nas pipelines de infra
- Branch protection na `main`

### Depois (V3) — GitOps maduro
- ArgoCD com ApplicationSet por ambiente
- `values-dev.yaml` e `values-prod.yaml` separados
- External Secrets Operator (SSM → K8s Secret automático)

### Avançado (V4) — segurança em runtime
- Kyverno para políticas de admission
- Falco para detecção de ameaças
- ECR scan obrigatório antes do deploy

---

## Conclusão

Seu projeto já segue práticas que muitas empresas não seguem:
- OIDC ao invés de chaves de acesso estáticas
- Terraform modular
- Separação clara entre infra e deploy
- GitOps com ArgoCD como fonte de verdade

As gaps principais para chegar no padrão corporativo são:
1. **DynamoDB lock** no tfstate (simples de adicionar)
2. **PR com terraform plan automático** (muda a cultura de trabalho)
3. **Roles IAM separadas** por responsabilidade
4. **Branch protection** na main

Estas melhorias transformam o laboratório em um portfólio que impressiona em entrevistas de DevOps Senior. 🚀
