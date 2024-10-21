# Retrieve SSH private key from AWS Secrets Manager 
data "aws_secretsmanager_secret" "ssh_key" {
  name = "epa_key4"
}

data "aws_secretsmanager_secret_version" "ssh_key_version" {
  secret_id = data.aws_secretsmanager_secret.ssh_key.id
}

# Store the secret string (private key) in a local variable
locals {
  private_key_contents = data.aws_secretsmanager_secret_version.ssh_key_version.secret_string
}

# Read the external script file and inject the private key contents for install_ansible.sh
data "template_file" "ansible_setup" {
  template = file("scripts/install_ansible.sh")
  vars = {
    PRIVATE_KEY_CONTENTS = local.private_key_contents
  }
}

# Read the cloneGi.sh script template
data "template_file" "clone_gi_setup" {
  template = file("scripts/cloneGi.sh")
  vars = {
    PRIVATE_KEY_CONTENTS = local.private_key_contents
  }
}

resource "aws_instance" "EPA_ansible_server" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  security_groups             = [var.ec2_security_group_id]
  associate_public_ip_address = true

  # Pass the user data script that runs both install_ansible.sh and cloneGi.sh
  user_data = <<-EOF
    #!/bin/bash
    # Run install_ansible.sh
    ${data.template_file.ansible_setup.rendered}

    # Run cloneGi.sh after Ansible is installed
    ${data.template_file.clone_gi_setup.rendered}
  EOF

  tags = {
    Name = "Ansible-${var.naming_prefix}"
  }
}


resource "aws_instance" "public_app_instances" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  security_groups             = [var.ec2_security_group_id]
  associate_public_ip_address = true
  private_ip                  = var.app_private_ip

  tags = {
    Name = "App-${var.naming_prefix}"
  }
}