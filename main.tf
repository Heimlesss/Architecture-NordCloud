# Image de base commune aux 3 tiers, résolue par son nom plutôt qu'un ID codé
# en dur : reste valide même si l'ID change d'une région/d'un projet à l'autre.
data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 22.04"
  most_recent = true
}

# Une seule paire de clés pour les 3 tiers : simplifie l'accès SSH en cascade
# (admin -> présentation -> application -> données, cf. ARCHITECTURE.md).
# Seule la clé publique transite par Terraform (var.ssh_public_key) ; la clé
# privée reste côté admin et n'est jamais stockée ici.
resource "openstack_compute_keypair_v2" "admin" {
  name       = "nordcloud-${var.author}"
  public_key = var.ssh_public_key
}

# ─── SECURITY GROUPS EN COUCHES ───────────────────────────────────────────────
# Chaque tier n'autorise que le trafic venant du tier immédiatement au-dessus
# de lui (remote_group_id), jamais 0.0.0.0/0, sauf le tier présentation qui
# est la seule porte d'entrée publique (HTTP/HTTPS + SSH admin). Ainsi le
# tier données n'est jamais exposé, ni à Internet, ni même à l'IP admin.

# ─── Tier présentation ─────────────────────────────────────────────────────────
# Seul security group autorisant du trafic depuis 0.0.0.0/0 : c'est la vitrine
# publique de l'architecture.
resource "openstack_networking_secgroup_v2" "presentation" {
  name        = "sg-presentation-${var.author}"
  description = "Tier présentation : HTTP/HTTPS publics, SSH restreint à l'IP admin"
}

# Trafic web entrant, ouvert à tous : c'est le rôle attendu du tier présentation.
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

# SSH restreint à var.my_ip : seule l'IP admin déclarée peut administrer ce
# tier, jamais Internet en général.
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
# Aucune règle "remote_ip_prefix" ici : tout est scoppé par security group
# source (remote_group_id), donc aucun accès public possible même si l'IP
# publique de l'instance était connue.
resource "openstack_networking_secgroup_v2" "application" {
  name        = "sg-application-${var.author}"
  description = "Tier application : aucun accès public, uniquement depuis le tier présentation"
}

# N'autorise que le tier présentation à parler au port applicatif (proxy/API
# vers la logique métier).
resource "openstack_networking_secgroup_rule_v2" "application_from_presentation" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.app_port
  port_range_max    = var.app_port
  remote_group_id   = openstack_networking_secgroup_v2.presentation.id
  security_group_id = openstack_networking_secgroup_v2.application.id
}

# SSH en cascade : seul le tier présentation (donc l'admin, via un premier
# saut SSH sur front) peut administrer le tier application.
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
# Le plus restrictif des 3 : seul le tier application peut lui parler, jamais
# la présentation ni Internet. C'est l'isolation exigée par le brief.
resource "openstack_networking_secgroup_v2" "database" {
  name        = "sg-database-${var.author}"
  description = "Tier données : aucun accès public, uniquement depuis le tier application"
}

# N'autorise que le tier application à parler au port du moteur de BDD.
resource "openstack_networking_secgroup_rule_v2" "database_from_application" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.db_port
  port_range_max    = var.db_port
  remote_group_id   = openstack_networking_secgroup_v2.application.id
  security_group_id = openstack_networking_secgroup_v2.database.id
}

# SSH en cascade : seul le tier application peut administrer le tier données.
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
# Seule instance exposée sur Ext-Net (IP publique) : point d'entrée unique de
# toute l'architecture, protégé par sg-presentation ci-dessus.
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
# `count` permet de scaler horizontalement (var.app_instance_count) sans
# dupliquer le bloc de ressource.
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
# Une seule instance (pas de `count`) : la BDD n'est pas destinée à scaler
# horizontalement de la même façon que le tier applicatif.
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

# Ressource distincte de la création du volume : Cinder sépare "créer un
# volume" et "l'attacher à une instance", ce qui permet par exemple de le
# recréer/déplacer sans redéployer l'instance.
resource "openstack_compute_volume_attach_v2" "db_data" {
  instance_id = openstack_compute_instance_v2.db.id
  volume_id   = openstack_blockstorage_volume_v3.db_data.id
}

# ─── IAM À PRIVILÈGE MINIMAL ──────────────────────────────────────────────────
# Voir "# Note IAM - NordCloud.md" pour le détail. En résumé : au lieu
# d'utiliser des clés API à portée compte-complet, on crée une policy qui
# n'autorise qu'une petite liste d'actions précises (lire/créer des
# instances, réseaux, volumes), uniquement sur ce projet — jamais de
# suppression, jamais d'autre projet.
#
# Tant que iam_deployer_urn n'est pas fourni (défaut ""), cette ressource est
# entièrement ignorée (count = 0) : ça permet de tester le reste de
# l'architecture sans avoir l'identité à qui donner ces droits (accès réservé
# à l'intervenant, cf. "# Note IAM - NordCloud.md").
resource "ovh_iam_policy" "nordcloud_deployer" {
  count       = var.iam_deployer_urn == "" ? 0 : 1
  name        = "nordcloud-deployer-${var.author}"
  description = "Accès limité aux ressources Compute/Network/Volume du projet ${var.ovh_project_id}"

  identities = [var.iam_deployer_urn]
  resources  = ["urn:v1:eu:resource:cloudProject:${var.ovh_project_id}"]

  # Liste courte et explicite plutôt qu'un droit large : uniquement lire et
  # créer des instances/réseaux/volumes. À confirmer/ajuster avec l'intervenant
  # une fois l'accès à la plateforme disponible (noms exacts du catalogue IAM).
  allow = [
    "cloudProject:apiovh:instance/get",
    "cloudProject:apiovh:instance/create",
    "cloudProject:apiovh:network/get",
    "cloudProject:apiovh:volume/get",
    "cloudProject:apiovh:volume/create",
  ]
}
