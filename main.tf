# --------------------------------------------------------------
# VPC creation
# --------------------------------------------------------------
resource "aws_vpc" "vpc-new" {
    cidr_block = var.cidr
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
  tags = {
    Name = var.project
  }
}
# --------------------------------------------------------------
# igw Creation
# --------------------------------------------------------------

resource "aws_internet_gateway" "igw" {

    vpc_id = aws_vpc.vpc-new.id
    tags = {
      "Name" = var.project
    }
}
# --------------------------------------------------------------
# subnet Public-1
# --------------------------------------------------------------

resource "aws_subnet" "public1" {

    vpc_id = aws_vpc.vpc-new.id
    cidr_block = cidrsubnet(var.cidr, var.subnets, 0)
    availability_zone = data.aws_availability_zones.az.names[0]
    map_public_ip_on_launch = true
tags = {
  "Name" = "${var.project}-public1"
} 
}
# --------------------------------------------------------------
# subnet Public-2
# --------------------------------------------------------------

resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.vpc-new.id
    cidr_block = cidrsubnet(var.cidr, var.subnets, 1)
    availability_zone = data.aws_availability_zones.az.names[1]
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project}-public2"
    }
}

# --------------------------------------------------------------
# subnet Public-3
# --------------------------------------------------------------

resource "aws_subnet" "public3" {
    vpc_id = aws_vpc.vpc-new.id
    cidr_block = cidrsubnet(var.cidr, var.subnets, 2)
    availability_zone = data.aws_availability_zones.az.names[2]
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project}-public3"
    }
}

# --------------------------------------------------------------
# subnet private-1
# --------------------------------------------------------------

resource "aws_subnet" "private1" {
    vpc_id = aws_vpc.vpc-new.id
    cidr_block = cidrsubnet(var.cidr, var.subnets, 3)
    availability_zone = data.aws_availability_zones.az.names[0]
    map_public_ip_on_launch = false
    tags = {
        Name = "${var.project}-private1"
    }
}

# --------------------------------------------------------------
# subnet private-2
# --------------------------------------------------------------

resource "aws_subnet" "private2" {
    vpc_id = aws_vpc.vpc-new.id
    cidr_block = cidrsubnet(var.cidr, var.subnets, 4)
    availability_zone = data.aws_availability_zones.az.names[1]
    map_public_ip_on_launch = false
    tags = {
        Name = "${var.project}-private2"
    }
}

# --------------------------------------------------------------
# subnet private-3
# --------------------------------------------------------------

resource "aws_subnet" "private3" {
    vpc_id = aws_vpc.vpc-new.id
    cidr_block = cidrsubnet(var.cidr, var.subnets, 5)
    availability_zone = data.aws_availability_zones.az.names[2]
    map_public_ip_on_launch = false
    tags = {
        Name = "${var.project}-private3"
    }
}

# --------------------------------------------------------------
# Creat route table 
# --------------------------------------------------------------

resource "aws_route_table" "public" {
    
    
  vpc_id = aws_vpc.vpc-new.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    
  tags = {
    Name    = "${var.project}-public"
    project = var.project
  }
}

# --------------------------------------------------------------
# association between public1 to public rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "public1" {

     subnet_id      = aws_subnet.public1.id
     route_table_id = aws_route_table.public.id
  
}
# --------------------------------------------------------------
# association between public2 to public rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "public2" {

     subnet_id      = aws_subnet.public2.id
     route_table_id = aws_route_table.public.id
  
}

# --------------------------------------------------------------
# association between public3 to public rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "public3" {

     subnet_id      = aws_subnet.public3.id
     route_table_id = aws_route_table.public.id
  
}

# --------------------------------------------------------------
# Elastic Ip Creation
# --------------------------------------------------------------

resource "aws_eip" "nat" {

  vpc      = true
  tags = {
    Name    = "${var.project}-nat-gw"
    project = var.project
  }
}
# --------------------------------------------------------------
# Create a nat gateway on public -1
# --------------------------------------------------------------

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "gw-NAT"
  }

}


# --------------------------------------------------------------
# Creating Private Routetable
# --------------------------------------------------------------

resource "aws_route_table" "private" {
    
  vpc_id = aws_vpc.vpc-new.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project}-private"
    project = var.project
  }
}
# --------------------------------------------------------------
# association between private1 to private rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

# --------------------------------------------------------------
# association between private2 to private rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}


# --------------------------------------------------------------
# association between private3 to private rtb
# --------------------------------------------------------------

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}


# -----------------------------------------------------------
# KeyPair Creation
# -----------------------------------------------------------

resource "aws_key_pair" "mykey" {
    
  key_name   = var.project
  public_key = file("vyjith.pub")
  tags = {
    Name = var.project
    project = var.project
  }
    
}
# -----------------------------------------------------------
# Security Group For bastion Access
# -----------------------------------------------------------

resource "aws_security_group" "bastion" {
    
  name        = "bastion"
  description = "allows 22 conntection"
  vpc_id      = aws_vpc.vpc-new.id

  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

   tags = {
    Name = "${var.project}-bastion"
    project = var.project
  }
    
}

# -----------------------------------------------------------
# Security Group For Frontend Access
# -----------------------------------------------------------

resource "aws_security_group" "frontend" {
    
  name        = "frontend"
  description = "allows 80,443,22 conntection"
  vpc_id      = aws_vpc.vpc-new.id

  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.bastion.id ]
    
  }
  
  ingress {
    description      = ""
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
    
  ingress {
    description      = ""
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

   tags = {
    Name = "${var.project}-frontend"
    project = var.project
  }
    
}

# -----------------------------------------------------------
# Security Group For Backend Access
# -----------------------------------------------------------

resource "aws_security_group" "backend" {
    
  name        = "backend"
  description = "allows 3306,22 conntection"
  vpc_id      = aws_vpc.vpc-new.id

  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.bastion.id ]
    
  }
  
  ingress {
    description      = ""
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [ aws_security_group.frontend.id ]
  }
    
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

   tags = {
    Name = "${var.project}-backend"
    project = var.project
  }
    
}
# -----------------------------------------------------------
# Ec2 For bastion
# -----------------------------------------------------------

resource "aws_instance"  "bastion" {
    
  ami                     =    "ami-04893cdb768d0f9ee"
  instance_type           =    "t2.micro"
  key_name                =    aws_key_pair.mykey.id
  vpc_security_group_ids  =    [  aws_security_group.bastion.id ]
  subnet_id               =    aws_subnet.public1.id 
  tags = {
    Name = "${var.project}-bastion"
    project = var.project
  } 
}


# -----------------------------------------------------------
# Ec2 For Frontend
# -----------------------------------------------------------

resource "aws_instance"  "frontend" {
    
  ami                     =    "ami-04893cdb768d0f9ee"
  instance_type           =    "t2.micro"
  key_name                =    aws_key_pair.mykey.id
  vpc_security_group_ids  =    [  aws_security_group.frontend.id ]
  subnet_id               =    aws_subnet.public1.id 
  tags = {
    Name = "${var.project}-frontend"
    project = var.project
  } 
}

# -----------------------------------------------------------
# Ec2 For backend
# -----------------------------------------------------------

resource "aws_instance"  "backend" {
    
  ami                     =    "ami-04893cdb768d0f9ee"
  instance_type           =    "t2.micro"
  key_name                =    aws_key_pair.mykey.id
  vpc_security_group_ids  =    [  aws_security_group.backend.id ]
  subnet_id               =    aws_subnet.private1.id 
  tags = {
    Name = "${var.project}-backend"
    project = var.project
  } 
}