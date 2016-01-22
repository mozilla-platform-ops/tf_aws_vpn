resource "aws_vpc" "vpc" {
    cidr_block = "${var.cidr_block}"
    enable_dns_support = "${var.enable_dns_support}"
    enable_dns_hostnames = "${var.enable_dns_hostnames}"
    tags {
        Name = "${var.name}-vpc"
    }
}

resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${element(split(",", var.private_subnets), count.index)}"
    availability_zone = "${element(split(",", var.zones), count.index)}"
    count = "${length(compact(split(",", var.private_subnets)))}"
    tags {
        Name = "${format("%s-private-%d", var.name, count.index + 1)}"
    }
}

resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${element(split(",", var.public_subnets), count.index)}"
    availability_zone = "${element(split(",", var.zones), count.index)}"
    count = "${length(compact(split(",", var.public_subnets)))}"
    map_public_ip_on_launch = true
    tags {
        Name = "${format("%s-public-%d", var.name, count.index + 1)}"
    }
}

resource "aws_internet_gateway" "vpc-igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.name}-igw"
    }
}
resource "aws_route" "igw-route" {
    route_table_id = "${aws_vpc.vpc.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc-igw.id}"
}

resource "aws_vpn_gateway" "vpc-vgw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.name}-vgw"
    }
}
resource "aws_route" "vgw-route" {
    route_table_id = "${aws_vpc.vpc.main_route_table_id}"
    destination_cidr_block = "${var.vpn_dest_cidr_block}"
    gateway_id = "${aws_vpn_gateway.vpc-vgw.id}"
}

resource "aws_customer_gateway" "vpc-cgw" {
    bgp_asn = "${var.vpn_bgp_asn}"
    ip_address = "${var.vpn_ip_address}"
    type = "ipsec.1"
    tags {
        Name = "${var.name}-cgw"
    }
}

resource "aws_vpn_connection" "vpc-vpn" {
    vpn_gateway_id = "${aws_vpn_gateway.vpc-vgw.id}"
    customer_gateway_id = "${aws_customer_gateway.vpc-cgw.id}"
    type = "ipsec.1"
    static_routes_only = true
    tags {
        Name = "${var.name}-vpn"
    }
}
