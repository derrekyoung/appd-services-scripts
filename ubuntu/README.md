# Setup
Modify the values in appd-env.sh as appropriate for your environment.

# Deploy/install a new service
`./ubuntu-deploy-service.sh appd-controller.init.d.sh`

## Deploy/install all services (Optional)
`./ubuntu-deploy-all-services.sh`
You'll need to comment in/out the appropriate services

# Service Usage

## Check service status
`service appd-controller status`

## Start service
`service appd-controller start`

## Stop service
`service appd-controller stop`

## Restart service
`service appd-controller restart`

## Check status for all services
``./AppDyanamics/status.sh`
You'll need to comment in/out the appropriate services
