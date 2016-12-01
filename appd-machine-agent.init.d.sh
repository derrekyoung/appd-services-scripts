#!/bin/bash
#chkconfig: 2345 50 80
#description: service script for AppDynamics Machine agent
set -e

APPD_RUNTIME_USER="ubuntu"
AGENT_HOME="/opt/AppDynamics/agents/machineagent"
JAVA_HOME="$AGENT_HOME/jre"
JAVA="$JAVA_HOME/bin/java"

# Additional -D and JVM args here, heap size for example
AGENT_OPTIONS=""
AGENT_OPTIONS="$AGENT_OPTIONS -Xmx100m"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.maxMetrics=500"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.sim.enabled=true"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.uniqueHostId=$HOSTNAME"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.hostName=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.port=8090"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.ssl.enabled=false"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountName=customer1"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountAccessKey=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.applicationName=App_$HOSTNAME" # Optional
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.tierName=Tier_$HOSTNAME" # Optional
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.nodeName=$HOSTNAME" # Optional
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.http.proxyHost=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.http.proxyPort=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.http.proxyUser=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.http.proxyPasswordFile=FOOBAR"

DEBUG_LOGS=false



################################################################################
# Do not edit below this line
################################################################################

init() {
	APPD_PROCESS="machineagent.jar"
	APPD_NAME="Machine Agent"
	ANALYTICS_AGENT_URL="http://localhost:9091/ping"

	START_COMMAND="nohup sudo -H -u $APPD_RUNTIME_USER $JAVA $AGENT_OPTIONS -jar $AGENT_HOME/$APPD_PROCESS > /dev/null 2>&1 &"
	STOP_COMMAND="nohup sudo -H -u $APPD_RUNTIME_USER kill $(get-pid) > /dev/null 2>&1 &"

	MSG_RUNNING="AppDynamics - $APPD_NAME: Running"
	MSG_STOPPED="AppDynamics - $APPD_NAME: STOPPED"

	if [[ -z "$JAVA" ]] || [[ ! -f "$JAVA" ]]; then
		echo "ERROR: could not find $JAVA"
		exit 1
	fi

	if [[ ! -f "$AGENT_HOME/$APPD_PROCESS" ]]; then
		echo "ERROR: could not find $AGENT_HOME/$APPD_PROCESS"
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

	remove-analytics-agent-pid

    log-debug "Starting the $APPD_NAME with $JAVA $($JAVA -version)"

    echo -e "Starting the $APPD_NAME..."
	log-debug "$START_COMMAND"
	eval "$START_COMMAND"

	echo -e "Started the $APPD_NAME..."
}

stop() {
	echo -e  "Stopping the $APPD_NAME..."
	log-debug "$STOP_COMMAND"
	eval "$STOP_COMMAND"

	remove-analytics-agent-pid

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

	# Check for running Analytics agent embedded into Machine Agent at localhost:9091
	check-analytics-agent
}

get-pid() {
	echo $(ps -ef | grep "$AGENT_HOME" | grep "$APPD_PROCESS" | grep -v grep | awk '{print $2}')
}

log-debug() {
    if [[ $DEBUG_LOGS = true ]]; then
        echo -e "DEBUG: $1"
    fi
}

check-analytics-agent() {
	# TODO: Validate that Analytics is enabled in the XML

	local url="$ANALYTICS_AGENT_URL"
    local expectedContent="HTTP/1.1 200 OK"

	local actualContent=$(curl -s --head "$url" | head -n 1 | grep "$expectedContent")

	log-debug "actualContent: $actualContent"

	if [[ $actualContent != *"$expectedContent"* ]]; then
		echo "AppDynamics - Analytics Agent: STOPPED. (OPTIONAL: only necessary if using Analytics)"
	else
		echo "AppDynamics - Analytics Agent: Running"
    fi
}

remove-analytics-agent-pid() {
	log-debug "Removing $AGENT_HOME/monitors/analytics-agent/analytics-agent.id"

	nohup sudo -H -u "$APPD_RUNTIME_USER" rm -f "$AGENT_HOME"/monitors/analytics-agent/analytics-agent.id > /dev/null 2>&1 &
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
