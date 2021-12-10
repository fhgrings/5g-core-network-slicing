output "public_ip" {
  value = aws_instance.kubernetes-master-pub.public_ip
}

output "private_ip" {
  value = aws_instance.kubernetes-worker-pub[0].private_ip
}