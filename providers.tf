# Provider OVHcloud natif : utilisé ici uniquement pour le volet IAM
# (ovh_iam_policy dans main.tf), cf. "# Note IAM - NordCloud.md".
provider "ovh" {
  endpoint = "ovh-eu"
  # Credentials via : OVH_APPLICATION_KEY, _SECRET, _CONSUMER_KEY
}

# Provider OpenStack : instances, security groups (Neutron), volumes (Cinder).
# Nécessaire car l'API OVH native ne gère pas les security groups en couches
# demandés par le brief — cette gestion passe par Neutron/OpenStack, avec une
# authentification distincte des clés API OVH ci-dessus.
provider "openstack" {
  auth_url = "https://auth.cloud.ovh.net/v3"
  region   = var.region
  # Credentials via RC file sourcé : OS_USERNAME, OS_PASSWORD, etc.
  # (ex: source ~/openrc.sh avant terraform plan/apply)
}
