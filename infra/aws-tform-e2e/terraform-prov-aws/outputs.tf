output "public_connection_string" {
  description = "Copy/Paste/Enter - You are in the matrix"
  value       = "ssh -i ${module.ssh-key.key_name}.pem ubuntu@${module.ec2.public_ip}"
}

output "private_connection_string" {
  description = "Copy/Paste/Enter - You are in the private ec2 instance"
  value       = "ssh -i ${module.ssh-key.key_name}.pem ubuntu@${module.ec2.private_ip}"
}