#!/bin/bash

./ubuntu-deploy-service.sh appd-controller.init.d.sh
./ubuntu-deploy-service.sh appd-controller-events-service.init.d.sh
./ubuntu-deploy-service.sh appd-db-agent.init.d.sh
./ubuntu-deploy-service.sh appd-machine-agent.init.d.sh
