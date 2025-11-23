# Laboratório - Aplicação

O mesmo consiste em uma aplicação em Python, com dois endpoints, nas respectivas portas:

1 - Porta 8000/tcp

Aplicação que recebe comentários em texto. Como a mesma não está disponibilizada através de um frontend as requisições serão feitas diretamente a API.

Exemplos de uso:

```
# matéria 1
curl -sv localhost:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"alice@example.com","comment":"first post!","content_id":1}'
curl -sv localhost:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"alice@example.com","comment":"ok, now I am gonna say something more useful","content_id":1}'
curl -sv localhost:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"bob@example.com","comment":"I agree","content_id":1}'

# matéria 2
curl -sv localhost:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"bob@example.com","comment":"I guess this is a good thing","content_id":2}'
curl -sv localhost:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"charlie@example.com","comment":"Indeed, dear Bob, I believe so as well","content_id":2}'
curl -sv localhost:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"eve@example.com","comment":"Nah, you both are wrong","content_id":2}'

# listagem matéria 1
curl -sv localhost:8000/api/comment/list/1

# listagem matéria 2
curl -sv localhost:8000/api/comment/list/2
```

Dados coletados durante o Laboratório:

```
[carina@fedora ekspp]$ curl -sv a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"alice@example.com","comment":"first post!","content_id":1}'
* Host a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000 was resolved.
* IPv6: (none)
* IPv4: 34.192.6.19, 35.168.80.67
*   Trying 34.192.6.19:8000...
* Connected to a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com (34.192.6.19) port 8000
> POST /api/comment/new HTTP/1.1
> Host: a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000
> User-Agent: curl/8.6.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 68
> 
* Empty reply from server
* Closing connection

[carina@fedora ekspp]$ curl -sv a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"alice@example.com","comment":"ok, now I am gonna say something more useful","content_id":1}'
* Host a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000 was resolved.
* IPv6: (none)
* IPv4: 34.192.6.19, 35.168.80.67
*   Trying 34.192.6.19:8000...
* Connected to a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com (34.192.6.19) port 8000
> POST /api/comment/new HTTP/1.1
> Host: a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000
> User-Agent: curl/8.6.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 101
> 
* Empty reply from server
* Closing connection

[carina@fedora ekspp]$ curl -sv a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"bob@example.com","comment":"I agree","content_id":1}'
* Host a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000 was resolved.
* IPv6: (none)
* IPv4: 34.192.6.19, 35.168.80.67
*   Trying 34.192.6.19:8000...
* Connected to a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com (34.192.6.19) port 8000
> POST /api/comment/new HTTP/1.1
> Host: a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000
> User-Agent: curl/8.6.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 62
> 
* Empty reply from server
* Closing connection

[carina@fedora ekspp]$ curl -sv a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"bob@example.com","comment":"I guess this is a good thing","content_id":2}'
* Host a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000 was resolved.
* IPv6: (none)
* IPv4: 34.192.6.19, 35.168.80.67
*   Trying 34.192.6.19:8000...
* Connected to a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com (34.192.6.19) port 8000
> POST /api/comment/new HTTP/1.1
> Host: a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000
> User-Agent: curl/8.6.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 83
> 
* Empty reply from server
* Closing connection

[carina@fedora ekspp]$ curl -sv a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"charlie@example.com","comment":"Indeed, dear Bob, I believe so as well","content_id":2}'
* Host a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000 was resolved.
* IPv6: (none)
* IPv4: 34.192.6.19, 35.168.80.67
*   Trying 34.192.6.19:8000...
* Connected to a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com (34.192.6.19) port 8000
> POST /api/comment/new HTTP/1.1
> Host: a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000
> User-Agent: curl/8.6.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 97
> 
* Empty reply from server
* Closing connection

[carina@fedora ekspp]$ curl -sv a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"eve@example.com","comment":"Nah, you both are wrong","content_id":2}'
* Host a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000 was resolved.
* IPv6: (none)
* IPv4: 34.192.6.19, 35.168.80.67
*   Trying 34.192.6.19:8000...
* Connected to a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com (34.192.6.19) port 8000
> POST /api/comment/new HTTP/1.1
> Host: a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000
> User-Agent: curl/8.6.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 78
> 
* Empty reply from server
* Closing connection

[carina@fedora ekspp]$ curl -sv a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000/api/comment/list/1
* Host a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000 was resolved.
* IPv6: (none)
* IPv4: 34.192.6.19, 35.168.80.67
*   Trying 34.192.6.19:8000...
* Connected to a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com (34.192.6.19) port 8000
> GET /api/comment/list/1 HTTP/1.1
> Host: a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000
> User-Agent: curl/8.6.0
> Accept: */*
> 
* Empty reply from server
* Closing connection

[carina@fedora ekspp]$ curl -sv a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000/api/comment/list/2
* Host a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000 was resolved.
* IPv6: (none)
* IPv4: 34.192.6.19, 35.168.80.67
*   Trying 34.192.6.19:8000...
* Connected to a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com (34.192.6.19) port 8000
> GET /api/comment/list/2 HTTP/1.1
> Host: a814ceeca59784f9ca861a8bb40339fb-2090287217.us-east-1.elb.amazonaws.com:8000
> User-Agent: curl/8.6.0
> Accept: */*
> 
* Empty reply from server
* Closing connection
```

