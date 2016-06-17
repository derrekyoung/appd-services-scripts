#!/bin/bash

. /home/ubuntu/AppDynamics/appd-env.sh

service appd-controller status
#service appd-controller-events-service status
#service appd-events-service status
#service appd-eum-server status
service appd-machine-agent status
service appd-db-agent status
