![OPS](prints/image1.png)

# Documentação está em construção, e as informações ainda não estão na ordem correta, nem com as devidas evidências!

---

# Uso recomendado de Inteligência Artificial

A IA não substitui treinamentos e conhecimentos prévios acadêmicos das tecnologias envolvidas neste laboratório, apenas auxilia com dúvidas pontuais, ou sugere melhorias.

Seja na edição de prompts, ou nas respostas da IA, ter este conhecimento prévio, acelera o resultado esperado.

No uso de IA se faz imprescindível um desenho prévio de toda a arquitetura, bem como as etapas, pois a falta deste planejamento, gera prompts desnecessários, com saídas desnecessárias, poluindo todo o histórico de mensagens, resultando em perca de tempo nas buscas pos informações úteis.

Uma documentação bem feita (a exemplo do Projeto_Anterior.md, disponível no diretório raiz deste repositório), também traz insumos para análise de IA, o que foi disruptivo para a evolução do projeto. Por padrão IAs fazem a leitura de Readme, então tenha sempre em mente a importância de boas documentações.

---

# Premissas

Criar um bucket S3 na AWS, com nome "tfstate-ppeks" antes de executar as pipelines do Github Actions. Caso deseje um bucket S3 com outro nome, necessário alterar nas configurações.

Alimentar valores manualmente após a criação do EKS:

```
vpc_id         = "vpc-0e424344843d73a95"
private_subnets = [
  "subnet-015a1736387966dfb",
  "subnet-0da9e8b2ee04052eb"
]
project_name   = "ppeks"
```

---

# Acesso a AWS

Certifique-se que o usuário que acessa a console (1), seja o mesmo usuário com acesso via awscli (2), e o mesmo usuário ao qual serão concedidas as permissões de visualização (3):

![USER](prints/image3.png)

1 - Lembrando que ao logar com o usuário root da conta, o que geralmente é o comum, não será possível visualizar, Pods, Services, etc... (isso pode causar confusão).

2 - Acesso via awscli, será com esse mesmo usuário que executaremos os comandos via Kubectl:
```
[carina@fedora pp_eks]$ aws sts get-caller-identity
{
...
"Arn": "arn:aws:iam::749000351410:user/devops"
}

```

3 - Permissões atribuídas via IAM (código Terraform), ao mesmo usuário:

![IAM](prints/image4.png)

---

# Laboratório OTEL

Este laboratório evoluiu de acordo com uma experiência anterior, descrita no arquivo Projeto_Anterior.md.

A proposta atual é adaptar para a Cloud AWS o laboratório do treinamento:

https://github.com/lftraining/LFS148-code

Como no print abaixo, os containers (Docker na estrutura do curso), serão orquestrados em um EKS na AWS, sendo a infra construida com o GitHub Actions/Terraform, o deploy das aplicações gerenciados via Helm, sendo o Github a única fonte de verdade para o ArgoCD.

![OTEL](prints/image.png)

Obs.: Como já temos um front em Python, não utilizaremos o microsserviço Todoui-thymeleaf.

OpentelemetryDemo:

https://opentelemetry.io/ecosystem/demo/

A construção será feita de forma didática e intuitiva, bem detalhada através desta documentação.

# Topologia da AWS

No laboratório anterior, foi sugerido o uso do Traefik, no qual este deploy do Kubernetes faria a gerencia das rotas (conceitos de CKA). Como queremos explorar mais os recursos da AWS (atualmente estudando para AWS Certified Solutions Architect Associate), para este Laboratório vamos utilizar o AWS ALB Ingress Controller, expondo aplicações.

De fato o deploy é feito pelo Helm, que é um gerenciador de pacotes do Kubernetes, mas ele fará a criação e gerencia do ALB, que por sua vez é um recurso da AWS. Aliás, qualquer serviço exposto em um EKS, sem "annotations" específicos, pode criar um ELB (geralmente é criado um "Clássico", com poucos recursos), mas a diferença é que para os próximos deployments, vamos usar os "annotations", para que estes utilizem o ALB previamente criado, e não crie outro ALB.

