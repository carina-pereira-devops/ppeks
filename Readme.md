![OPS](prints/image1.png)

# Esta documentação está em construção, então as informações ainda não estão na ordem correta, nem com as devidas evidências!

---

# Uso recomendado de Inteligência Artificial

A IA não substitui treinamentos e conhecimentos prévios acadêmicos das tecnologias envolvidas neste laboratório, apenas auxilia com dúvidas pontuais, ou sugere melhorias.

Seja na edição de prompts, ou nas respostas da IA, ter este conhecimento prévio, acelera o resultado esperado.

No uso de IA se faz imprescindível um desenho prévio de toda a arquitetura, bem como as etapas, pois a falta deste planejamento, gera prompts desnecessários, com saídas desnecessárias, poluindo todo o histórico de mensagens, resultando em perca de tempo nas buscas pos informações úteis.

Uma documentação bem feita (a exemplo do Projeto_Anterior.md, disponível no diretório raiz deste repositório), também traz insumos para análise de IA, o que foi disruptivo para a evolução do projeto. Por padrão IAs fazem a leitura de Readme, então tenha sempre em mente a importância de boas documentações.

# Acesso a AWS

Certifique-se que o mesmo usuário que acessa a console (1), seja o mesmo usuário com acesso via awscli (2), e o mesmo usuário ao qual serão concedidas as permissões de visualização (3):

![USER](prints/image3.png)

1 - Lembrando que ao logar com o usuário root da conta, o que geralmente é o comum, não será possível visualizar, Pods, Services, etc... (isso pode causar confusão).

```
2 - Acesso via awscli, será com esse usuário que executaremos os comandos via Kubectl:
[carina@fedora pp_eks]$ aws sts get-caller-identity
{
...
"Arn": "arn:aws:iam::749000351410:user/devops"
}

```

3 - Permissões atribuídas via IAM (código Terraform), ao mesmo usuário:

![IAM](prints/image4.png)


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

Validação:

```
aws eks update-kubeconfig --region us-east-1 --name ppeks-cluster
Updated context arn:aws:eks:us-east-1:749000351410:cluster/ppeks-cluster in /home/carina/.kube/config

kubectl config use-context  arn:aws:eks:us-east-1:749000351410:cluster/ppeks-cluster
Switched to context "arn:aws:eks:us-east-1:749000351410:cluster/ppeks-cluster".

[carina@fedora pp_eks]$ k get nodes
NAME                         STATUS   ROLES    AGE     VERSION
ip-10-0-3-23.ec2.internal    Ready    <none>   2m55s   v1.34.2-eks-ecaa3a6
ip-10-0-4-211.ec2.internal   Ready    <none>   2m57s   v1.34.2-eks-ecaa3a6

[carina@fedora pp_eks]$ k get pods -A
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-97g2d             2/2     Running   0          3m23s
kube-system   aws-node-c9rvg             2/2     Running   0          3m22s
kube-system   coredns-7d58d485c9-28q95   1/1     Running   0          6m55s
kube-system   coredns-7d58d485c9-w4sgm   1/1     Running   0          6m55s
kube-system   kube-proxy-hmcnj           1/1     Running   0          3m22s
kube-system   kube-proxy-v4kr7           1/1     Running   0          3m23s

```

# Features

Instalação manual via kubectl, do deploy de métricas, para coleta de informações de CPU e Memória de Nodes e Pods:

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

obs.: Em um primeiro deploy, com apenas dois nodes no cluster não haviam recursos para a implementação do recurso (considerando com o deploy do ALB Controller):

Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  3m34s  default-scheduler  0/2 nodes are available: 2 Too many pods. no new claims to deallocate, preemption: 0/2 nodes are available: 2 No preemption victims found for incoming pod.

[carina@fedora pp_eks]$ k -n kube-system get deploy
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
coredns          2/2     2            2           17m
metrics-server   1/1     1            1           5m32s

[carina@fedora pp_eks]$ k -n kube-system get po
NAME                             READY   STATUS    RESTARTS   AGE
aws-node-kjn9l                   2/2     Running   0          15m
aws-node-pswqq                   2/2     Running   0          15m
coredns-7d58d485c9-4gnwm         1/1     Running   0          18m
coredns-7d58d485c9-7hdb2         1/1     Running   0          18m
kube-proxy-gw7n9                 1/1     Running   0          15m
kube-proxy-mv86m                 1/1     Running   0          15m
metrics-server-df8589546-vc8zl   1/1     Running   0          5m52s

[carina@fedora pp_eks]$ k top no
NAME                         CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
ip-10-0-3-73.ec2.internal    27m          1%       342Mi           66%         
ip-10-0-4-183.ec2.internal   23m          1%       334Mi           65% 

[carina@fedora pp_eks]$ k top po -A
NAMESPACE     NAME                             CPU(cores)   MEMORY(bytes)   
kube-system   aws-node-kjn9l                   4m           42Mi            
kube-system   aws-node-pswqq                   3m           43Mi            
kube-system   coredns-7d58d485c9-4gnwm         2m           11Mi            
kube-system   coredns-7d58d485c9-7hdb2         2m           11Mi            
kube-system   kube-proxy-gw7n9                 1m           20Mi            
kube-system   kube-proxy-mv86m                 1m           20Mi            
kube-system   metrics-server-df8589546-vc8zl   3m           17Mi            

```

# Erros mapeados durante a construção do cluster

1 - Erro ao tentar instalar o ALB Controller via Helm, pois a role que o GitHub assumia, ao criar o cluster EKS não tinha permissão de acessar o cluster.

![ERRO](prints/image2.png)

Solução:

Configuração das permissões no arquivo cluster.tf:

```
```





