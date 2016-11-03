#!/bin/bash
#--------------------------------------------------------------------------------------------------
# Script for starting or stopping the AppDynamics Database Agent
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
DB_AGENT_HOME="/opt/AppDynamics/DBAgent"

# OPTIONAL
UNIQUE_HOST_ID="$HOSTNAME" #Useful if running multiple DB Mon agents on 1 server
DB_AGENT_NAME="$HOSTNAME" #Useful if sending multiple DB Mon agents in a Controller



################################################
# Do not edit below this line
DB_AGENT_JAR="$DB_AGENT_HOME/db-agent.jar"

start()
{
	echo "AppDynamics Database Agent - Starting"

    nohup $JAVA_BIN -Xmx32m -Dappdynamics.agent.uniqueHostId=$UNIQUE_HOST_ID -Ddbagent.name=$DB_AGENT_NAME -jar $DB_AGENT_JAR > /dev/null 2>&1 &

	echo "AppDynamics Database Agent - Started"
}

stop()
{
	echo "AppDynamics Database Agent - Stopping"

	# For CentOS and RedHat Linux
	ps -ef | grep "java.*db-agent" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
	
	# For Ubuntu and Debian Linux
	#    ps -opid,cmd | egrep "java.*db-agent" | awk '{print $1}' | xargs --no-run-if-empty kill -9

	echo "AppDynamics Database Agent - Stopped"
}

status()
{
	STATUS=`ps -ef | grep db-agent.jar | grep -v grep`

	if [ $? -eq 0 ]
	   then
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