Também no laboratório anterior, no destroy da infra, a pipeline quebrava por conta que o ALB estava com aplicações criadas no EKS, o que não permitia a destruição do cluster. Então com a instalação/desinstalação do ALB Ingress Controller via pipeline do GitHub Actions, a infra fica totalmente apartada do deploy permitindo flexibilidade.

Também temos granularidade em qualquer alteração da pasta "iac_eks" podendo ser executada através de uma pipeline específica para a infra.

# Cluster EKS

Validação e configurações iniciais:

```
aws eks update-kubeconfig --region us-east-1 --name ppeks-cluster
Updated context arn:aws:eks:us-east-1:749000351410:cluster/ppeks-cluster in /home/carina/.kube/config

kubectl config use-context  arn:aws:eks:us-east-1:749000351410:cluster/ppeks-cluster
Switched to context "arn:aws:eks:us-east-1:749000351410:cluster/ppeks-cluster".
```

# MGN/Karpenter

Validações:
kubectl get ec2nodeclasses
kubectl get nodepools

Nodes que vão receber apenas pods do kube-proxy, aws-node, coredns, karpenter:

![NODES](prints/image9.png)

![EFFECT](prints/image8.png)

Visão micro:

![MGN](prints/image10.png)

```
1. Você faz deploy da sua app (helm install java-back)
        ↓
2. Pod fica em Pending — nenhum node disponível
        ↓
3. Karpenter detecta o pod Pending em segundos
        ↓
4. Lê o NodePool — quais instâncias spot são permitidas?
        ↓
5. Chama a API da AWS e provisiona uma EC2 spot
        ↓
6. Node entra no cluster (~60-90 segundos)
        ↓
7. Pod é agendado no novo node → Running ✅
        ↓
8. App fica ociosa por tempo configurado (ex: 30 min)
        ↓
9. Karpenter remove o node automaticamente → $ economizado
```

# Features

1 - Instalação manual via kubectl, do deploy de métricas, para coleta de informações de CPU e Memória de Nodes e Pods:

```
[carina@fedora pp_eks]$ k apply -f ./features/metrics.yaml
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
``` 

Obs.: Em um primeiro deploy com apenas dois nodes no cluster, não haviam CPU e Memória suficientes para a implementação do recurso (considerando com o deploy do ALB Controller):

```
[carina@fedora pp_eks]$ k -n kube-system get deploy
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           22m
coredns                        2/2     2            2           24m
metrics-server                 0/1     1            0           10m

[carina@fedora pp_eks]$ k -n kube-system describe po metrics-server-df8589546-gr5gp
...
Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  3m34s  default-scheduler  0/2 nodes are available: 2 Too many pods. no new claims to deallocate, preemption: 0/2 nodes are available: 2 No preemption victims found for incoming pod.
```

Após a adição de mais um node:

```
[carina@fedora pp_eks]$ k get no
NAME                         STATUS   ROLES    AGE   VERSION
ip-10-0-3-155.ec2.internal   Ready    <none>   21m   v1.34.2-eks-ecaa3a6
ip-10-0-4-171.ec2.internal   Ready    <none>   36s   v1.34.2-eks-ecaa3a6
ip-10-0-4-213.ec2.internal   Ready    <none>   21m   v1.34.2-eks-ecaa3a6

[carina@fedora pp_eks]$ k -n kube-system get deploy
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           26m
coredns                        2/2     2            2           28m
metrics-server                 1/1     1            1           14m

[carina@fedora pp_eks]$ k get po -A
NAMESPACE     NAME                                            READY   STATUS    RESTARTS   AGE
kube-system   aws-load-balancer-controller-68bc9587b7-2zbn4   1/1     Running   0          23m
kube-system   aws-load-balancer-controller-68bc9587b7-tsxnd   1/1     Running   0          23m
kube-system   aws-node-2w92l                                  2/2     Running   0          22m
kube-system   aws-node-8dxv2                                  2/2     Running   0          83s
kube-system   aws-node-dlkdq                                  2/2     Running   0          22m
kube-system   coredns-7d58d485c9-29ds5                        1/1     Running   0          25m
kube-system   coredns-7d58d485c9-rqn5l                        1/1     Running   0          25m
kube-system   kube-proxy-7qkdd                                1/1     Running   0          22m
kube-system   kube-proxy-c56sg                                1/1     Running   0          83s
kube-system   kube-proxy-hhhgw                                1/1     Running   0          22m
kube-system   metrics-server-df8589546-gr5gp                  1/1     Running   0          11m
```