2 - Porta 7000/tcp

Aplicação envia métricas através do coletor do Prometheus.

Exemplos de uso:

```
curl -v http://localhost:7000/metrics
```

Dados coletados durante o Laboratório:

```
*   Trying ::1:7000...
* TCP_NODELAY set
* connect to ::1 port 7000 failed: Connection refused
*   Trying 127.0.0.1:7000...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 7000 (#0)
> GET /metrics HTTP/1.1
> Host: localhost:7000
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
* HTTP 1.0, assume close after body
< HTTP/1.0 200 OK
< Date: Mon, 30 Jun 2025 01:41:21 GMT
< Server: WSGIServer/0.2 CPython/3.8.10
< Content-Type: text/plain; version=0.0.4; charset=utf-8
< Content-Length: 2148
< 
# HELP python_gc_objects_collected_total Objects collected during gc
# TYPE python_gc_objects_collected_total counter
python_gc_objects_collected_total{generation="0"} 289.0
python_gc_objects_collected_total{generation="1"} 107.0
python_gc_objects_collected_total{generation="2"} 0.0
# HELP python_gc_objects_uncollectable_total Uncollectable objects found during GC
# TYPE python_gc_objects_uncollectable_total counter
python_gc_objects_uncollectable_total{generation="0"} 0.0
python_gc_objects_uncollectable_total{generation="1"} 0.0
python_gc_objects_uncollectable_total{generation="2"} 0.0
# HELP python_gc_collections_total Number of times this generation was collected
# TYPE python_gc_collections_total counter
python_gc_collections_total{generation="0"} 64.0
python_gc_collections_total{generation="1"} 5.0
python_gc_collections_total{generation="2"} 0.0
# HELP python_info Python platform information
# TYPE python_info gauge
python_info{implementation="CPython",major="3",minor="8",patchlevel="10",version="3.8.10"} 1.0
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 1.88637184e+08
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 2.65216e+07
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.75124752607e+09
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 0.2
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 6.0
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 65536.0
# HELP app_requests_total Total de requisições processadas
# TYPE app_requests_total counter
app_requests_total 320.0
# HELP app_requests_created Total de requisições processadas
# TYPE app_requests_created gauge
app_requests_created 1.7512475265861325e+09
* Closing connection 0
```

# Laboratório - CI_CD via Github Actions

O código da aplicação, bem como as instruções são abstraídos em um Dockerfile:

```
FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y python3.9 python3.9-dev pip

# Configurando diretório atual para o diretório /app a ser executado no container
COPY ./app /app

# Instalando dependências
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Expondo porta da aplicação
EXPOSE 8000

# Comando de Inicialização
WORKDIR /app
CMD cd /app;  python3 api.py 
```

Através da pipeline previamente configurada, disponibilizada no diretório padrão do Git .github/workflows, será criada uma imagem a ser armazanada em um repositório no ECR na AWS.

