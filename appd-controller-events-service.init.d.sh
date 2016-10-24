#!/bin/bash

APPD_RUNTIME_USER="ubuntu"
APPD_CONTROLLER_HOME="/opt/AppDynamics/Controller"



################################################################################
# Do not edit below this line
################################################################################

start() {
	removePID
	nohup sudo -H -u $APPD_RUNTIME_USER $APPD_CONTROLLER_HOME/bin/controller.sh start-events-service > /dev/null 2>&1 &
}

stop() {
	nohup sudo -H -u $APPD_RUNTIME_USER $APPD_CONTROLLER_HOME/bin/controller.sh stop-events-service > /dev/null 2>&1 &
	removePID
}

status () {
	STATUS=`ps -ef | grep -i controller/events_service |grep -v grep`
    if [ $? -eq 0 ];then
        echo "AppDynamics Controller embedded Events Service is Running"
    else
		echo "AppDynamics Controller embedded Events Service is STOPPED"
    fi
}

removePID() {
	nohup sudo -H -u $APPD_RUNTIME_USER rm -f $APPD_CONTROLLER_HOME/events_service/events-service-api-store.id > /dev/null 2>&1 &
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
