# Uso recomendado de Inteligência Artificial

A IA não substitui treinamentos e conhecimentos prévios acadêmicos das tecnologias envolvidas neste laboratório, apenas auxilia com dúvidas pontuais, ou sugere melhorias.

No uso de IA se faz imprescindível um desenho prévio de toda a arquitetura, bem como as etapas, pois a falta deste planejamento, gera prompts desnecessários, com saídas desnecessárias, poluindo todo o histórico de mensagens, resultando em perca de tempo nas buscas pos informações úteis.

Uma documentação bem feita (a exemplo do Projeto_Anterior.md, disponível no diretório raiz deste repositório), também traz insumos para análise de IA, o que foi disruptivo para a evolução do projeto.

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