Evidência do repositório: <img src="https://github.com/carina-pereira-devops/appeks/blob/868c5a1020d4e3830dfa9da034e00f1296823633/prints/5.png" alt="ECR">

# Laboratório - Infra na AWS criada via Terraform

Estrutura dos diretórios de acordo com este repositório, onde os recursos serão modularizados.

```
iac_eks/
├── destroy_config.json
├── locals.tf
├── modules
│   ├── argo
│   │   └── main.tf
│   ├── aws-load-balancer-controller
│   │   ├── data.tf
│   │   ├── helm.tf
│   │   ├── iam_policy.json
│   │   ├── iam.tf
│   │   ├── locals.tf
│   │   ├── policy.tf
│   │   ├── serviceaccount.tf
│   │   └── variables.tf
│   ├── cluster
│   │   ├── cluster.tf
│   │   ├── iam.tf
│   │   ├── oidc.tf
│   │   ├── outputs.tf
│   │   ├── sg-rule.tf
│   │   └── variables.tf
│   ├── managed-node-group
│   │   ├── eks.tf
│   │   ├── iam.tf
│   │   └── variables.tf
│   ├── network
│   │   ├── igw.tf
│   │   ├── ngw.tf
│   │   ├── output.tf
│   │   ├── private.tf
│   │   ├── public.tf
│   │   ├── region.tf
│   │   ├── variables.tf
│   │   └── vpc.tf
│   └── waf
│       └── main.tf
├── modules.tf
├── provider.tf
├── terraform.tfvars
└── variables.tf
```

Os custos com os testes e resolução de problemas (tshoot) durante os testes são satisfatórios.

<img src="https://github.com/carina-pereira-devops/appeks/blob/cbd88f8ce0d5f0fdcbcc04b65c7022e47b5e137a/prints/12.png" alt="AWS">

Importante lembrar também a importância da escolha de recursos. Na imagem acima, notamos que os custos com as instâncias EC2 (nodes que hospedam os Pods) são relevantes. Por isso desde o ínício do Laboratório mensuramos a utilização de CPU/Memória dos Pods, para que os mesmos fossem executados com folga, porém sem desperdícios.

# Laboratório - Implementações

A imagem construída na etapa de CICD, será deploiada em um cluster EKS, no qual também terá as seguintes implementações:

1 - ArgoCD, tendo o Git como única fonte de verdade. Esta implementação é feita via Helm juntamente com o Terraform, sendo apenas a customização do recurso (argo.yaml) sendo feita manualmente. No mesmo diretório, teremos o artefato para a implementação da aplicação explanada na primeira etapa.

```
[carina@fedora ekspp]$ tree app_values/
app_values/
├── app.yaml
└── argo.yaml
```

Abaixo o exemplo de sincronismo entre o Argo e o Git, durante o deploy de uma nova versão da aplicação: <img src="https://github.com/carina-pereira-devops/appeks/blob/4462cc0fdd9b533129da2abdfddf258e9ea436e3/prints/4.png" alt="Argo">

2 - A implementação do Prometheus Server que será feita via Helm manualmente. <img src="https://github.com/carina-pereira-devops/appeks/blob/cbd88f8ce0d5f0fdcbcc04b65c7022e47b5e137a/prints/9.png" alt="Prometheus">

Obs.: Será feita a adição no ConfigMap customizado das configurações do Prometheus, para que o mesmo receba as métricas que coletamos na porta 7000 da aplicação, conforme o print: <img src="https://github.com/carina-pereira-devops/appeks/blob/be94c4856e1cb1e455aba4c37872019239a67139/prints/13.png" alt="CM">

O Grafana criará as Dashs com as métricas envidas pelo Prometheus:

<img src="https://github.com/carina-pereira-devops/appeks/blob/cbd88f8ce0d5f0fdcbcc04b65c7022e47b5e137a/prints/10.png" alt="Pr-Gr">

3 - A implementação do Grafana que será feita via Helm manualmente. <img src="https://github.com/carina-pereira-devops/appeks/blob/5187a309ae2575295dd71ab67dee32e64ef3ee8f/prints/8.png" alt="Grafana">

