#!/bin/sh
#--------------------------------------------------------------------------------------------------
# Linux service script for the AppDynamics Controller
#
#	Notes:
#		This service script will run the AppDynamics in a dedicated user account.
#
#		Edit all path names or agent options to suit your particular installation.
#
#		Copy this file to the /etc/init.d directory as 'appd-controller'
#			Remove the 'init.d.sh' extension
#
#		There may be differences for CentOS/RedHat vs Ubuntu/Debian - adjust accordingly.
#
# chkconfig: 2345 60 25
# description: AppDynamics Controller
#--------------------------------------------------------------------------------------------------

# Edit the following parameters to suit your environment
CONTROLLER_HOME="/opt/AppDynamics/Controller"
APPD_RUNTIME_USER="root"


################################################
# Do not edit below this line

start()
{
	/bin/su $APPD_RUNTIME_USER $CONTROLLER_HOME/bin/controller.sh start
}

stop ()
{
	/bin/su $APPD_RUNTIME_USER $CONTROLLER_HOME/bin/controller.sh stop
}

status ()
{
	STATUS=`ps -ef | grep glassfish |grep -v grep`

	if [ $? -eq 0 ];then
		echo "AppDynamics Controller app server is running"
	else
		echo "AppDynamics Controller app server is STOPPED"
	fi

	STATUS=`ps -ef|grep "Controller/db/bin/mysqld" |grep -v grep`
	if [ $? -eq 0 ];then
		echo "AppDynamics Controller database is running"
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
