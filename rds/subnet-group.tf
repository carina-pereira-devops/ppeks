# rds/subnet-group.tf
resource "aws_db_subnet_group" "this" {
  name = "${var.project_name}-rds-subnet-group"
  subnet_ids = [                                                        # ← antes: var.private_subnets
    data.terraform_remote_state.eks.outputs.subnet_priv_1a,
    data.terraform_remote_state.eks.outputs.subnet_priv_1b,
  ]
  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}