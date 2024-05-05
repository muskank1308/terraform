output "public-ip" {
 description = "this is the public ip"
value = aws_instance.ec2-user.public_ip
}