Enfim, Métricas de Nodes e Pods:

```
[carina@fedora pp_eks]$ k top no
NAME                         CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
ip-10-0-3-155.ec2.internal   31m          1%       379Mi           73%         
ip-10-0-4-171.ec2.internal   42m          2%       315Mi           61%         
ip-10-0-4-213.ec2.internal   33m          1%       375Mi           73%    

[carina@fedora pp_eks]$ k top po -A
NAMESPACE     NAME                                            CPU(cores)   MEMORY(bytes)   
kube-system   aws-load-balancer-controller-68bc9587b7-2zbn4   1m           20Mi            
kube-system   aws-load-balancer-controller-68bc9587b7-tsxnd   2m           20Mi            
kube-system   aws-node-2w92l                                  2m           43Mi            
kube-system   aws-node-8dxv2                                  3m           42Mi            
kube-system   aws-node-dlkdq                                  3m           43Mi            
kube-system   coredns-7d58d485c9-29ds5                        2m           11Mi            
kube-system   coredns-7d58d485c9-rqn5l                        2m           13Mi            
kube-system   kube-proxy-7qkdd                                1m           18Mi            
kube-system   kube-proxy-c56sg                                1m           18Mi            
kube-system   kube-proxy-hhhgw                                1m           19Mi            
kube-system   metrics-server-df8589546-gr5gp                  3m           18Mi           

```

2 - Gerar contexto para IA:

bash features/dump_project.sh . meu_projeto_dump.txt

3 - Verificação de recursos em execução na AWS após finalização do Laboratório:

bash features/aws-resource-check.sh

---

# Lambda

Criação de alguns recursos como uma Lambda, apenas para adição de créditos na conta AWS.

A função Lambda `ppeks-health-check` é uma aplicação web serverless que atua como **ponto central de verificação de saúde** dos recursos da infraestrutura do projeto `ppeks`. Ela é exposta publicamente via **Function URL** — ou seja, gera um endpoint HTTP diretamente, sem necessidade de API Gateway.

Quando acessada (via browser, `curl`, ou pelo EventBridge), a função executa três verificações em sequência e retorna um JSON com o resultado.

1.1 - Verifica as credenciais no SSM Parameter Store

```python
param = ssm.get_parameter(
    Name=os.environ['SSM_PATH_DB_USERNAME'],
    WithDecryption=False
)
```

Lê o parâmetro `/db/username` do **AWS Systems Manager Parameter Store** — o mesmo repositório de credenciais usado pelo backend Java e pelo workflow de deploy. Confirma que:

- A IAM Role da Lambda tem permissão de leitura no SSM

- O parâmetro existe e está acessível

1.2 - Lê o endpoint do RDS via variável de ambiente

```python
results['db_host'] = os.environ.get('DB_HOST', 'not-configured')
```

O `DB_HOST` é injetado pelo Terraform no momento do `apply`, lendo o endpoint diretamente do tfstate do RDS via `terraform_remote_state`. Isso garante que a Lambda sempre aponta para o banco correto, sem valores hardcoded.

1.3 - Retorna o status como resposta HTTP

```json
{
  "db_user_found": true,
  "db_user": "matthias",
  "db_host": "ppeks-postgres.xxxxxx.us-east-1.rds.amazonaws.com",
  "project": "ppeks",
  "status": "ok",
  "message": "ppeks Lambda health check executado com sucesso"
}
```

A resposta segue o formato esperado pela **Function URL** (`statusCode`, `headers`, `body`), tornando-a compatível com qualquer browser ou cliente HTTP.

1.4 - Infraestrutura associada

IAM Role

A Lambda executa com uma IAM Role dedicada (`ppeks-lambda-role`) com apenas duas permissões:
- `AWSLambdaBasicExecutionRole` — escrita de logs no CloudWatch
- `AmazonSSMReadOnlyAccess` — leitura de parâmetros no SSM

