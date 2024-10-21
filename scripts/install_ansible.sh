#!/bin/bash

LOG_FILE="/var/log/script_execution.log"

# Function to check the exit status of the last executed command
check_exit_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed." | tee -a $LOG_FILE
        exit 1
    else
        echo "$1 succeeded." | tee -a $LOG_FILE
    fi
}

# Clear the log file at the beginning of the script
> $LOG_FILE

# Update the package list
echo "Running apt-get update..." | tee -a $LOG_FILE
sudo apt-get update -y
check_exit_status "apt-get update"

# Upgrade packages
echo "Running apt-get upgrade..." | tee -a $LOG_FILE
sudo apt-get upgrade -y
check_exit_status "apt-get upgrade"

# Install required dependencies
echo "Installing software-properties-common..." | tee -a $LOG_FILE
sudo apt-get install -y software-properties-common
check_exit_status "Install software-properties-common"

# Add Ansible PPA and install Ansible
echo "Adding Ansible PPA..." | tee -a $LOG_FILE
sudo add-apt-repository --yes --update ppa:ansible/ansible
check_exit_status "Add Ansible PPA"

echo "Installing Ansible..." | tee -a $LOG_FILE
sudo apt-get install -y ansible
check_exit_status "Install Ansible"

# Create necessary directories
echo "Creating /media/.ssh directory..." | tee -a $LOG_FILE
sudo mkdir -p /media/.ssh
check_exit_status "Create /media/.ssh directory"

# Write private key contents to file
echo "Writing private key to /media/.ssh/EPA-test2.pem..." | tee -a $LOG_FILE
echo -e "${PRIVATE_KEY_CONTENTS}" > /media/.ssh/EPA-test2.pem
check_exit_status "Write private key"

# Convert line endings (^M) in the private key file
echo "Fixing line endings in /media/.ssh/EPA-test2.pem..." | tee -a $LOG_FILE
sed -i 's/\r$//' /media/.ssh/EPA-test2.pem
check_exit_status "Fix line endings"

# Set correct permissions for the private key
echo "Setting permissions for /media/.ssh/EPA-test2.pem..." | tee -a $LOG_FILE
sudo chmod 600 /media/.ssh/EPA-test2.pem
check_exit_status "Set private key permissions"

# Create Ansible configuration directory and files
echo "Creating Ansible directories and configuration files..." | tee -a $LOG_FILE
sudo mkdir -p /media/ansible
check_exit_status "Create /media/ansible directory"

echo "Writing ansible.cfg..." | tee -a $LOG_FILE
sudo tee /media/ansible/ansible.cfg > /dev/null <<EOF
[defaults]
inventory = /media/ansible/inventory
private_key_file = /media/.ssh/EPA-test2.pem
host_key_checking = False
EOF
check_exit_status "Create ansible.cfg"

# Define inventory file for Ansible
echo "Writing inventory file..." | tee -a $LOG_FILE
sudo tee /media/ansible/inventory > /dev/null <<EOF
[example]
10.0.1.10
EOF
check_exit_status "Create inventory file"

# Create the NGINX Ansible playbook
echo "Creating Ansible playbook for NGINX..." | tee -a $LOG_FILE
sudo tee /media/ansible/nginx.yaml > /dev/null <<EOF
- name: Install and start NGINX on remote servers
  hosts: all
  become: yes
  tasks:
    - name: Install NGINX
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Start NGINX service
      service:
        name: nginx
        state: started
        enabled: yes
EOF
check_exit_status "Create NGINX Ansible playbook"

# Run the Ansible playbook
echo "Running the Ansible playbook..." | tee -a $LOG_FILE
cd /media/ansible && sudo ansible-playbook -i /media/ansible/inventory -u ubuntu /media/ansible/nginx.yaml
check_exit_status "Run Ansible playbook"




#  cat /var/log/script_execution.log - Check on status of running programme 