![OPS](prints/image1.png)

# Esta documentação está em construção, então as informações ainda não estão na ordem correta, nem com as devidas evidências!

---

# Uso recomendado de Inteligência Artificial

A IA não substitui treinamentos e conhecimentos prévios acadêmicos das tecnologias envolvidas neste laboratório, apenas auxilia com dúvidas pontuais, ou sugere melhorias.

Seja na edição de prompts, ou nas respostas da IA, ter este conhecimento prévio, acelera o resultado esperado.

No uso de IA se faz imprescindível um desenho prévio de toda a arquitetura, bem como as etapas, pois a falta deste planejamento, gera prompts desnecessários, com saídas desnecessárias, poluindo todo o histórico de mensagens, resultando em perca de tempo nas buscas pos informações úteis.

Uma documentação bem feita (a exemplo do Projeto_Anterior.md, disponível no diretório raiz deste repositório), também traz insumos para análise de IA, o que foi disruptivo para a evolução do projeto. Por padrão IAs fazem a leitura de Readme, então tenha sempre em mente a importância de boas documentações.

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

# Erros

Erro ao tentar instalar o ALB Controller via Helm:

![OPS](prints/image2.png)




