terraform {
  # Versions minimales testées pour ce projet (cf. .terraform.lock.hcl pour
  # les versions exactes de providers réellement installées et validées).
  required_version = ">= 1.6.0"
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.14"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 2.0"
    }
  }
}
