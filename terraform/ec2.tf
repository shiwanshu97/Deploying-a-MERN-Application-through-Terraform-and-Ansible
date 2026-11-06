
# ==========================================
# DATA SOURCE - UBUNTU AMI
# ==========================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==========================================
# DATA SOURCE - AVAILABILITY ZONES
# ==========================================

data "aws_availability_zones" "available" {
  state = "available"
}

# ==========================================
# 1. CREATE VPC
# ==========================================

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# ==========================================
# 2. CREATE PUBLIC SUBNET
# ==========================================

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
    Role    = "public"
  }
}

# ==========================================
# 3. CREATE PRIVATE SUBNET
# ==========================================

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project_name}-private-subnet"
    Project = var.project_name
    Role    = "private"
  }
}

# ==========================================
# 4. CREATE INTERNET GATEWAY
# ==========================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# ==========================================
# 5. CREATE PUBLIC ROUTE TABLE
# ==========================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

# Public route to Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ==========================================
# 6. CREATE PRIVATE ROUTE TABLE
# ==========================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-private-rt"
    Project = var.project_name
  }
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ==========================================
# 7. WEB EC2 INSTANCE
# ==========================================

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  monitoring             = true
  ebs_optimized          = true

  # Use newly created public subnet
  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Public IP required for web application access
  associate_public_ip_address = true

  # Enforce IMDSv2 for better security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypted root EBS volume
  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "${var.project_name}-web"
    Project = var.project_name
    Role    = "web"
  }
}

# ==========================================
# 8. DATABASE EC2 INSTANCE
# ==========================================

resource "aws_instance" "database" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  monitoring             = true
  ebs_optimized          = true

  # Use newly created private subnet
  subnet_id = aws_subnet.private.id

  vpc_security_group_ids = [aws_security_group.database.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Database must not have a public IP
  associate_public_ip_address = false

  # Enforce IMDSv2 for better security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypted root EBS volume
  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "${var.project_name}-database"
    Project = var.project_name
    Role    = "database"
  }
}
