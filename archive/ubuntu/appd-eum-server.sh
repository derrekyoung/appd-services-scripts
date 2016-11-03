#!/bin/bash

source ./appd-environment-variables.sh
if [ ! -f "./appd-environment-variables.sh" ]; then
	echo "ERROR: File not found, appd-environment-variables.sh. This file must be in the same directory as this script."
	exit 1
fi

################################################
# Do not edit below this line

start() {
	cd $APPD_EUM_HOME
	exec bin/eum.sh start
}

stop() {
	cd $APPD_EUM_HOME
	exec bin/eum.sh stop
}

restart() {
	stop
	start
}

status() {
	STATUS=`ps -ef | grep -i "eum.sh" |grep -v grep`
	if [ $? -eq 0 ];then
		echo "AppDynamics EUM Server is running"
	else
		echo "AppDynamics EUM Server is STOPPED"
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
		restart
	;;

	status)
		status
	;;

	*)
		echo "Usage: $0 {start|stop|restart|status}"
		exit 1
esac