Nenhuma permissão de escrita, nenhum acesso ao banco diretamente — **princípio do menor privilégio**.

1.5 - Function URL

```
https://<id>.lambda-url.us-east-1.on.aws/
```

Endpoint HTTP público gerado automaticamente pela AWS. Não requer API Gateway. Método permitido: `GET`.

1.6 - EventBridge (agendamento)

Um gatilho automático executa a Lambda **a cada 5 minutos** via `rate(5 minutes)`. Isso serve para:

- Manter a Lambda "aquecida" (reduz cold start)

- Gerar logs periódicos no CloudWatch

- Funcionar como um monitor contínuo da infraestrutura

1.7 - Fluxo completo

```
Browser / curl
      │
      ▼
Function URL (HTTPS)
      │
      ▼
Lambda ppeks-health-check
      │
      ├──► SSM Parameter Store  →  /db/username
      │
      ├──► Variável DB_HOST     →  endpoint do RDS (via Terraform remote_state)
      │
      └──► Retorna JSON com status
```

```
EventBridge (rate 5min)
      │
      ▼
Lambda ppeks-health-check  →  CloudWatch Logs
```

1.8 - Como acessar

Após o `terraform apply` do `iac_lambda`, o output exibe a URL:

```bash
terraform output lambda_function_url
# https://<id>.lambda-url.us-east-1.on.aws/
```

1.9 - Acesse no browser ou via terminal:

```bash
curl https://<id>.lambda-url.us-east-1.on.aws/
```

1.10 - Relação com o restante do projeto

| Recurso                    | Como a Lambda usa                                        |
|                            |                                                          |
| **SSM Parameter Store**    | Lê `/db/username` para validar credenciais               |
| **RDS PostgreSQL**         | Exibe o endpoint via `DB_HOST` (não conecta diretamente) |
| **CloudWatch Logs**        | Registra cada execução automaticamente                   |
| **EventBridge**            | Dispara a função a cada 5 minutos                        |
| **Terraform remote_state** | Lê o endpoint do RDS do tfstate sem hardcode             |

---

# Banco de Dados

Endpoint para conexão via DBeaver.

---

# Erros mapeados durante a construção do cluster

1 - Erro ao tentar instalar o ALB Controller via Helm, pois a role que o GitHub assumia, ao criar o cluster EKS não tinha permissão de acesso ao cluster.

![ERRO](prints/image2.png)

Solução:

Como o ALB, embora seja uma implementação via Helm, faz a gerência de LBs (infra da AWS) a medida que acontece o "expose" dos deployments, a implementação do Controller que antes era feita via pipe no GitHub Actions, passou a ser feita via modulo no Terraform:

```
[carina@fedora pp_eks]$ tree ./iac_eks/modules/alb-controller/
./iac_eks/modules/alb-controller/
├── data.tf
├── helm_alb.tf
├── iam_policy.json
├── iam.tf
├── locals.tf
├── policy.tf
├── sa.tf
└── variables.tf

1 directory, 8 files
```

2 - IA não revisou "com assertividade" o meu código de criação do RDS, de modo que não tinha TFstate armazenado na AWS, deixando de fazer a gerência de criação/destruição dos recursos, como solicitado:

![TFSTATE](prints/image5.png)

Solução:

"Feeling" ao perceber erros de recursos que já estavam criados. TFSTATE devidamente configurado:

```
    backend "s3" {
    bucket = "arquivo-de-estado-tf1"
    key    = "rds/terraform.tfstate"
    region = "us-east-1"    
  }
```

---

Deleção manual de recursos (despesas extras):

3 - Deletar Snashot RDS 
2 - Deletar Imagens e ECRs
3 - Deletar tfstate e RDS

---

3 - Script que ao final do laboratório pode ser executado para validar se ficou algum recurso que não foi deletado gerando custos inesperados:

features/aws-resource-check.sh

---

# Documentações 

Projeto inicial: /docs/Projeto_Anterior.md
Análise DevOps: /docs/Projeto_Anterior.md

---

# Implementações Sugeridas

https://landscape.cncf.io/


![alt text](prints/image11.png)

---

# Badge CKA

![alt text](prints/image7.png)

---

# Badge AWS

![alt text](prints/image6.png)