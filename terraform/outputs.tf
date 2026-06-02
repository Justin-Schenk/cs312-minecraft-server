output "instance_public_ip" {
  description = "Public IP address of the Minecraft server"
  value       = aws_instance.minecraft.public_ip
}
