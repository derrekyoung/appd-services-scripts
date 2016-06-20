#!/bin/bash

. /home/ubuntu/AppDynamics/appd-env.sh

################################################
# Do not edit below this line

start()
{
	nohup sudo -H -u $APPD_RUNTIME_USER $JAVA_BIN -Xmx1024m $ $APP_AGENT_OPTIONS -jar $APPD_DB_AGENT_HOME/db-agent.jar  > /dev/null 2>&1 &
}

stop()
{
	nohup sudo -H -u $APPD_RUNTIME_USER ps -ef | grep "java.*db-agent" | awk '{print $2}' | xargs --no-run-if-empty kill -9 > /dev/null 2>&1 &
}

status ()
{
	STATUS=`ps -ef | grep db-agent.jar | grep -v grep`

	if [ $? -eq 0 ]; then
	   echo "AppDynamics Database Agent is running"
   else
	   echo "AppDynamics Database Agent is STOPPED"
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
