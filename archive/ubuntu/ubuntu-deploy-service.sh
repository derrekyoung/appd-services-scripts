#!/bin/bash

# Check for parameters
if [ -z "$1" ];then
    echo "Service script file is required as a parameter"
    echo "Usage: ./ubuntu-deploy-service.sh appd-controller.init.d.sh"
    exit 1
fi

# Copy over the AppD environment variables
echo "Copying over the environment variables"
sudo cp ./appd-environment-variables.sh /etc/init.d/

# Trim parameter file extensions
script=$1
service=${script%.init.d.sh}

echo "Deploying ./$script to /etc/init.d/$service"

sudo cp ./$script /etc/init.d/$service

sudo chmod a+rx /etc/init.d/$service
sudo chown root:root /etc/init.d/$service
sudo initctl reload-configuration

sudo update-rc.d $service defaults
sudo update-rc.d $service enable

echo "Service enabled: $service"

# Print out the usage
service $service
