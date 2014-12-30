#!/bin/sh

# This script is run by the Vagrant provisioner to configure the newly
# booted VM.  It should be run as root.

# The APT_PACKAGES will be installed via 'apt-get install'.
APT_PACKAGES="git  nodejs  nodejs-legacy  npm mongodb"

# the NPM_PACKAGES will be install systemwide via 'npm install -g'
NPM_PACKAGES="coffee-script" 

#-------------------------------------------------------------------

echo Provisioning...
  date

echo "Updating APT source catalogs"
  apt-get -qq -y update

echo "Installing APT packages"
  apt-get -qq -y install $APT_PACKAGES

echo "Installing NPM packages"
  npm --loglevel error install -g $NPM_PACKAGES

echo "Updating NPM globals"
  npm --loglevel error update -g

#echo "Running user-level provisioning script"
  #su vagrant -c ". ~/l2capp/provision_as_vagrant.sh"
  #su ubuntu -c ". /vagrant/provison_as_vagrant.sh"


echo "Finished provisioning."
  date

