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


