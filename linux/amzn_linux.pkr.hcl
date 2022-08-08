packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "amazon-ebs" "this" {
  ami_name      = "amzn-linux-silver-{{timestamp}}"
  ami_users     = var.share_with
  instance_type = var.inst_type
  region        = var.region
  #security_group_id           = "sg-0f4abe34913599a2e" #Use this if you don't want to use the Packer created temp SG
  #iam_instance_profile        = var.iam_profile
  associate_public_ip_address = true
  ssh_username = var.ssh_user

  aws_polling {
    delay_seconds = 30
    max_attempts  = 200
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = var.vol_size
    volume_type           = var.vol_type
    delete_on_termination = true
  }

#   subnet_id = "subnet-d9205ebc" #uncomment to use and comment the filter below
    subnet_filter {
      filters = {
            "tag:Name": "public"
      }
      most_free = true
      random    = false
    }

  source_ami = var.image_id #uncomment to use and comment the filter below
  # source_ami_filter {
  #   filters = {
  #     name                = "amzn2-goldimage-*"
  #     root-device-type    = "ebs"
  #     virtualization-type = "hvm"
  #   }
  #   most_recent = true
  #   owners      = ["1234567890"] #accountID sharing the GI
  # }

  tags = {
    Release       = "Latest"
    Name          = "amzn-linux-si-{{timestamp}}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }
}

build {
  sources = [
    "source.amazon-ebs.this"
  ]

  provisioner "shell-local" {
    inline = ["sleep 60"]
  }

  provisioner "shell" {
    environment_vars = [
      "FOO=BAR",
    ]
    inline = [
      "sudo yum update -y",
      "sudo yum install wget -y",
      "sudo yum install -y yum-utils",
      "sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2",
      "sleep 5",
      "sudo yum install -y httpd",
      "sleep 5",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo amazon-linux-extras install ansible2",
      "sleep 5",
      "echo foo equals $FOO"
    ]
  }
  provisioner "ansible-local" {
    playbook_file = "./scripts/playbook.yml"
  }

  provisioner "shell" {
    script = "scripts/install_bins.sh"
  }


  provisioner "breakpoint" {
    disable = true
  }

  post-processor "checksum" {
    checksum_types = ["sha1", "sha256"]
    output         = "packer_{{.BuildName}}_{{.ChecksumType}}.checksum"
  }

}