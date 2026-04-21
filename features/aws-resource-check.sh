#!/bin/bash
# ==============================================================
# aws-resource-check.sh — Lista recursos ppeks ainda ativos na AWS
# Uso: bash aws-resource-check.sh
# Região: us-east-1 (ajuste AWS_REGION se necessário)
# ==============================================================

REGION="us-east-1"
PROJECT="ppeks"
SEP="=================================================================="
WARN="\e[33m[ATENÇÃO]\e[0m"
OK="\e[32m[OK]\e[0m"
FOUND="\e[31m[ATIVO]\e[0m"

echo -e "\n$SEP"
echo "  AWS Resource Check — projeto: $PROJECT"
echo "  Região: $REGION | $(date)"
echo -e "$SEP\n"

# --------------------------------------------------------------
# EKS
# --------------------------------------------------------------
echo "### EKS Clusters"
CLUSTERS=$(aws eks list-clusters --region $REGION --query 'clusters' --output text 2>/dev/null)
if [ -z "$CLUSTERS" ]; then
  echo -e "$OK Nenhum cluster EKS ativo"
else
  for C in $CLUSTERS; do
    echo -e "$FOUND Cluster: $C"
    NGS=$(aws eks list-nodegroups --cluster-name $C --region $REGION --query 'nodegroups' --output text 2>/dev/null)
    for NG in $NGS; do
      echo -e "   $FOUND  NodeGroup: $NG"
    done
  done
fi
echo ""

# --------------------------------------------------------------
# EC2 — Instâncias rodando
# --------------------------------------------------------------
echo "### EC2 Instâncias rodando"
EC2=$(aws ec2 describe-instances \
  --region $REGION \
  --filters "Name=instance-state-name,Values=running,stopped" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0]]' \
  --output text 2>/dev/null)
if [ -z "$EC2" ]; then
  echo -e "$OK Nenhuma instância EC2 ativa"
else
  echo -e "$FOUND Instâncias encontradas:"
  echo "$EC2" | while read ID TYPE STATE NAME; do
    echo -e "   $FOUND $ID | $TYPE | $STATE | $NAME"
  done
fi
echo ""

# --------------------------------------------------------------
# RDS
# --------------------------------------------------------------
echo "### RDS Instâncias"
RDS=$(aws rds describe-db-instances \
  --region $REGION \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus,Engine]' \
  --output text 2>/dev/null)
if [ -z "$RDS" ]; then
  echo -e "$OK Nenhuma instância RDS ativa"
else
  echo -e "$FOUND RDS encontrado:"
  echo "$RDS" | while read ID CLASS STATUS ENGINE; do
    echo -e "   $FOUND $ID | $CLASS | $STATUS | $ENGINE"
  done
fi
echo ""

# --------------------------------------------------------------
# RDS Snapshots (manuais e automáticos)
# --------------------------------------------------------------
echo "### RDS Snapshots"

# Snapshots manuais
SNAPS_MANUAL=$(aws rds describe-db-snapshots \
  --region $REGION \
  --snapshot-type manual \
  --query 'DBSnapshots[*].[DBSnapshotIdentifier,DBInstanceIdentifier,SnapshotCreateTime,AllocatedStorage,Status]' \
  --output text 2>/dev/null)
if [ -z "$SNAPS_MANUAL" ]; then
  echo -e "$OK Nenhum snapshot manual de RDS"
else
  echo -e "$FOUND Snapshots MANUAIS encontrados (cobram armazenamento!):"
  echo "$SNAPS_MANUAL" | while read SNAP_ID DB_ID CREATED STORAGE STATUS; do
    echo -e "   $FOUND $SNAP_ID | DB: $DB_ID | $STORAGE GB | $STATUS | criado: $CREATED"
  done
fi

# Snapshots automáticos (gerados pelo destroy do Terraform com skip_final_snapshot=false)
SNAPS_AUTO=$(aws rds describe-db-snapshots \
  --region $REGION \
  --snapshot-type automated \
  --query 'DBSnapshots[*].[DBSnapshotIdentifier,DBInstanceIdentifier,SnapshotCreateTime,AllocatedStorage,Status]' \
  --output text 2>/dev/null)
if [ -z "$SNAPS_AUTO" ]; then
  echo -e "$OK Nenhum snapshot automático de RDS"