O resultado esperado será a análise do comportamento da aplicação, a medida que a mesma recebe as requisições:<img src="https://github.com/carina-pereira-devops/appeks/blob/cbd88f8ce0d5f0fdcbcc04b65c7022e47b5e137a/prints/11.png" alt="Dash">

# Execuções manuais (futuras automações)

```
1 - Criação da Infra via IaC

2 - Construção da imagem da aplicação IaC

Atualizando context do cluster:
aws eks update-kubeconfig --region us-east-1 --name ekspp-cluster
kubectl config use-context  arn:aws:eks:us-east-1:535002861869:cluster/ekspp-cluster

Validação:
kubectl get po -A
kubectl get no

Alias:
alias k='kubectl'

Deploy manual da aplicação:
kubectl apply -f app_values/app.yaml

Credenciais do Argo para configuração do Projeto
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d

Apenas exemplos (não são as credenciais atuais):
admin 
cbJidwERE1rGrH7m

Endpoint do service para acesso ao Argo:
kubectl -n argocd get svc

Informações solicitadas:
Repo:
https://github.com/carina-pereira-devops/appeks
Path:
app_values
Branch:
main 
Nome da aplicação
python
Namespace
app 

Obs.: Caso a aplicação não esteja operacional o projeto no Argo não é criado.

Endpoint da aplicação:
kubectl get svc -n app
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)                         AGE
python-service   LoadBalancer   172.20.91.248   aca1723546f354b6d8896916d01ce0fd-1707209365.us-east-1.elb.amazonaws.com   8000:32616/TCP,7000:32515/TCP   19m

Requisições:
# matéria 1
curl -sv <endpoint>:8000 -X POST -H 'Content-Type: application/json' -d '{"email":"alice@example.com","comment":"first post!","content_id":1}'
curl -sv <endpoint>:8000 -X POST -H 'Content-Type: application/json' -d '{"email":"alice@example.com","comment":"ok, now I am gonna say something more useful","content_id":1}'
curl -sv <endpoint>:8000 -X POST -H 'Content-Type: application/json' -d '{"email":"bob@example.com","comment":"I agree","content_id":1}'
# matéria 2
curl -sv <endpoint>:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"bob@example.com","comment":"I guess this is a good thing","content_id":2}'
curl -sv <endpoint>:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"charlie@example.com","comment":"Indeed, dear Bob, I believe so as well","content_id":2}'
curl -sv <endpoint>:8000/api/comment/new -X POST -H 'Content-Type: application/json' -d '{"email":"eve@example.com","comment":"Nah, you both are wrong","content_id":2}'
# listagem matéria 1
curl -sv <endpoint>:8000/api/comment/list/1
# listagem matéria 2
curl -sv <endpoint>:8000/api/comment/list/2

Forçando parada da aplicação para validação das requisições:
kubectl -n app delete po python-59c697dfdf-bw8sg --force --grace-period 0

Não há execução na saida:
curl -sv aca1723546f354b6d8896916d01ce0fd-1707209365.us-east-1.elb.amazonaws.com:8000/api/comment/list/1
* Host aca1723546f354b6d8896916d01ce0fd-1707209365.us-east-1.elb.amazonaws.com:8000 was resolved.
* IPv6: (none)
* IPv4: 54.210.178.46, 50.16.221.30
*   Trying 54.210.178.46:8000...

Instalação do curl no Pod/Container da aplicação:
kubectl -n app exec -ti  python-68796f44c7-hldh6 -- /bin/bash

Execução no Pod/Container:
apt install curl 

Validação:
kubectl -n app exec  python-68796f44c7-hldh6 -- curl http://localhost:7000/metrics

Instalação para coleta de Métricas do Cluster, a medida que os recursos são implementados:
kubectl apply -f recursos/metrics.yaml

Instalação do prometheus via linha de comando:
helm install prometheus prometheus-community/kube-prometheus-stack --namespace app

Obs.: Validação é feita consultando todos os Pods com a label que referencia o deploy do Prometheus.

kubectl --namespace app get pods -l "release=prometheus"
NAME                                                   READY   STATUS    RESTARTS   AGE
prometheus-kube-prometheus-operator-54c9b77c65-8nlcw   1/1     Running   0          2m51s
prometheus-kube-state-metrics-7f5f75c85d-5wrp4         1/1     Running   0          2m51s
prometheus-prometheus-node-exporter-nsf6f              1/1     Running   0          2m51s
prometheus-prometheus-node-exporter-wdg7f              1/1     Running   0          2m51s

Na instalação da pilha do Prometheus, já vem a implementação do Grafana.

Apenas validar se é a credencial padrão:
kubectl --namespace app get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Apenas exemplos (não são as credenciais atuais):
admin
prom-operator

A implementação sugere o port-forward (requer conhecimento de Kubernetes para entendimento de como e qual serviço será exposto):
export POD_NAME=$(kubectl --namespace app get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname)
kubectl --namespace app port-forward $POD_NAME 3000

Porém será feita a edição do service e a alteração do ClusterIp para LoadBalancer, para acesso no navegador:
kubectl -n app edit svc grafana
service/grafana edited
Obs.: informar o endpoint no CM do Prometheus

Obs.: A título de informação caso fosse necessário expor a aplicação via linha de comando:
kubectl expose deployment grafana --type=LoadBalancer --port=80 --name=grafana
kubectl expose deployment <nome_do_deployment> --type=LoadBalancer --port=<porta_de_exposição> --name=<nome_do_serviço>

O Grafana criará as Dashs de acordo com as métricas envidas pelo Prometheus.

Para que o Prometheus envie as métricas se faz necessário algumas configurações:

1 - Configurar o prometheus para receber as métricas do endpoint através do arquivo:
/etc/prometheus/prometheus.yml

2 - Configurar Prometheus para coletar métricas do Cluster.

Porém como não conseguimos alterar as configurações que já vem no container, a configuração será feita através:
1 - Configuração de acesso RBAC através do arquivo recursos/clusterRole.yaml:
[carina@fedora ekspp]$ kubectl apply -f recursos/clusterRole.yaml 
clusterrole.rbac.authorization.k8s.io/prometheus created
clusterrolebinding.rbac.authorization.k8s.io/prometheus created

2 - Customização das consfigurações através de um ConfigMap localizado em recursos/cm.yaml:
[carina@fedora ekspp]$ kubectl apply -f recursos/cm.yaml 
configmap/prometheus-server-conf created

3 - Uma nova implementação do prometheus-server, localizado em recursos/deploy.yaml:
[carina@fedora ekspp]$ kubectl apply -f recursos/deploy.yaml 
deployment.apps/prometheus-deployment created

Obs.: No item 3 faremos a configuração para exportar as métricas que coletamos com a biblioteca prometheus_client, da aplicação em python.

Edição do service e a alteração do ClusterIp para LoadBalancer, para acesso no navegador:
kubectl -n app edit svc prometheus-kube-prometheus-prometheus
service/prometheus-kube-prometheus-prometheus edited
Obs.: informar o endpoint no CM do Prometheus
```

