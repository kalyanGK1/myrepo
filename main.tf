resource "aws_vpc" "vpc1"{
  cidr_block="${var.vpc_cidr}"
  enable_dns_hostnames=true
  instance_tenancy="default"
  tags={
   Name="${var.vpc_name}"
   env="${var.env}"
  }
}
resource "aws_subnet" "subnets1"{
  count="${length(var.subnets1_cidr)}"
  vpc_id="${aws_vpc.vpc1.id}"
  availability_zone="${element(var.azs1,count.index)}"
  map_public_ip_on_launch=true
  cidr_block="${element(var.subnets1_cidr,count.index)}"
  tags={
   Name="public-sub-${count.index+1}"
   env="${var.env}"
  }
}
resource "aws_subnet" "subnets2"{
  count="${length(var.subnets2_cidr)}"
  vpc_id="${aws_vpc.vpc1.id}"
  availability_zone="${element(var.azs2,count.index)}"
  cidr_block="${element(var.subnets2_cidr,count.index)}"
  tags={
   Name="private-sub-${count.index+1}"
   env="${var.env}"
  }
}
resource "aws_internet_gateway" "igw1"{
  vpc_id="${aws_vpc.vpc1.id}"
  tags={
   Name="${var.igw_name}"
   env="${var.env}"
  }
}
resource "aws_route_table" "rt1"{
  vpc_id="${aws_vpc.vpc1.id}"
  tags={
   Name="${var.rt1_name}"
   env="${var.env}"
  }
  
  route {
    cidr_block="0.0.0.0/0"
	gateway_id="${aws_internet_gateway.igw1.id}"
  }
}
resource "aws_route_table" "rt2"{
  vpc_id="${aws_vpc.vpc1.id}"
  tags={
   Name="${var.rt2_name}"
   env="${var.env}"
  }
  
  route {
    cidr_block="0.0.0.0/0"
	gateway_id="${aws_nat_gateway.nat1.id}"
  }
}
resource "aws_eip" "eip1"{
  vpc=true
  tags={
   Name="${var.eip_name}"
   env="${var.env}"
  }
}
resource "aws_nat_gateway" "nat1"{
  allocation_id="${aws_eip.eip1.id}"
  subnet_id="${aws_subnet.subnets1[0].id}"
  tags={
   Name="${var.nat_name}"
   env="${var.env}"
  }
}    
resource "aws_route_table_association" "rt1ass"{
  count="${length(var.subnets1_cidr)}"
  route_table_id="${aws_route_table.rt1.id}"
  subnet_id="${element(aws_subnet.subnets1.*.id,count.index)}"
}
resource "aws_route_table_association" "rt2ass"{
  count="${length(var.subnets2_cidr)}"
  route_table_id="${aws_route_table.rt2.id}"
  subnet_id="${element(aws_subnet.subnets2.*.id,count.index)}"
}
resource "aws_security_group" "sg1"{
  name="prod-sg"
  vpc_id="${aws_vpc.vpc1.id}"
  tags={
   Name="${var.sg_name}"
   env="${var.env}"
  }
 ingress {
  from_port=22
  to_port=22
  protocol="tcp"
  cidr_blocks=["0.0.0.0/0"]
 }
 ingress {
  from_port=80
  to_port=80
  protocol="tcp"
  cidr_blocks=["0.0.0.0/0"]
 }
 egress {
  from_port=0
  to_port=0
  protocol="-1"
  cidr_blocks=["0.0.0.0/0"]
 }
} 
resource "aws_instance" "instance1"{
  count="${length(var.subnets1_cidr)}"
  ami="${var.ami}"
  instance_type="${var.instance_type}"
  key_name="${var.key_name}"
  subnet_id="${element(aws_subnet.subnets1.*.id,count.index)}" 
  security_groups=["${aws_security_group.sg1.id}"]
  user_data="${file("file.sh")}"
  tags={
   Name="instance-${count.index+1}"
   env="${var.env}"
  }
}
resource "aws_instance" "instance2"{
  ami="${var.ami}"
  instance_type="${var.instance_type}"
  key_name="${var.key_name}"
  subnet_id="${aws_subnet.subnets2[0].id}" 
  security_groups=["${aws_security_group.sg1.id}"]
  tags={
   Name="${var.instance_name}"
   env="${var.env}"
  }
}







  
  
  