else
  echo -e "$WARN Snapshots AUTOMÁTICOS encontrados (gratuitos dentro do free tier, mas verifique):"
  echo "$SNAPS_AUTO" | while read SNAP_ID DB_ID CREATED STORAGE STATUS; do
    echo -e "   $WARN $SNAP_ID | DB: $DB_ID | $STORAGE GB | $STATUS | criado: $CREATED"
  done
fi

# Snapshots gerados no final do destroy (final snapshots)
SNAPS_FINAL=$(aws rds describe-db-snapshots \
  --region $REGION \
  --query "DBSnapshots[?contains(DBSnapshotIdentifier, 'final') || contains(DBSnapshotIdentifier, '$PROJECT')].[DBSnapshotIdentifier,DBInstanceIdentifier,SnapshotCreateTime,AllocatedStorage,Status]" \
  --output text 2>/dev/null)
if [ ! -z "$SNAPS_FINAL" ]; then
  echo -e "$FOUND Snapshots com 'final' ou '$PROJECT' no nome (provavelmente gerados pelo destroy):"
  echo "$SNAPS_FINAL" | while read SNAP_ID DB_ID CREATED STORAGE STATUS; do
    echo -e "   $FOUND $SNAP_ID | DB: $DB_ID | $STORAGE GB | $STATUS | criado: $CREATED"
    echo -e "         Para deletar: aws rds delete-db-snapshot --db-snapshot-identifier $SNAP_ID --region $REGION"
  done
fi
echo ""

# --------------------------------------------------------------
# NAT Gateways (cobram por hora mesmo sem tráfego!)
# --------------------------------------------------------------
echo "### NAT Gateways"
NATS=$(aws ec2 describe-nat-gateways \
  --region $REGION \
  --filter "Name=state,Values=available,pending" \
  --query 'NatGateways[*].[NatGatewayId,State,Tags[?Key==`Name`].Value|[0]]' \
  --output text 2>/dev/null)
if [ -z "$NATS" ]; then
  echo -e "$OK Nenhum NAT Gateway ativo"
else
  echo -e "$FOUND NAT Gateways encontrados (cobram ~\$0.045/hora cada!):"
  echo "$NATS" | while read ID STATE NAME; do
    echo -e "   $FOUND $ID | $STATE | $NAME"
  done
fi
echo ""

# --------------------------------------------------------------
# Elastic IPs não associados
# --------------------------------------------------------------
echo "### Elastic IPs não associados"
EIPS=$(aws ec2 describe-addresses \
  --region $REGION \
  --query 'Addresses[?AssociationId==null].[AllocationId,PublicIp,Tags[?Key==`Name`].Value|[0]]' \
  --output text 2>/dev/null)
if [ -z "$EIPS" ]; then
  echo -e "$OK Nenhum Elastic IP solto"
else
  echo -e "$FOUND Elastic IPs não associados (cobram quando não usados!):"
  echo "$EIPS" | while read ALLOC IP NAME; do
    echo -e "   $FOUND $ALLOC | $IP | $NAME"
  done
fi
echo ""

# --------------------------------------------------------------
# Load Balancers
# --------------------------------------------------------------
echo "### Load Balancers (ALB/NLB)"
LBS=$(aws elbv2 describe-load-balancers \
  --region $REGION \
  --query 'LoadBalancers[*].[LoadBalancerName,Type,State.Code,DNSName]' \
  --output text 2>/dev/null)
if [ -z "$LBS" ]; then
  echo -e "$OK Nenhum Load Balancer ativo"
else
  echo -e "$FOUND Load Balancers encontrados:"
  echo "$LBS" | while read NAME TYPE STATE DNS; do
    echo -e "   $FOUND $NAME | $TYPE | $STATE"
  done
fi
echo ""

# --------------------------------------------------------------
# Lambda
# --------------------------------------------------------------
echo "### Lambda Functions"
LAMBDAS=$(aws lambda list-functions \
  --region $REGION \
  --query 'Functions[*].[FunctionName,Runtime,LastModified]' \
  --output text 2>/dev/null)
if [ -z "$LAMBDAS" ]; then
  echo -e "$OK Nenhuma Lambda ativa"
else
  echo -e "$FOUND Lambdas encontradas:"
  echo "$LAMBDAS" | while read NAME RUNTIME MODIFIED; do
    echo -e "   $FOUND $NAME | $RUNTIME | modificada: $MODIFIED"
  done
fi
echo ""

# --------------------------------------------------------------
# ECR Repositórios
# --------------------------------------------------------------
echo "### ECR Repositórios"
ECRS=$(aws ecr describe-repositories \
  --region $REGION \
  --query 'repositories[*].[repositoryName,createdAt]' \
  --output text 2>/dev/null)
