#!/bin/bash
#chkconfig: 2345 20 80
#description: service script for AppDynamics Controller

APPD_RUNTIME_USER="ubuntu"
APPD_CONTROLLER_HOME="/opt/AppDynamics/Controller"

DEBUG_LOGS=false

################################################################################
# Do not edit below this line
################################################################################

init() {
	APPD_PROCESS="glassfish"
	APPD_NAME="Controller"

	START_COMMAND="nohup sudo -H -u $APPD_RUNTIME_USER $JAVA $AGENT_OPTIONS -jar $AGENT_HOME/$APPD_PROCESS > /dev/null 2>&1 &"
	STOP_COMMAND="nohup sudo -H -u $APPD_RUNTIME_USER kill $(get-pid) > /dev/null 2>&1 &"

	MSG_APP_RUNNING="AppDynamics - $APPD_NAME app server: Running"
	MSG_APP_STOPPED="AppDynamics - $APPD_NAME app server: STOPPED"
	MSG_DB_RUNNING="AppDynamics - $APPD_NAME database: Running"
	MSG_DB_STOPPED="AppDynamics - $APPD_NAME database: STOPPED"
	MSG_ES_RUNNING="AppDynamics - $APPD_NAME events service: Running"
	MSG_ES_STOPPED="AppDynamics - $APPD_NAME events service: STOPPED"

	CONTROLLER_URL="http://localhost:8090/controller/login.html"
	CONTROLLER_RUNNING="AppDynamics - $APPD_NAME home page: Up"
	CONTROLLER_STOPPED="AppDynamics - $APPD_NAME home page: Down"
	CONTROLLER_VALIDATION="AppDyamics"

	if [[ -z "$APPD_CONTROLLER_HOME" ]] || [[ ! -d "$APPD_CONTROLLER_HOME" ]]; then
		echo "ERROR: could not find $APPD_CONTROLLER_HOME"
		exit 1
	fi
}

start() {
	local processPIDs=$(get-pid)
	log-debug "processPIDs=$processPIDs"
	if [[ ! -z "$processPIDs" ]]; then
   		status
		return
   	fi

	echo -e "Starting the $APPD_NAME..."
	sudo -H -u "$APPD_RUNTIME_USER" "$APPD_CONTROLLER_HOME"/bin/startController.sh
	sudo -H -u "$APPD_RUNTIME_USER" "$APPD_CONTROLLER_HOME"/bin/controller.sh start-events-service
	echo -e "Started the $APPD_NAME..."
}

stop() {
	echo -e "Stopping the $APPD_NAME..."
	sudo -H -u "$APPD_RUNTIME_USER" "$APPD_CONTROLLER_HOME"/bin/stopController.sh
	sudo -H -u "$APPD_RUNTIME_USER" "$APPD_CONTROLLER_HOME"/bin/controller.sh stop-events-service
	echo -e "Stopped the $APPD_NAME..."
}

status () {
	STATUS=$(ps -ef | grep "$APPD_CONTROLLER_HOME" | grep -i "$APPD_PROCESS" | grep -v grep)
	if [[ -z "$STATUS" ]]; then
		echo "$MSG_APP_STOPPED"
	else
		echo "$MSG_APP_RUNNING"
	fi

	STATUS=$(ps -ef | grep "$APPD_CONTROLLER_HOME" | grep -i "db/bin/mysqld" | grep -v grep)
	if [[ -z "$STATUS" ]]; then
		echo "$MSG_DB_STOPPED"
	else
		echo "$MSG_DB_RUNNING"
	fi

	STATUS=$(ps -ef | grep "$APPD_CONTROLLER_HOME" | grep -i events_service | grep -v grep)
	if [[ -z "$STATUS" ]]; then
		echo "$MSG_ES_STOPPED"
	else
		echo "$MSG_ES_RUNNING"
	fi

	check-home-page
}

check-home-page() {
	local url="$CONTROLLER_URL"
    local expectedContent="HTTP/1.1 200 OK"

	local actualContent=$(curl -s --head "$url" | head -n 1 | grep "$expectedContent")

	log-debug "actualContent: $actualContent"

	if [[ $actualContent != *"$expectedContent"* ]]; then
		echo "$CONTROLLER_STOPPED"
	else
		echo "$CONTROLLER_RUNNING"
    fi
}

get-pid() {
	echo $(ps -ef | grep "$APPD_EUM_HOME" | grep "$APPD_PROCESS" | grep -v grep | awk '{print $2}')
}

log-debug() {
    if [[ $DEBUG_LOGS = true ]]; then
        echo -e "DEBUG: $1"
    fi
}

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
		echo $"Usage: $0 {start|stop|restart|status}"
		exit 1
		;;
esac
