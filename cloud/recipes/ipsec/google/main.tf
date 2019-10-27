#
# Google Cloud Platform specific inputs
#
variable "google_dns_managed_zone_name" {
  default = ""
}

variable "google_dns_zone" {
  type = string
}

#
# Bootstrap VPN server
#

module "bootstrap" {
  source = "../../../../../cloud-inceptor/modules/bootstrap/google"

  #
  # Company information used in certificate creation
  #
  company_name = "${var.company_name}"

  organization_name = "${var.organization_name}"

  locality = "${var.locality}"

  province = "${var.province}"

  country = "${var.country}"

  #
  # VPC details
  #
  region = "${var.region}"

  # Name of VPC will be used to identify 
  # VPC specific cloud resources
  vpc_name = "${var.name}-ipsec-${var.region}"

  # DNS Name for VPC
  vpc_dns_zone = "${var.name}-ipsec-${var.region}.${var.google_dns_zone}"

  # Local DNS zone. This could also be the same as the public
  # which will enable setting up a split DNS of the public zone
  # for names to map to external and internal addresses.
  vpc_internal_dns_zones = ["local"]

  # Name of parent zone 'gcp.appbricks.cloud' to which the 
  # name server records of the 'vpc_dns_zone' will be added.
  dns_managed_zone_name = "${length(var.google_dns_managed_zone_name) == 0
    ? replace(var.google_dns_zone, ".", "-")
    : var.google_dns_managed_zone_name }"

  # Local file path to write SSH private key for bastion instance
  ssh_key_file_path = "${length(var.ssh_key_file_path) > 0 ? var.ssh_key_file_path : path.cwd}"

  # VPN
  vpn_users = "${var.vpn_users}"
  vpn_idle_action = "${var.vpn_idle_action}"

  vpn_type = "ipsec"

  # Whether to allow SSH access to bastion server
  bastion_allow_public_ssh = true

  bastion_host_name = "vpn"
  bastion_use_fqdn = true

  bastion_instance_type = "n1-standard-1"

  # Issue certificates from letsencrypt.org
  certify_bastion = true

  # Whether to deploy a jumpbox in the admin network. The
  # jumpbox will be deployed only if a local DNS zone is
  # provided and the DNS will be jumpbox.[first local zone].
  deploy_jumpbox = false
}

#
# Backend state
#
terraform {
  backend "gcs" {
  }
}

#
# Output
#
output "bastion_instance_id" {
  value = "${module.bootstrap.bastion_instance_id}"
}

output "bastion_fqdn" {
  value = "${module.bootstrap.bastion_fqdn}"
}

output "bastion_admin_password" {
  value = "${module.bootstrap.bastion_admin_password}"
}
