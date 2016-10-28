#!/bin/bash
#chkconfig: 2345 50 80
#description: service script for AppDynamics Machine agent
set -e

APPD_RUNTIME_USER="appdynamics"
AGENT_HOME="/opt/AppDynamics/machineagent"
JAVA="$AGENT_HOME/jre/bin/java"

# Additional -D and JVM args here, heap size for example
AGENT_OPTIONS=""
AGENT_OPTIONS="$AGENT_OPTIONS -Xmx100m"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.maxMetrics=500"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.sim.enabled=true"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.hostName=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.port=8090"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.ssl.enabled=false"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountName=customer1"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountAccessKey=FOOBAR"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.uniqueHostId=$HOSTNAME"
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.applicationName=$HOSTNAME" # Optional
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.tierName=$HOSTNAME" # Optional
# AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.nodeName=$HOSTNAME" # Optional

DEBUG_LOGS=false



################################################################################
# Do not edit below this line
################################################################################

APPD_PROCESS="machineagent.jar"
APPD_NAME="Machine Agent"
ANALYTICS_AGENT_URL="http://localhost:9091/ping"

start() {
	if [[ -z "$JAVA" ]] || [[ ! -f "$JAVA" ]]; then
		echo "ERROR: could not find $JAVA"
		exit 1
	elif [[ ! -f "$AGENT_HOME/$APPD_PROCESS" ]]; then
		echo "ERROR: could not find $AGENT_HOME/$APPD_PROCESS"
		exit 1
	fi

	remove-analytics-agent-pid

    log-debug "Starting the $APPD_NAME with $JAVA $($JAVA -version)"

	nohup sudo -H -u "$APPD_RUNTIME_USER" "$JAVA" $AGENT_OPTIONS -jar "$AGENT_HOME/$APPD_PROCESS" > /dev/null 2>&1 &
}

stop() {
	local processPIDs=$(ps -ef | grep "$AGENT_HOME/$APPD_PROCESS" | grep -v grep | awk '{print $2}')

	log-debug "processPIDs: $processPIDs"

    if [[ -z "$processPIDs" ]]; then
        echo -e "$APPD_PROCESS is STOPPED"
        return
    fi

    log-debug "Stopping the $APPD_NAME"

    # Grab all processes. Grep for db-agent. Remove the grep process. Get the PID. Then do a kill on all that.
    nohup sudo -H -u "$APPD_RUNTIME_USER" kill -9 $processPIDs > /dev/null 2>&1 &

	remove-analytics-agent-pid
}

status() {
	local processPIDs=$(ps -ef | grep "$AGENT_HOME/$APPD_PROCESS" | grep -v grep | awk '{print $2}')

	log-debug "processPIDs=$processPIDs"

	if [[ -z "$processPIDs" ]]; then
	   echo "AppDynamics $APPD_NAME is STOPPED"
   	else
		echo "AppDynamics $APPD_NAME is Running"
   	fi

   # Check for running Analytics agent embedded into Machine Agent at localhost:9091
   check-analytics-agent
}

log-debug() {
    if [[ $DEBUG_LOGS = true ]]; then
        echo -e "DEBUG: $1"
    fi
}

check-analytics-agent() {
	local url="$ANALYTICS_AGENT_URL"
    local expectedContent="HTTP/1.1 200 OK"

	local actualContent=$(curl -s --head "$url" | head -n 1 | grep "$expectedContent")

	log-debug "actualContent: $actualContent"

	if [[ $actualContent != *"$expectedContent"* ]]; then
		echo "AppDynamics Analytics Agent is STOPPED. (OPTIONAL: only necessary if using Analytics)"
	else
		echo "AppDynamics Analytics Agent is Running"
    fi
}

remove-analytics-agent-pid() {
	log-debug "Removing $AGENT_HOME/monitors/analytics-agent/analytics-agent.id"

	nohup sudo -H -u "$APPD_RUNTIME_USER" rm -f "$AGENT_HOME"/monitors/analytics-agent/analytics-agent.id > /dev/null 2>&1 &
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
		echo -e "Usage:\n $0 [start|stop|restart|status]"
		exit 1
		;;
esac
