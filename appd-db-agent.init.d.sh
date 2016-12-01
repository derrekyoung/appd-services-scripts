#!/bin/bash
#chkconfig: 2345 60 90
#description: service script for AppDynamics Database agent
set -e

APPD_RUNTIME_USER="ubuntu"
AGENT_HOME="/opt/AppDynamics/agents/dbagent"
JAVA_HOME="/usr/local/java/jdk1.8.0_91"
JAVA="$JAVA_HOME/bin/java"

# Additional -D and JVM args here, heap size for example
AGENT_OPTIONS=""
AGENT_OPTIONS="$AGENT_OPTIONS -Xmx1024m"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.uniqueHostId=$HOSTNAME"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.hostName=localhost"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.port=8090"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.ssl.enabled=false"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountName=customer1"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountAccessKey=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Ddbagent.name=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.http.proxyHost=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.http.proxyPort=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.http.proxyUser=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.http.proxyPasswordFile=FOOBAR"

DEBUG_LOGS=false

################################################################################
# Do not edit below this line
################################################################################

init() {
	APPD_PROCESS="db-agent.jar"
	APPD_NAME="Database Agent"

	START_COMMAND="nohup sudo -H -u $APPD_RUNTIME_USER $JAVA $AGENT_OPTIONS -jar $AGENT_HOME/$APPD_PROCESS > /dev/null 2>&1 &"
	STOP_COMMAND="nohup sudo -H -u $APPD_RUNTIME_USER kill $(get-pid) > /dev/null 2>&1 &"

	MSG_RUNNING="AppDynamics - $APPD_NAME: Running"
	MSG_STOPPED="AppDynamics - $APPD_NAME: STOPPED"

	if [[ -z "$JAVA_HOME" ]] || [[ ! -f "$JAVA" ]]; then
		echo -e "ERROR: could not find $JAVA"
		exit 1
	elif [[ ! -f "$AGENT_HOME/$APPD_PROCESS" ]]; then
		echo -e "ERROR: could not find $AGENT_HOME/$APPD_PROCESS"
		exit 1
	fi
}

start() {
	local processPIDs=$(get-pid)
	log-debug "processPIDs=$processPIDs"
	if [[ ! -z "$processPIDs" ]]; then
   		echo -e "$MSG_RUNNING"
		return
   	fi

    echo -e "Starting the $APPD_NAME..."
	log-debug "$START_COMMAND"
	eval "$START_COMMAND"

	echo -e "Started the $APPD_NAME..."
}

stop() {
	echo -e  "Stopping the $APPD_NAME..."
	log-debug "$STOP_COMMAND"
	eval "$STOP_COMMAND"
	echo -e "Stopped the $APPD_NAME..."
}

status() {
	local processPIDs=$(get-pid)

	log-debug "processPIDs=$processPIDs"

	if [[ -z "$processPIDs" ]]; then
		echo "$MSG_STOPPED"
   	else
		echo "$MSG_RUNNING"
   	fi
}

get-pid() {
	echo $(ps -ef | grep "$AGENT_HOME" | grep "$APPD_PROCESS" | grep -v grep | awk '{print $2}')
}

log-debug() {
    if [[ $DEBUG_LOGS = true ]]; then
        echo -e "DEBUG: $1"
    fi
}

# init() to set the global variables
init
case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		sleep 1
		start
		;;
	status)
		status
		;;
	*)
		echo -e "Usage:\n $0 [start|stop|restart|status]"
		exit 1
		;;
esac
