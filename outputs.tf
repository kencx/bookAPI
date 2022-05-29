output "public_dns" {
  value       = aws_instance.instance.public_dns
  description = "Instance Public DNS"
}

output "db_connection_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "nat_gateway_public_ip" {
  value = aws_eip.nat.public_ip
}
