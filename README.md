Terraform AWS VPN module
========================

A Terraform module (or standalone) to create a VPC and VPN in AWS.

**NB**: AWS will provide a **random** /30 IPv4 subnet in RFC-1918 space for the ipsec tunnel.
If you have multiple tunnels (to other VPCs) there is **no** guarantee that they won't use a /30
already in use (by you). If you find that you have an address conflict, you will need to destroy
the VPN connection and re-create it (e.g. `terraform destroy -target=aws_vpn_connection`)

Input Variables
---------------
- `name` - Name of the VPC (will be used in tags)
- `cidr_block` - CIDR block for the VPC
- `public_subnets` - Comma separated list of public subnet CIDR blocks
- `private_subnets` - Comma separated list of private subnet CIDR blocks
- `zones` - Comma separated lists of AZs in which to distribute subnets
- `enable_dns_hostnames` - Enable DNS hostnames in the VPC (default false)
- `enable_dns_support` - Enable DNS support in the VPC (default true)
- `vpn_bgp_asn` -  BPG ASN of the customer gateway for a dynamically routed VPN connection.
- `vpn_ip_address` - IP address of the customer gateway's external interface
- `vpn_dest_cidr_block` - Internal CIDR block to advertise over the VPN to the VPC

One should keep the `public_subnets`, `private_subnets`, and
`zones` lists the same length.

Modules Usage
-------------

```js
module "vpc" {
  source = "github.com/mozilla-platform-ops/tf_aws_vpn"

  name = "my-vpc"

  cidr_block = "10.0.0.0/16"
  private_subnets = "10.0.1.0/24,10.0.2.0/24,10.0.3.0/24"
  zones = "us-west-2a,us-west-2b,us-west-2c"

  vpn_bgp_asn = "65000"
  vpn_ip_address = "1.2.3.4"
  vpn_dest_cidr_block = "192.168.1.0/24"
}
```

Standalone Usage
----------------
Rename the `provider.tf-dist` and `terraform.tfvars-dist` files to remove the `-dist` suffix, and then
customize `terraform.tfvars`.


Outputs
-------
- `VPC` - VPC ID
- `Private subnets` - comma separated list of private subnet ids
- `Public subnets` - comma separated list of public subnet ids
- `Internet gateway` - Internet gateway ID
- `Customer gateway` - Customer gateway ID
- `VPN gateway` - VPN gateway ID
- `VPN gateway config` - XML configuration for your hardware VPN


Authors
=======

Created by [Kendall Libby](https://github.com/klibby), based on [tf_aws_vpc](https://github.com/terraform-community-modules/tf_aws_vpc) by [Casey Ransom](https://github.com/cransom) and [Paul Hinze](https://github.com/phinze)

License
=======
Mozilla Public License, version 2.0. See LICENSE for full details.