# Validações:

ALB Controller é uma implementação via Helm que gerencia os ALBs. 

Semelhante ao Protocolo Arp que atua na camada 2,5 traduzindo Ip para MAC.

Quando um service do tipo LoadBalancer do Kubernetes expoẽ uma aplicação, automaticamente um LB é criado, e quando finaliza o LB é encerrado. <img src="ttps://github.com/carina-pereira-devops/appeks/blob/099aed66c15aedf9cfd5420dac1c9b93c76dcb00/prints/1.png" alt="ALB">

Detalhe sobe instância t3.medium (padrão na subida do cluster): <img src="https://github.com/carina-pereira-devops/appeks/blob/099aed66c15aedf9cfd5420dac1c9b93c76dcb00/prints/3.png" alt="T3">

Foram coletadas métricas durante os testes, para justificativa de aumento ou redução dos recursos do cluster:

Pods:

```
NAMESPACE     NAME                                                 CPU(cores)   MEMORY(bytes)   
app           grafana-577575669d-rzcgr                             3m           77Mi            
app           prometheus-kube-state-metrics-57d654d7bf-mv5l2       2m           15Mi            
app           prometheus-prometheus-node-exporter-5kxhv            1m           3Mi             
app           prometheus-prometheus-node-exporter-cj9m5            1m           3Mi             
app           prometheus-prometheus-node-exporter-vkw9z            1m           3Mi             
app           prometheus-prometheus-node-exporter-w6q5m            1m           3Mi             
app           prometheus-prometheus-pushgateway-784c485d55-vrmsk   1m           6Mi             
argocd        argocd-application-controller-0                      1m           25Mi            
argocd        argocd-applicationset-controller-696b6668f-n4rfm     1m           21Mi            
argocd        argocd-dex-server-c68dfbb6-qlwfg                     1m           19Mi            
argocd        argocd-notifications-controller-f55767bc9-hglt9      1m           18Mi            
argocd        argocd-redis-6465fc4f75-vp5b5                        2m           2Mi             
argocd        argocd-repo-server-5c5cb94ff8-kshqs                  1m           21Mi            
argocd        argocd-server-5c976fcf44-qpjnd                       2m           25Mi            
kube-system   aws-load-balancer-controller-78f7564788-4gqsw        2m           21Mi            
kube-system   aws-load-balancer-controller-78f7564788-sw45v        1m           19Mi            
kube-system   aws-node-4kqlh                                       3m           54Mi            
kube-system   aws-node-klhwc                                       3m           57Mi            
kube-system   aws-node-p5fql                                       3m           54Mi            
kube-system   aws-node-zq9x9                                       3m           55Mi            
kube-system   coredns-5d849c4789-dr8j8                             2m           13Mi            
kube-system   coredns-5d849c4789-p9zpw                             2m           13Mi            
kube-system   kube-proxy-5mhvx                                     2m           12Mi            
kube-system   kube-proxy-5zq8j                                     1m           12Mi            
kube-system   kube-proxy-nztmq                                     2m           12Mi            
kube-system   kube-proxy-t9g9x                                     2m           12Mi            
kube-system   metrics-server-db4f45b97-smg9w                       6m           16Mi            
```

