#!/bin/bash
#chkconfig: 2345 40 90
#description: service script for AppDynamics EUM Server

APPD_RUNTIME_USER="ubuntu"
APPD_EUM_HOME="/opt/AppDynamics/EUM"



################################################################################
# Do not edit below this line
################################################################################

start() {
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	cd $APPD_EUM_HOME
	exec bin/eum.sh start
	cd $DIR
}

stop() {
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	cd $APPD_EUM_HOME
	exec bin/eum.sh stop
	cd $DIR
}

restart() {
	stop
	start
}

status() {
	STATUS=`ps -ef | grep -i "eum.sh" | grep -v grep`
	if [ $? -eq 0 ];then
		echo "AppDynamics EUM Server is Running"
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
