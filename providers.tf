# Provider OVHcloud natif : instances, réseau privé, etc.
provider "ovh" {
  endpoint = "ovh-eu"
  # Credentials via : OVH_APPLICATION_KEY, _SECRET, _CONSUMER_KEY
}

# Provider OpenStack : Security Groups, règles réseau (Neutron)
provider "openstack" {
  auth_url = "https://auth.cloud.ovh.net/v3"
  region   = var.region
  # Credentials via RC file sourcé : OS_USERNAME, OS_PASSWORD, etc.
}