if [ -z "$ECRS" ]; then
  echo -e "$OK Nenhum repositório ECR"
else
  echo -e "$FOUND ECR repositórios (armazenamento cobrado):"
  echo "$ECRS" | while read NAME CREATED; do
    echo -e "   $FOUND $NAME | criado: $CREATED"
  done
fi
echo ""

# --------------------------------------------------------------
# VPCs não default
# --------------------------------------------------------------
echo "### VPCs (não-default)"
VPCS=$(aws ec2 describe-vpcs \
  --region $REGION \
  --filters "Name=isDefault,Values=false" \
  --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
  --output text 2>/dev/null)
if [ -z "$VPCS" ]; then
  echo -e "$OK Nenhuma VPC customizada"
else
  echo -e "$FOUND VPCs customizadas encontradas:"
  echo "$VPCS" | while read ID CIDR NAME; do
    echo -e "   $FOUND $ID | $CIDR | $NAME"
  done
fi
echo ""

# --------------------------------------------------------------
# S3 Buckets
# --------------------------------------------------------------
echo "### S3 Buckets"
BUCKETS=$(aws s3api list-buckets \
  --query 'Buckets[*].[Name,CreationDate]' \
  --output text 2>/dev/null)
if [ -z "$BUCKETS" ]; then
  echo -e "$OK Nenhum bucket S3"
else
  echo -e "$WARN Buckets S3 (verifique se ainda são necessários):"
  echo "$BUCKETS" | while read NAME DATE; do
    echo -e "   $WARN $NAME | criado: $DATE"
  done
fi
echo ""

# --------------------------------------------------------------
# IAM Roles do projeto
# --------------------------------------------------------------
echo "### IAM Roles do projeto ($PROJECT)"
ROLES=$(aws iam list-roles \
  --query "Roles[?contains(RoleName, '$PROJECT')].[RoleName,CreateDate]" \
  --output text 2>/dev/null)
if [ -z "$ROLES" ]; then
  echo -e "$OK Nenhuma IAM Role com '$PROJECT' no nome"
else
  echo -e "$WARN IAM Roles encontradas:"
  echo "$ROLES" | while read NAME DATE; do
    echo -e "   $WARN $NAME | criada: $DATE"
  done
fi
echo ""

# --------------------------------------------------------------
# CloudWatch Log Groups
# --------------------------------------------------------------
echo "### CloudWatch Log Groups do projeto"
LOGS=$(aws logs describe-log-groups \
  --region $REGION \
  --log-group-name-prefix "/aws/eks/$PROJECT" \
  --query 'logGroups[*].[logGroupName,storedBytes]' \
  --output text 2>/dev/null)
LOGS2=$(aws logs describe-log-groups \
  --region $REGION \
  --log-group-name-prefix "/aws/lambda/$PROJECT" \
  --query 'logGroups[*].[logGroupName,storedBytes]' \
  --output text 2>/dev/null)
if [ -z "$LOGS" ] && [ -z "$LOGS2" ]; then
  echo -e "$OK Nenhum Log Group do projeto"
else
  echo -e "$WARN Log Groups (podem gerar custo de armazenamento):"
  echo "$LOGS $LOGS2" | while read NAME BYTES; do
    echo -e "   $WARN $NAME | $BYTES bytes"
  done
fi
echo ""

# --------------------------------------------------------------
# RESUMO FINAL
# --------------------------------------------------------------
echo -e "$SEP"
echo "  RESUMO — recursos que MAIS geram custo se esquecidos:"
echo -e "$SEP"
echo "  1. EKS Cluster        → ~\$0.10/hora só pelo control plane"
echo "  2. NAT Gateway        → ~\$0.045/hora cada (você tem 2!)"
echo "  3. EC2 / Node Groups  → depende do tipo (t3.micro = ~\$0.01/hora)"
echo "  4. RDS                → db.t3.micro = ~\$0.02/hora"
echo "  5. Load Balancer ALB  → ~\$0.008/hora + dados"
echo "  6. Elastic IPs soltos → ~\$0.005/hora quando não associados"
echo "  7. RDS Snapshots      → \$0.095/GB-mês acima do free tier"
echo ""
echo "  Para deletar um snapshot manualmente:"
echo "  aws rds delete-db-snapshot --db-snapshot-identifier <ID> --region $REGION"
echo -e "$SEP\n"

