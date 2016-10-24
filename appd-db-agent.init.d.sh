#!/bin/bash
set -e

APPD_RUNTIME_USER="ubuntu"
AGENT_HOME="/opt/AppDynamics/agents/dbagent"
JAVA="/usr/local/java/jdk1.8.0_91/bin/java"

# Additional -D and JVM args here, heap size for example
AGENT_OPTIONS=""
AGENT_OPTIONS="$AGENT_OPTIONS -Xmx1024m"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.maxMetrics=1000"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.hostName=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.port=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.ssl.enabled=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountName=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountAccessKey=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.uniqueHostId=FOOBAR"

DEBUG_LOGS=false

################################################################################
# Do not edit below this line
################################################################################

APPD_PROCESS="db-agent.jar"
APPD_NAME="Database Agent"

start() {
	if [[ -z "$JAVA" ]] || [[ ! -f "$JAVA" ]]; then
		echo "ERROR: could not find $JAVA"
		exit 1
	elif [[ ! -f "$AGENT_HOME/$APPD_PROCESS" ]]; then
		echo "ERROR: could not find $AGENT_HOME/$APPD_PROCESS"
		exit 1
	fi

    log-debug "Starting the $APPD_NAME with $JAVA $($JAVA -version)"

	log-debug "nohup sudo -H -u $APPD_RUNTIME_USER $JAVA $AGENT_OPTIONS -jar $AGENT_HOME/$APPD_PROCESS > /dev/null 2>&1 &"

	nohup sudo -H -u "$APPD_RUNTIME_USER" "$JAVA" $AGENT_OPTIONS -jar "$AGENT_HOME/$APPD_PROCESS" > /dev/null 2>&1 &
	# sudo -H -u "$APPD_RUNTIME_USER" "$JAVA" $AGENT_OPTIONS -jar "$AGENT_HOME/$APPD_PROCESS"
}

stop() {
	local processPIDs=$(ps -ef | grep "$AGENT_HOME"/"$APPD_PROCESS" | grep -v grep | awk '{print $2}')

	log-debug "processPIDs: $processPIDs"

    if [[ -z "$processPIDs" ]]; then
        echo -e "$APPD_PROCESS is STOPPED"
        return
    fi

    log-debug "Stopping the $APPD_NAME"

	log-debug "nohup sudo -H -u $APPD_RUNTIME_USER kill -9 \"$processPIDs\" 2>&1 &"

    # Grab all processes. Grep for db-agent. Remove the grep process. Get the PID. Then do a kill on all that.
    nohup sudo -H -u "$APPD_RUNTIME_USER" kill -9 $processPIDs > /dev/null 2>&1 &
}

status() {
	local processPIDs=$(ps -ef | grep "$AGENT_HOME"/"$APPD_PROCESS" | grep -v grep | awk '{print $2}')

	log-debug "processPIDs=$processPIDs"

	if [[ -z "$processPIDs" ]]; then
	   echo "AppDynamics $APPD_NAME is STOPPED"
   	else
		echo "AppDynamics $APPD_NAME is Running"
   	fi
}

log-debug() {
    if [[ $DEBUG_LOGS = true ]]; then
        echo -e "DEBUG: $1"
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
