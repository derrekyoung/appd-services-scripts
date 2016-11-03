#!/bin/bash
#--------------------------------------------------------------------------------------------------
# Script for starting or stopping the AppDynamics Machine Agent
#
#	Notes:
#		Edit all path names or agent options to suit your particular installation.
#
#		There may be differences in service scripts for CentOS/RedHat vs Ubuntu/Debian -
#			adjust scripts accordingly
#
#--------------------------------------------------------------------------------------------------

# Edit the following parameters to suit your environment
JAVA_BIN="/usr/bin/java"
MACHINE_AGENT_HOME="/opt/AppDynamics/MachineAgent"

# Optional command line machine agent properties
AGENT_OPTIONS=""

# == Controller Connection Properties
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.hostName=[controller-hostname]
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.port=[controller-port]

# == Machine Agent Identification Properties
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.applicationName=<application-name>"
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.tierName=<tiername>"
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.nodeName=<nodename>"

# == Runtime Properties
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.logging.dir="

# == Jetty Server Listener Properties
#AGENT_OPTIONS="$AGENT_OPTIONS -Dmetric.http.listener.port=<port>"
#AGENT_OPTIONS="$AGENT_OPTIONS -Dmetric.http.listener=true | false

################################################
# Do not edit below this line
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

MACHINE_AGENT_JAR="$MACHINE_AGENT_HOME/machineagent.jar"

start()
{
	echo "AppDynamics Machine Agent - Starting"

    nohup $JAVA_BIN $AGENT_OPTIONS -Xmx32m -jar $MACHINE_AGENT_JAR > /dev/null 2>&1 &

	echo "AppDynamics Machine Agent - Started"
}

stop()
{
	echo "AppDynamics Machine Agent - Stopping"

	# For CentOS and RedHat Linux
#	ps -ef | grep "java.*machineagent" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

# For Ubuntu and Debian Linux
    ps -opid,cmd | egrep "java.*machineagent" | awk '{print $1}' | xargs --no-run-if-empty kill -9

# For Unix
#	TBD

	echo "AppDynamics Machine Agent - Stopped"
}

status()
{
	STATUS=`ps -ef | grep machineagent.jar | grep -v grep`

	if [ $? -eq 0 ]
	   then
		   echo "AppDynamics Machine Agent is running"
	   else
		   echo "AppDynamics Machine Agent is NOT running"
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
