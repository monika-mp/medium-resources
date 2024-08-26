#!/bin/bash

# Script: GCP Metadata Puller
# Author: Monika Mrozek-Pasieka
# Description: This script pulls metadata from Google Cloud Platform (GCP) to configure the instance automatically.
# 
# For detailed information and a step-by-step guide on how this script works, check out my article on Medium:
# Google Compute metadata - Efficient Usage in Shell Scripts
# https://medium.com/@monika.mp/google-compute-metadata-efficient-usage-in-shell-scripts-fa04339e9b38
#


# [Script Starts Here]

# Name of the script
script_name="script.sh"

base_package="sysstat net-tools"

web_packages_apt="apache2 php-common libapache2-mod-php php-cli php"
web_packages_yum="httpd php-common php php-cli policycoreutils-python-utils"

dev_packages_apt="apache2 php-common libapache2-mod-php php-cli python3 git php"
dev_packages_yum="httpd php-common php php-cli python3 git policycoreutils-python-utils"

# Function to check if the script is running
is_script_running() {
    echo "Checking if script is already running."
    if [ "$(pgrep -f "$script_name" -c)" -gt "2" ]> /dev/null 2>&1
    then
        echo "The script $script_name is already running."
        exit 1
    else
        echo "The script $script_name is not running. Starting execution."
    fi
}

# Determine operating system
get_package_manager() {
if which apt > /dev/null 2>&1; then
  package_manager='apt'

elif which yum > /dev/null 2>&1; then
  package_manager='yum'
fi
}

# Function to install packages
install_packages() {
    packages=$1

    if [ "$package_manager" = "apt" ]; then
        sudo apt update
        sudo apt install -y $packages
    elif [ "$package_manager" = "yum" ]; then
        sudo yum install -y $packages
    fi
}

# Retrieve metadata
get_metadata()
{
    KEY=$1
    curl -s -H "Metadata-Flavor: Google" "http://metadata/computeMetadata/v1/$KEY"
}

# Check instance and project metadata

determineVariables() {

instance_base_package=$(get_metadata "instance/attributes/base-package")
project_base_package=$(get_metadata "project/attributes/base-package")

instance_web=$(get_metadata "instance/attributes/web")
project_web=$(get_metadata "project/attributes/web")

instance_dev=$(get_metadata "instance/attributes/dev")
project_dev=$(get_metadata "project/attributes/dev")


install_base_package=false
install_web=false
install_dev=false


for var in base_package web dev; do

  instance_var="instance_$var"
  install_var="install_${var}"
  project_var="project_$var"


  if [ "${!instance_var}" = "true" ] || [ "${!instance_var}" = "yes" ]; then
        eval $instance_var=true
  elif [ "${!instance_var}" = "false" ] || [ "${!instance_var}" = "no" ];then
        eval $instance_var=false
  elif echo "${!instance_var}"|grep -q "404" ; then
        eval $instance_var=unset
  fi

  if [ "${!instance_var}" = "true" ]; then
      eval $install_var=true

  elif [ "${!instance_var}" = "false" ]; then
      eval $install_var=false

  elif [ "${!instance_var}" = "unset" ]; then
      eval $install_var=false

      if [ "${!project_var}" = "true" ] || [ "${!project_var}" = "yes" ]; then
        eval $install_var=true
      fi
  fi
  
done
}


# Check if the script is already running
is_script_running

# Checkign distribution:
get_package_manager

# Set variables
determineVariables


# Install base packages if applicable
if [ "$install_base_package" = "true" ]; then
    echo "Installing base packages..."
    install_packages $base_package
fi

if [ "$install_web" = "true" ]; then
   echo "Installing web packages..."
   web_packages="web_packages_$package_manager"
   install_packages "${!web_packages}"

   curl -o /var/www/html/index.php https://raw.githubusercontent.com/monika-mp/medium-resources/main/gcp-metadata-exercise/index.php
   systemctl enable apache2 || systemctl enable httpd
   systemctl restart apache2 || systemctl start httpd


fi

if [ "$install_dev" = "true" ]; then
   echo "Installing dev packages..."
   dev_packages="dev_packages_$package_manager"
   install_packages "${!dev_packages}"

   curl -o /var/www/html/index.php https://raw.githubusercontent.com/monika-mp/medium-resources/main/gcp-metadata-exercise/index.php
   sed -i 's/Hello! This is prod server :)/Hello! This is dev server :)/g' /var/www/html/index.php
   systemctl enable apache2 || systemctl enable httpd
   systemctl restart apache2 || systemctl start httpd
fi


if [ "$package_manager" = "yum" ]; then
   echo Setting up contex for index file
   semanage fcontext -a -t httpd_sys_content_t /var/www/html/index.php
   restorecon -Rv /var/www/html/index.php
   setsebool -P httpd_can_network_connect on
fi
   

logger "Example Startup script execution completed"