#!/bin/sh
#--------------------------------------------------------------------------------------------------
# Master service script for starting any/all on-premise AppDynamics components
#
#	Notes:
#		When installing this file in the /etc/init.d directory,
#			remove the 'init.d.sh' extension
#
#		Comment out those services which do not apply to your installation
#
# chkconfig: 2345 60 25
# description: AppDynamics Master Service
#--------------------------------------------------------------------------------------------------

case "$1" in
	start)
		service appd-controller start
		service appd-events-service start
		service appd-eum start
		service appd-machine-agent start
		service appd-db-agent start
	;;

	stop)
		service appd-db-agent stop
		service appd-machine-agent stop
		service appd-eum stop
		#service appd-events-service stop - Events service will be automatically stopped by the controller.
		service appd-controller stop
	;;

	restart)
		$0 stop
		$0 start
	;;

	status)
		service appd-controller status
		service appd-events-service status
		service appd-eum status
		service appd-machine-agent status
		service appd-db-agent status
	;;

	*)
		echo "Usage: $0 {start|stop|restart|status}"
		exit 1
esac
