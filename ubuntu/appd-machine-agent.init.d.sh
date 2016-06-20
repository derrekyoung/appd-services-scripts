#!/bin/bash

. /home/ubuntu/AppDynamics/appd-env.sh

################################################
# Do not edit below this line

APPD_MACHINE_AGENT_ANALYTICS_URL="http://localhost:9091/ping"

start()
{
	removePID
	nohup sudo -H -u $APPD_RUNTIME_USER $JAVA_BIN $APPD_AGENT_OPTIONS -Xmx32m -jar $APPD_MACHINE_AGENT_HOME/machineagent.jar > /dev/null 2>&1 &
}

stop()
{
	nohup sudo -H -u $APPD_RUNTIME_USER ps -ef | grep "java.*machineagent" | awk '{print $2}' | xargs --no-run-if-empty kill -9 > /dev/null 2>&1 &
	removePID
}

status ()
{
	STATUS=`ps -ef | grep -i machineagent.jar | grep -v grep`
	if [ $? -eq 0 ]; then
	   echo "AppDynamics Machine Agent is running"
   else
	   echo "AppDynamics Machine Agent is STOPPED"
   fi

   # Check for running Analytics agent embedded into Machine Agent at localhost:9091/ping --> pong
   check_analytics_agent
}

check_analytics_agent(){
    local url=$APPD_MACHINE_AGENT_ANALYTICS_URL
    local expectedContent="HTTP/1.1 200 OK"

	curl -s --head $url | head -n 1 | grep "$expectedContent" > /dev/null
	if [ $? -gt 0 ] ; then
		echo "AppDynamics Machine Agent - Analytics Agent is STOPPED. (OPTIONAL: only necessary if using Analytics)"
        exit 1
	else
		echo "AppDynamics Machine Agent - Analytics Agent is running"
    fi
}

removePID() {
	nohup sudo -H -u $APPD_RUNTIME_USER rm -f $APPD_MACHINE_AGENT_HOME/monitors/analytics-agent/analytics-agent.id > /dev/null 2>&1 &
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