Nodes:

```
NAME                         CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
ip-10-0-3-14.ec2.internal    21m          1%       490Mi           14%         
ip-10-0-3-157.ec2.internal   30m          1%       576Mi           17%         
ip-10-0-4-130.ec2.internal   25m          1%       497Mi           15%         
ip-10-0-4-95.ec2.internal    34m          1%       458Mi           13%         
```

# Situações que impactaram no tempo da entrega:

1 - Implementações via Helm, conflito de versões das implementações dos Charts via IaC Terraform.<img src="https://github.com/carina-pereira-devops/appeks/blob/099aed66c15aedf9cfd5420dac1c9b93c76dcb00/prints/7.png" alt="Erro">

Implementação do Prometheus, necessita de storage de persistência, exemplo de saída de acordo com os Eventos do Cluster:

```
3m4s        Normal    FailedBinding             persistentvolumeclaim/prometheus-server                   no persistent volumes available for this claim and no storage class is set
9m10s       Normal    EnsuringLoadBalancer      service/prometheus-server                                 Ensuring load balancer
9m9s        Warning   UnAvailableLoadBalancer   service/prometheus-server                                 There are no available nodes for LoadBalancer
9m9s        Normal    ScalingReplicaSet         deployment/prometheus-server                              Scaled up replica set prometheus-server-b48bbcb5c from 0 to 1
9m8s        Normal    EnsuredLoadBalancer       service/prometheus-server                                 Ensured load balancer
8m13s       Normal    UpdatedLoadBalancer       service/prometheus-server                                 Updated load balancer with new hosts
3m4s        Normal    FailedBinding             persistentvolumeclaim/storage-prometheus-alertmanager-0   no persistent volumes available for this claim and no storage class is set
```

Na descrição do service via Helm, essas eram as classes configuradas:

```
kubectl describe pvc prometheus-server
               volume.beta.kubernetes.io/storage-provisioner: ebs.csi.eks.amazonaws.com
               volume.kubernetes.io/selected-node: ip-10-0-3-99.ec2.internal
               volume.kubernetes.io/storage-provisioner: ebs.csi.eks.amazonaws.com
```

