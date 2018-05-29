#!/bin/bash
#chkconfig: 2345 40 90
#description: service script for AppDynamics Enterprise Console
set -e

APPD_RUNTIME_USER="ubuntu"
APPD_EC_HOME="/opt/AppDynamics/platform-admin"

DEBUG_LOGS=false

################################################################################
# Do not edit below this line
################################################################################

init() {
	APPD_PROCESS="com.appdynamics.platformadmin.PlatformAdminApplication"
	APPD_NAME="Enterprise Console"

	MSG_RUNNING="AppDynamics - $APPD_NAME: Running"
	MSG_STOPPED="AppDynamics - $APPD_NAME: STOPPED"

	EC_CHECK_URL="http://localhost:9191/service/version"
	EC_CHECK_RUNNING="AppDynamics - $APPD_NAME /service/version: Up"
	EC_CHECK_STOPPED="AppDynamics - $APPD_NAME /service/version: Down"

	if [[ -z "$APPD_EC_HOME" ]] || [[ ! -d "$APPD_EC_HOME" ]]; then
		echo "ERROR: could not find $APPD_EC_HOME"
		exit 1
	fi
}

start() {
	echo -e "Starting the $APPD_NAME..."
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	cd $APPD_EC_HOME/bin
	sudo -H -u $APPD_RUNTIME_USER ./platform-admin.sh start-platform-admin
	cd $DIR
	echo -e "Started the $APPD_NAME..."
}

stop() {
	echo -e "Stopping the $APPD_NAME..."
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	cd $APPD_EC_HOME/bin
	sudo -H -u $APPD_RUNTIME_USER ./platform-admin.sh stop-platform-admin
	cd $DIR
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

	check-ec
}

check-ec() {
	local url="$EC_CHECK_URL"
    local expectedContent="HTTP/1.1 200 OK"

	local actualContent=$(curl -s --head "$url" | head -n 1 | grep "$expectedContent")

	log-debug "actualContent: $actualContent"

	if [[ $actualContent != *"$expectedContent"* ]]; then
		echo "$EC_CHECK_RUNNING"
	else
		echo "$EC_CHECK_STOPPED"
    fi
}

get-pid() {
	echo $(ps -ef | grep "$APPD_EC_HOME" | grep "$APPD_PROCESS" | grep -v grep | awk '{print $2}')
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
		echo "Usage: $0 {start|stop|restart|status}"
		exit 1
esac
