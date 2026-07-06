data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 22.04"
  most_recent = true
}

# Clé SSH commune : accès en cascade admin -> présentation -> application -> données
resource "openstack_compute_keypair_v2" "admin" {
  name       = "nordcloud-${var.author}"
  public_key = var.ssh_public_key
}

# ─── SECURITY GROUPS EN COUCHES ───────────────────────────────────────────────
# Chaque tier n'autorise que le trafic venant du tier immédiatement au-dessus
# de lui (remote_group_id), jamais 0.0.0.0/0, sauf le tier présentation qui
# est la seule porte d'entrée publique (HTTP/HTTPS + SSH admin).

# ─── Tier présentation ─────────────────────────────────────────────────────────
resource "openstack_networking_secgroup_v2" "presentation" {
  name        = "sg-presentation-${var.author}"
  description = "Tier présentation : HTTP/HTTPS publics, SSH restreint à l'IP admin"
}

resource "openstack_networking_secgroup_rule_v2" "presentation_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.presentation.id
}

resource "openstack_networking_secgroup_rule_v2" "presentation_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.presentation.id
}

resource "openstack_networking_secgroup_rule_v2" "presentation_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.my_ip
  security_group_id = openstack_networking_secgroup_v2.presentation.id
}

# ─── Tier application ──────────────────────────────────────────────────────────
resource "openstack_networking_secgroup_v2" "application" {
  name        = "sg-application-${var.author}"
  description = "Tier application : aucun accès public, uniquement depuis le tier présentation"
}

resource "openstack_networking_secgroup_rule_v2" "application_from_presentation" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.app_port
  port_range_max    = var.app_port
  remote_group_id   = openstack_networking_secgroup_v2.presentation.id
  security_group_id = openstack_networking_secgroup_v2.application.id
}

resource "openstack_networking_secgroup_rule_v2" "application_ssh_from_presentation" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = openstack_networking_secgroup_v2.presentation.id
  security_group_id = openstack_networking_secgroup_v2.application.id
}

# ─── Tier données ───────────────────────────────────────────────────────────────
resource "openstack_networking_secgroup_v2" "database" {
  name        = "sg-database-${var.author}"
  description = "Tier données : aucun accès public, uniquement depuis le tier application"
}

resource "openstack_networking_secgroup_rule_v2" "database_from_application" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.db_port
  port_range_max    = var.db_port
  remote_group_id   = openstack_networking_secgroup_v2.application.id
  security_group_id = openstack_networking_secgroup_v2.database.id
}

resource "openstack_networking_secgroup_rule_v2" "database_ssh_from_application" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = openstack_networking_secgroup_v2.application.id
  security_group_id = openstack_networking_secgroup_v2.database.id
}

# ─── TIER PRÉSENTATION ─────────────────────────────────────────────────────────
resource "openstack_compute_instance_v2" "front" {
  name        = "front-${var.author}"
  flavor_name = var.front_flavor
  image_id    = data.openstack_images_image_v2.ubuntu.id
  region      = var.region
  key_pair    = openstack_compute_keypair_v2.admin.name

  security_groups = [openstack_networking_secgroup_v2.presentation.name]

  network {
    name = "Ext-Net"
  }
}

# ─── TIER APPLICATION ──────────────────────────────────────────────────────────
# Isolé par security group : aucun accès entrant sauf depuis sg-presentation.
resource "openstack_compute_instance_v2" "app" {
  count       = var.app_instance_count
  name        = "app-${var.author}-${count.index}"
  flavor_name = var.app_flavor
  image_id    = data.openstack_images_image_v2.ubuntu.id
  region      = var.region
  key_pair    = openstack_compute_keypair_v2.admin.name

  security_groups = [openstack_networking_secgroup_v2.application.name]

  network {
    name = "Ext-Net"
  }
}

# ─── TIER DONNÉES ───────────────────────────────────────────────────────────────
# Isolé par security group : aucun accès entrant sauf depuis sg-application.
resource "openstack_compute_instance_v2" "db" {
  name        = "db-${var.author}"
  flavor_name = var.db_flavor
  image_id    = data.openstack_images_image_v2.ubuntu.id
  region      = var.region
  key_pair    = openstack_compute_keypair_v2.admin.name

  security_groups = [openstack_networking_secgroup_v2.database.name]

  network {
    name = "Ext-Net"
  }
}

# ─── VOLUME CHIFFRÉ DU TIER DONNÉES ──────────────────────────────────────────
# Le volume Cinder est distinct du disque de boot : il isole les données
# sensibles et peut être chiffré indépendamment de l'OS (cf. ARCHITECTURE.md
# pour la mise en œuvre du chiffrement au repos).
resource "openstack_blockstorage_volume_v3" "db_data" {
  name        = "db-data-${var.author}"
  description = "Volume de données chiffré du tier données (isolé du disque de boot)"
  size        = var.db_volume_size
  region      = var.region
  volume_type = var.db_volume_type
}

resource "openstack_compute_volume_attach_v2" "db_data" {
  instance_id = openstack_compute_instance_v2.db.id
  volume_id   = openstack_blockstorage_volume_v3.db_data.id
}

# ─── IAM À PRIVILÈGE MINIMAL ──────────────────────────────────────────────────
# Plutôt que d'utiliser des clés API à portée compte-complet pour le
# déploiement, on scope une identité IAM aux seules actions nécessaires
# (lecture/création/liste) sur le Compute, le Network et le Volume de CE
# projet Public Cloud uniquement.
data "ovh_iam_reference_actions" "cloud_project" {
  type = "cloudProject"
}

locals {
  # Filtre les actions du catalogue cloudProject à celles réellement requises
  # par ce déploiement (instances, réseau, volumes), en lecture/écriture de
  # base uniquement (pas de delete/update en dehors de Terraform lui-même).
  deployer_allowed_actions = [
    for a in data.ovh_iam_reference_actions.cloud_project.actions :
    a.action if(
      can(regex("(?i)(instance|network|volume)", a.action)) &&
      can(regex("(?i)(get|list|create)", a.action))
    )
  ]
}

resource "ovh_iam_policy" "nordcloud_deployer" {
  name        = "nordcloud-deployer-${var.author}"
  description = "Accès limité aux ressources Compute/Network/Volume du projet ${var.ovh_project_id}"

  identities = [var.iam_deployer_urn]
  resources  = ["urn:v1:eu:resource:cloudProject:${var.ovh_project_id}"]
  allow      = local.deployer_allowed_actions
}
