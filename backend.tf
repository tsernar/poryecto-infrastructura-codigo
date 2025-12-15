terraform {
  backend "s3" {
    bucket         = "terraform-thomas-prueba"
    key            = "project9/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
