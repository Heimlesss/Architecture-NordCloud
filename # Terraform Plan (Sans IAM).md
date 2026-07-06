~/Architecture-NordCloud$ terraform plan
data.openstack_images_image_v2.ubuntu: Reading...
data.openstack_images_image_v2.ubuntu: Read complete after 2s [id=819aecfa-f89c-4023-b289-ecd1655bf558]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # openstack_blockstorage_volume_v3.db_data will be created
  + resource "openstack_blockstorage_volume_v3" "db_data" {
      + attachment        = (known after apply)
      + availability_zone = (known after apply)
      + description       = "Volume de données chiffré du tier données (isolé du disque de boot)"
      + id                = (known after apply)
      + metadata          = (known after apply)
      + name              = "db-data-Nulos"
      + region            = "GRA11"
      + size              = 20
      + volume_type       = "high-speed-gen2"
    }

  # openstack_compute_instance_v2.app[0] will be created
  + resource "openstack_compute_instance_v2" "app" {
      + access_ip_v4        = (known after apply)
      + access_ip_v6        = (known after apply)
      + all_metadata        = (known after apply)
      + all_tags            = (known after apply)
      + availability_zone   = (known after apply)
      + created             = (known after apply)
      + flavor_id           = (known after apply)
      + flavor_name         = "d2-2"
      + force_delete        = false
      + id                  = (known after apply)
      + image_id            = "819aecfa-f89c-4023-b289-ecd1655bf558"
      + image_name          = (known after apply)
      + key_pair            = "nordcloud-Nulos"
      + name                = "app-Nulos-0"
      + power_state         = "active"
      + region              = "GRA11"
      + security_groups     = [
          + "sg-application-Nulos",
        ]
      + stop_before_destroy = false
      + updated             = (known after apply)

      + network {
          + access_network = false
          + fixed_ip_v4    = (known after apply)
          + fixed_ip_v6    = (known after apply)
          + mac            = (known after apply)
          + name           = "Ext-Net"
          + port           = (known after apply)
          + uuid           = (known after apply)
        }
    }

  # openstack_compute_instance_v2.db will be created
  + resource "openstack_compute_instance_v2" "db" {
      + access_ip_v4        = (known after apply)
      + access_ip_v6        = (known after apply)
      + all_metadata        = (known after apply)
      + all_tags            = (known after apply)
      + availability_zone   = (known after apply)
      + created             = (known after apply)
      + flavor_id           = (known after apply)
      + flavor_name         = "d2-4"
      + force_delete        = false
      + id                  = (known after apply)
      + image_id            = "819aecfa-f89c-4023-b289-ecd1655bf558"
      + image_name          = (known after apply)
      + key_pair            = "nordcloud-Nulos"
      + name                = "db-Nulos"
      + power_state         = "active"
      + region              = "GRA11"
      + security_groups     = [
          + "sg-database-Nulos",
        ]
      + stop_before_destroy = false
      + updated             = (known after apply)

      + network {
          + access_network = false
          + fixed_ip_v4    = (known after apply)
          + fixed_ip_v6    = (known after apply)
          + mac            = (known after apply)
          + name           = "Ext-Net"
          + port           = (known after apply)
          + uuid           = (known after apply)
        }
    }

  # openstack_compute_instance_v2.front will be created
  + resource "openstack_compute_instance_v2" "front" {
      + access_ip_v4        = (known after apply)
      + access_ip_v6        = (known after apply)
      + all_metadata        = (known after apply)
      + all_tags            = (known after apply)
      + availability_zone   = (known after apply)
      + created             = (known after apply)
      + flavor_id           = (known after apply)
      + flavor_name         = "d2-2"
      + force_delete        = false
      + id                  = (known after apply)
      + image_id            = "819aecfa-f89c-4023-b289-ecd1655bf558"
      + image_name          = (known after apply)
      + key_pair            = "nordcloud-Nulos"
      + name                = "front-Nulos"
      + power_state         = "active"
      + region              = "GRA11"
      + security_groups     = [
          + "sg-presentation-Nulos",
        ]
      + stop_before_destroy = false
      + updated             = (known after apply)

      + network {
          + access_network = false
          + fixed_ip_v4    = (known after apply)
          + fixed_ip_v6    = (known after apply)
          + mac            = (known after apply)
          + name           = "Ext-Net"
          + port           = (known after apply)
          + uuid           = (known after apply)
        }
    }

  # openstack_compute_keypair_v2.admin will be created
  + resource "openstack_compute_keypair_v2" "admin" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + name        = "nordcloud-Nulos"
      + private_key = (sensitive value)
      + public_key  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEiqYXBSifwDQiuuXCRTKT0+xxzLjY2KSld7FbbyqhNo ovh-terraform"
      + region      = (known after apply)
      + user_id     = (known after apply)
    }

  # openstack_compute_volume_attach_v2.db_data will be created
  + resource "openstack_compute_volume_attach_v2" "db_data" {
      + device      = (known after apply)
      + id          = (known after apply)
      + instance_id = (known after apply)
      + region      = (known after apply)
      + volume_id   = (known after apply)
    }

  # openstack_networking_secgroup_rule_v2.application_from_presentation will be created
  + resource "openstack_networking_secgroup_rule_v2" "application_from_presentation" {
      + direction         = "ingress"
      + ethertype         = "IPv4"
      + id                = (known after apply)
      + port_range_max    = 8080
      + port_range_min    = 8080
      + protocol          = "tcp"
      + region            = (known after apply)
      + remote_group_id   = (known after apply)
      + remote_ip_prefix  = (known after apply)
      + security_group_id = (known after apply)
      + tenant_id         = (known after apply)
    }

  # openstack_networking_secgroup_rule_v2.application_ssh_from_presentation will be created
  + resource "openstack_networking_secgroup_rule_v2" "application_ssh_from_presentation" {
      + direction         = "ingress"
      + ethertype         = "IPv4"
      + id                = (known after apply)
      + port_range_max    = 22
      + port_range_min    = 22
      + protocol          = "tcp"
      + region            = (known after apply)
      + remote_group_id   = (known after apply)
      + remote_ip_prefix  = (known after apply)
      + security_group_id = (known after apply)
      + tenant_id         = (known after apply)
    }

  # openstack_networking_secgroup_rule_v2.database_from_application will be created
  + resource "openstack_networking_secgroup_rule_v2" "database_from_application" {
      + direction         = "ingress"
      + ethertype         = "IPv4"
      + id                = (known after apply)
      + port_range_max    = 5432
      + port_range_min    = 5432
      + protocol          = "tcp"
      + region            = (known after apply)
      + remote_group_id   = (known after apply)
      + remote_ip_prefix  = (known after apply)
      + security_group_id = (known after apply)
      + tenant_id         = (known after apply)
    }

  # openstack_networking_secgroup_rule_v2.database_ssh_from_application will be created
  + resource "openstack_networking_secgroup_rule_v2" "database_ssh_from_application" {
      + direction         = "ingress"
      + ethertype         = "IPv4"
      + id                = (known after apply)
      + port_range_max    = 22
      + port_range_min    = 22
      + protocol          = "tcp"
      + region            = (known after apply)
      + remote_group_id   = (known after apply)
      + remote_ip_prefix  = (known after apply)
      + security_group_id = (known after apply)
      + tenant_id         = (known after apply)
    }

  # openstack_networking_secgroup_rule_v2.presentation_http will be created
  + resource "openstack_networking_secgroup_rule_v2" "presentation_http" {
      + direction         = "ingress"
      + ethertype         = "IPv4"
      + id                = (known after apply)
      + port_range_max    = 80
      + port_range_min    = 80
      + protocol          = "tcp"
      + region            = (known after apply)
      + remote_group_id   = (known after apply)
      + remote_ip_prefix  = "0.0.0.0/0"
      + security_group_id = (known after apply)
      + tenant_id         = (known after apply)
    }

  # openstack_networking_secgroup_rule_v2.presentation_https will be created
  + resource "openstack_networking_secgroup_rule_v2" "presentation_https" {
      + direction         = "ingress"
      + ethertype         = "IPv4"
      + id                = (known after apply)
      + port_range_max    = 443
      + port_range_min    = 443
      + protocol          = "tcp"
      + region            = (known after apply)
      + remote_group_id   = (known after apply)
      + remote_ip_prefix  = "0.0.0.0/0"
      + security_group_id = (known after apply)
      + tenant_id         = (known after apply)
    }

  # openstack_networking_secgroup_rule_v2.presentation_ssh will be created
  + resource "openstack_networking_secgroup_rule_v2" "presentation_ssh" {
      + direction         = "ingress"
      + ethertype         = "IPv4"
      + id                = (known after apply)
      + port_range_max    = 22
      + port_range_min    = 22
      + protocol          = "tcp"
      + region            = (known after apply)
      + remote_group_id   = (known after apply)
      + remote_ip_prefix  = "176.142.194.61/32"
      + security_group_id = (known after apply)
      + tenant_id         = (known after apply)
    }

  # openstack_networking_secgroup_v2.application will be created
  + resource "openstack_networking_secgroup_v2" "application" {
      + all_tags    = (known after apply)
      + description = "Tier application : aucun accès public, uniquement depuis le tier présentation"
      + id          = (known after apply)
      + name        = "sg-application-Nulos"
      + region      = (known after apply)
      + stateful    = (known after apply)
      + tenant_id   = (known after apply)
    }

  # openstack_networking_secgroup_v2.database will be created
  + resource "openstack_networking_secgroup_v2" "database" {
      + all_tags    = (known after apply)
      + description = "Tier données : aucun accès public, uniquement depuis le tier application"
      + id          = (known after apply)
      + name        = "sg-database-Nulos"
      + region      = (known after apply)
      + stateful    = (known after apply)
      + tenant_id   = (known after apply)
    }

  # openstack_networking_secgroup_v2.presentation will be created
  + resource "openstack_networking_secgroup_v2" "presentation" {
      + all_tags    = (known after apply)
      + description = "Tier présentation : HTTP/HTTPS publics, SSH restreint à l'IP admin"
      + id          = (known after apply)
      + name        = "sg-presentation-Nulos"
      + region      = (known after apply)
      + stateful    = (known after apply)
      + tenant_id   = (known after apply)
    }

Plan: 16 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + app_ips         = [
      + (known after apply),
    ]
  + db_ip           = (known after apply)
  + front_public_ip = (known after apply)