Obs.: Lembrando que em uma implementação de volumes no kubernetes, primeiramente definimo a StorageClass (sc), na sequência o PersistentVolume (pv), e finalmente o PersistentVolumeClaim (pvc).

2 - Implementações via artefatos do Kubernetes (yaml), falta de implementações CRD no cluster EKS.

Saídas das implementações:

```
no matches for kind "Ingress"            in version "extensions/v1beta1"                ensure CRDs are installed first
no matches for kind "ClusterRole"        in version "rbac.authorization.k8s.io/v1beta1" ensure CRDs are installed first
no matches for kind "ClusterRoleBinding" in version "rbac.authorization.k8s.io/v1beta1" ensure CRDs are installed first
```

Listando CRDs disponíveis:

```
kubectl get crd
NAME                                         CREATED AT
cninodes.vpcresources.k8s.aws                2025-06-28T21:38:03Z
eniconfigs.crd.k8s.amazonaws.com             2025-06-28T21:39:50Z
ingressclassparams.elbv2.k8s.aws             2025-06-28T21:42:37Z
policyendpoints.networking.k8s.aws           2025-06-28T21:38:03Z
securitygrouppolicies.vpcresources.k8s.aws   2025-06-28T21:38:03Z
targetgroupbindings.elbv2.k8s.aws            2025-06-28T21:42:37Z
```

# Questionamentos:

1 - Quais boas práticas para o Código IaC:

    Implementações via Terraform

    Implementações via Helm

    Implementações via artefatos

    Implementações via Ansible

2 - Como instalar crd, como exemplo networking.k8s.io/v1?

# Melhorias futuras:

1 - Autenticação via Role, mesmo para IaC via Github Actions.

Saída na tentativa da conexão com o cluster criado recentemente via CiCd:

```
"Unhandled Error" err="couldn't get current server API group list: the server has asked for the client to provide credentials"
```

Autenticação via Role, com acesso aos Workloads do Cluster, mesmo com criação via Github Actions.

Detalhe das configurações de acesso ao EKS: <img src="https://github.com/carina-pereira-devops/appeks/blob/099aed66c15aedf9cfd5420dac1c9b93c76dcb00/prints/6.png" alt="Acesso">

2 - Traefik como ingress do kubernetes, instanciando apenas um LB, configurando as rotas para as demais requisições. <img src="https://github.com/carina-pereira-devops/appeks/blob/caf887d81889a363612bb5315ee33d9186550a75/prints/2.png" alt="Traefik">

A implementação e configuração prévia do Traefik, eliminará a exposição manual dos serviços.

Obs.: Exemplo de configuração manual:

Criação manual do recurso, uma vez que o CRD não está implementando no Cluster:

```
kubectl -n prometheus create ingress prometheus --rule="/prometheus=prometheus-service:9090"
```

Anotação para que o recurso seja utilizado:

```
kubectl -n prometheus annotate ingress prometheus kubernetes.io/ingress.class=traefik
```

Obs.: Embora tenha sido sugerida esta implementação, devido ao tempo disponibilizado, os serviços principais foram expostos através do ALB Controller.

3 - Monitoramento Opentelemetry:

Web store: http://localhost:8080/

Grafana: http://localhost:8080/grafana/

Load Generator UI: http://localhost:8080/loadgen/

Jaeger UI: http://localhost:8080/jaeger/ui/

Flagd configurator UI: http://localhost:8080/feature

4 - Script shell para as etapas manuais da aplicação.

# Referências utilizadas na construção deste Laboratório:
Terraform para AWS, Mateus Muller (Udemy)

https://spacelift.io/blog/argocd-terraform

https://medium.com/@habbema/monitorando-aplica%C3%A7%C3%B5es-python-com-prometheus-e-grafana-020a69ffafa8

https://devopscube.com/setup-prometheus-monitoring-on-kubernetes

https://github.com/techiescamp/kubernetes-prometheus

Sugestão para formatação de Markdown: https://stackedit.io/app#

