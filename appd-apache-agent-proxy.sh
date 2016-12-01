#!/bin/bash
#chkconfig: 2345 60 90
#description: service script for AppDynamics Apache agent proxy
set -e

APPD_RUNTIME_USER="ubuntu"
AGENT_HOME="/opt/AppDynamics/appdynamics-sdk-native"

DEBUG_LOGS=false

################################################################################
# Do not edit below this line
################################################################################

init() {
	APPD_PROCESS="com.appdynamics.ee.agent.proxy.bootstrap.ProxyControlEntryPoint"
	APPD_NAME="Apache Agent Proxy"

	START_COMMAND="nohup sudo -H -u $APPD_RUNTIME_USER $AGENT_HOME/runSDKProxy.sh >>/dev/null 2>$AGENT_HOME/logs/proxy.out &"
	STOP_COMMAND="nohup sudo -H -u $APPD_RUNTIME_USER kill $(get-pid) > /dev/null 2>&1 &"

	MSG_RUNNING="AppDynamics - $APPD_NAME: Running"
	MSG_STOPPED="AppDynamics - $APPD_NAME: STOPPED"

	if [[ ! -d "$AGENT_HOME" ]]; then
		echo "ERROR: could not find $AGENT_HOME"
		exit 1
	fi

	# TODO: Validate running on Linux
}

start() {
	# Validate not already started
	local processPIDs=$(get-pid)
	log-debug "processPIDs=$processPIDs"
	if [[ ! -z "$processPIDs" ]]; then
   		echo "$MSG_RUNNING"
		return
   	fi

    echo -e "Starting the $APPD_NAME..."
	eval "$START_COMMAND"
	echo -e "Started the $APPD_NAME..."
}

stop() {
    echo -e  "Stopping the $APPD_NAME..."
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
