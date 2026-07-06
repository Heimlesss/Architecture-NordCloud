output "front_public_ip" {
  description = "IP publique du tier présentation (seul point d'entrée prévu)"
  value       = openstack_compute_instance_v2.front.access_ip_v4
}

output "app_ips" {
  description = "IPs des instances du tier application"
  value       = [for i in openstack_compute_instance_v2.app : i.access_ip_v4]
}

output "db_ip" {
  description = "IP de l'instance du tier données"
  value       = openstack_compute_instance_v2.db.access_ip_v4
}
