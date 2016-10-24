#!/bin/bash
#chkconfig: 2345 20 80
#description: service script for AppDynamics Controller

APPD_RUNTIME_USER="ubuntu"
APPD_CONTROLLER_HOME="/opt/AppDynamics/Controller"



################################################################################
# Do not edit below this line
################################################################################

start() {
	nohup sudo -H -u $APPD_RUNTIME_USER $APPD_CONTROLLER_HOME/bin/controller.sh start > /dev/null 2>&1 &
	nohup sudo -H -u $APPD_RUNTIME_USER $APPD_CONTROLLER_HOME/bin/controller.sh start-events-service > /dev/null 2>&1 &
}

stop() {
	nohup sudo -H -u $APPD_RUNTIME_USER $APPD_CONTROLLER_HOME/bin/controller.sh stop > /dev/null 2>&1 &
	nohup sudo -H -u $APPD_RUNTIME_USER $APPD_CONTROLLER_HOME/bin/controller.sh stop-events-service > /dev/null 2>&1 &
}

status () {
	STATUS=`ps -ef | grep -i glassfish |grep -v grep`
	if [ $? -eq 0 ]; then
		echo "AppDynamics Controller app server is Running"
	else
		echo "AppDynamics Controller app server is STOPPED"
	fi

	STATUS=`ps -ef|grep -i "db/bin/mysqld" |grep -v grep`
	if [ $? -eq 0 ]; then
		echo "AppDynamics Controller database is Running"
	else
		echo "AppDynamics Controller database is STOPPED"
	fi
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	status)
		status
		;;
	*)
		echo $"Usage: $0 {start|stop|restart|status}"
		exit 1
		;;
esac
