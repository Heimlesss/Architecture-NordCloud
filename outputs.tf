# IPs utiles pour se connecter (SSH en cascade, cf. ARCHITECTURE.md) et pour
# vérifier l'état des instances sans accès au Manager OVH.
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

output "instances_status" {
  description = "État connu par Terraform (id, power_state, date de création) pour chaque instance, faute d'accès au Manager OVH"
  value = {
    front = {
      id          = openstack_compute_instance_v2.front.id
      power_state = openstack_compute_instance_v2.front.power_state
      created     = openstack_compute_instance_v2.front.created
      updated     = openstack_compute_instance_v2.front.updated
    }
    app = {
      for i in openstack_compute_instance_v2.app : i.name => {
        id          = i.id
        power_state = i.power_state
        created     = i.created
        updated     = i.updated
      }
    }
    db = {
      id          = openstack_compute_instance_v2.db.id
      power_state = openstack_compute_instance_v2.db.power_state
      created     = openstack_compute_instance_v2.db.created
      updated     = openstack_compute_instance_v2.db.updated
    }
  }
}
