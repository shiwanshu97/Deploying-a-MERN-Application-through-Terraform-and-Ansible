output "web_instance_public_ip" {
  description = "Public IP address of the TravelMemory web server"
  value       = aws_instance.web.public_ip
}

output "web_instance_public_dns" {
  description = "Public DNS name of the TravelMemory web server"
  value       = aws_instance.web.public_dns
}

output "database_instance_private_ip" {
  description = "Private IP address of the MongoDB server"
  value       = aws_instance.database.private_ip
}

output "web_security_group_id" {
  description = "Security group ID of the web server"
  value       = aws_security_group.web.id
}

output "database_security_group_id" {
  description = "Security group ID of the database server"
  value       = aws_security_group.database.id
}