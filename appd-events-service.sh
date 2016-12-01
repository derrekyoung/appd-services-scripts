#!/bin/bash
#chkconfig: 2345 60 90
#description: service script for AppDynamics standalone events service
set -e

APPD_RUNTIME_USER="ubuntu"
ES_HOME="/home/ubuntu/AppDynamics/events-service"
export JAVA_HOME="/usr/local/java/jdk1.8.0_91"

DEBUG_LOGS=false

################################################################################
# Do not edit below this line
################################################################################

init() {
	APPD_PROCESS="tool-executor.jar"
	APPD_NAME="Events Service"

	START_COMMAND="$ES_HOME/bin/events-service.sh start $ES_HOME/conf/events-service-api-store.properties"
	STOP_COMMAND="nohup sudo -H -u $APPD_RUNTIME_USER kill $(get-pid) > /dev/null 2>&1 &"

	MSG_RUNNING="AppDynamics - $APPD_NAME: Running"
	MSG_STOPPED="AppDynamics - $APPD_NAME: STOPPED"

	ES_URL="http://localhost:9080/_ping"
	ES_RUNNING="AppDynamics - $APPD_NAME ping/: Success"
	ES_STOPPED="AppDynamics - $APPD_NAME ping/: Failure"
	ES_VALIDATION="_pong"

	if [[ -z "$JAVA_HOME" ]] || [[ ! -d "$JAVA_HOME" ]]; then
		echo -e "ERROR: could not find $JAVA_HOME"
		exit 1
	fi

	if [[ ! -d "$ES_HOME" ]]; then
		echo -e "ERROR: could not find $ES_HOME"
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
	# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	# cd $ES_HOME

	log-debug "$START_COMMAND"
	eval "$START_COMMAND"

	# cd $DIR

	echo -e "Started the $APPD_NAME..."
}

stop() {
	local processPIDs=$(get-pid)
	log-debug "processPIDs: $processPIDs"

    if [[ -z "$processPIDs" ]]; then
        echo -e "$MSG_STOPPED"
        return
    fi

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

	check-ping
}

check-ping() {
	local url="$ES_URL"
    local expectedContent="HTTP/1.1 200 OK"

	local actualContent=$(curl -s --head "$url" | head -n 1 | grep "$expectedContent")

	log-debug "actualContent: $actualContent"

	if [[ $actualContent != *"$expectedContent"* ]]; then
		echo "$ES_STOPPED"
	else
		echo "$ES_RUNNING"
    fi
}

get-pid() {
	echo $(ps -ef | grep "$ES_HOME" | grep "$APPD_PROCESS" | grep -v grep | awk '{print $2}')
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
