output "vpc_id" { 
    value = aws_vpc.this.id 
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "route_table_ids" {
  value = [aws_route_table.public.id, aws_route_table.private.id]
}
