# ============================================================
# SQS + EventBridge — Spot Interruption Handling
# Quando a AWS vai interromper um spot, envia aviso 2 min antes.
# O Karpenter lê a fila e drena o node graciosamente.
# ============================================================

resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = "${var.project_name}-karpenter-interruption"
  message_retention_seconds = 300 # 5 minutos — suficiente para o aviso de spot

  tags = merge(var.tags, { Name = "${var.project_name}-karpenter-interruption" })
}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  queue_url = aws_sqs_queue.karpenter_interruption.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = ["events.amazonaws.com", "sqs.amazonaws.com"] }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.karpenter_interruption.arn
      }
    ]
  })
}

# Eventos que o Karpenter precisa monitorar para spot
resource "aws_cloudwatch_event_rule" "spot_interruption" {
  name        = "${var.project_name}-karpenter-spot-interruption"
  description = "Aviso de interrupção de Spot Instance para o Karpenter"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Spot Instance Interruption Warning"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "spot_interruption" {
  rule      = aws_cloudwatch_event_rule.spot_interruption.name
  target_id = "KarpenterInterruption"
  arn       = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "instance_rebalance" {
  name        = "${var.project_name}-karpenter-rebalance"
  description = "EC2 Instance Rebalance Recommendation para o Karpenter"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance Rebalance Recommendation"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "instance_rebalance" {
  rule      = aws_cloudwatch_event_rule.instance_rebalance.name
  target_id = "KarpenterRebalance"
  arn       = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "instance_state_change" {
  name        = "${var.project_name}-karpenter-state-change"
  description = "EC2 Instance State Change para o Karpenter"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "instance_state_change" {
  rule      = aws_cloudwatch_event_rule.instance_state_change.name
  target_id = "KarpenterStateChange"
  arn       = aws_sqs_queue.karpenter_interruption.arn
}
