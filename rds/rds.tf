data "aws_ssm_parameter" "db_username" {
  name = "/db/username"
}

data "aws_ssm_parameter" "db_password" {
  name            = "/db/password"
  with_decryption = true
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-postgres"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro"  # free tier elegível
  allocated_storage      = 20

  db_name                = "mydb"
  username               = data.aws_ssm_parameter.db_username.value
  password               = data.aws_ssm_parameter.db_password.value

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false
  storage_encrypted   = false

  skip_final_snapshot = true
}
