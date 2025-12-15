resource "aws_security_group" "db" {
  name        = "db-sg-${var.environment}"
  description = "DB access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Postgres/MySQL from VPC (simple demo)"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # simple; en real lo restringes al SG de la app
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "db-subnet-${var.environment}"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier             = "db-${var.environment}"
  engine                 = var.db_engine
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  skip_final_snapshot    = true
  publicly_accessible    = false

  #esto se puede modificar dependiendoque tan seguido quiera las copias de seguridad
  backup_retention_period = 0
}
