# Toutes les valeurs concrètes (my_ip, clé SSH, project ID...) vivent dans
# terraform.tfvars, non versionné (cf. .gitignore) : ce fichier ne définit
# que le contrat (nom, type, description, valeur par défaut si sans risque).

# ─── Projet OVHcloud ──────────────────────────────────────────────────────────
variable "ovh_project_id" {
  description = "OVHcloud Public Cloud project ID"
  type        = string
}

variable "region" {
  description = "Région OVHcloud cible (doit être une région Public Cloud avec réseau privé)"
  type        = string
  default     = "GRA11"
}

variable "author" {
  description = "Suffixe identifiant l'auteur / l'environnement, utilisé dans le nommage des ressources"
  type        = string
}

variable "my_ip" {
  description = "IP publique admin autorisée en SSH sur le tier présentation (format x.x.x.x/32)"
  type        = string
}

variable "ssh_public_key" {
  description = "Clé publique SSH injectée sur les 3 tiers (accès en cascade : admin -> présentation -> application -> données)"
  type        = string
}

# ─── Tier présentation ─────────────────────────────────────────────────────────
variable "front_flavor" {
  description = "Flavor OVHcloud de l'instance du tier présentation"
  type        = string
  default     = "d2-2"
}

# ─── Tier application ──────────────────────────────────────────────────────────
variable "app_flavor" {
  description = "Flavor OVHcloud des instances du tier application"
  type        = string
  default     = "d2-2"
}

variable "app_instance_count" {
  description = "Nombre d'instances du tier application"
  type        = number
  default     = 1
}

variable "app_port" {
  description = "Port applicatif exposé par le tier application au tier présentation"
  type        = number
  default     = 8080
}

# ─── Tier données ───────────────────────────────────────────────────────────────
variable "db_flavor" {
  description = "Flavor OVHcloud de l'instance du tier données"
  type        = string
  default     = "d2-4"
}

variable "db_port" {
  description = "Port du moteur de base de données exposé au tier application"
  type        = number
  default     = 5432
}

variable "db_volume_size" {
  description = "Taille (Go) du volume de données chiffré attaché au tier données"
  type        = number
  default     = 20
}

variable "db_volume_type" {
  description = "Type de volume Cinder OVHcloud pour le volume de données (catalogue dépendant du projet)"
  type        = string
  default     = "high-speed-gen2"
}

# ─── IAM à privilège minimal ────────────────────────────────────────────────────
variable "iam_deployer_urn" {
  description = "URN de l'identité IAM OVH (compte, groupe ou clé API) à qui accorder la policy de déploiement à privilège minimal. Laisser vide pour tester le plan sans ce volet (la policy ne sera alors pas créée)."
  type        = string
  default     = ""
}
