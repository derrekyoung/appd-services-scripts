#!/bin/bash
#--------------------------------------------------------------------------------------------------
# Linux service script for the AppDynamics Machine Agent
#
#	Notes:
#		This service script will run the AppDynamics in a dedicated user account.
#
#		Edit all path names or agent options to suit your particular installation.
#
#		Copy this file to the /etc/init.d directory as 'appd-controller'
#			Remove the 'init.d.sh' extension
#
#		There may be differences for CentOS/RedHat vs Ubuntu/Debian - adjust accordingly.
#
# chkconfig: 2345 60 25
# description: AppDynamics Machine Agent
#--------------------------------------------------------------------------------------------------

# Edit the following parameters to suit your environment
MACHINE_AGENT_HOME="/opt/AppDynamics/MachineAgent"
APPD_RUNTIME_USER="root"

################################################
# Do not edit below this line

start()
{
	if [ -x "$MACHINE_AGENT_HOME/MachineAgent.sh" ]; then
		/bin/su $APPD_RUNTIME_USER $MACHINE_AGENT_HOME/MachineAgent.sh start
		RETVAL=$?
	else
		echo "Startup script $MACHINE_AGENT_HOME/MachineAgent.sh doesn't exist or is not executable."
		RETVAL=255
	fi
}

stop()
{
	if [ -x "$MACHINE_AGENT_HOME/MachineAgent.sh" ]; then
		/bin/su $APPD_RUNTIME_USER $MACHINE_AGENT_HOME/MachineAgent.sh stop
		RETVAL=$?
	else
		echo "Startup script $MACHINE_AGENT_HOME/MachineAgent.sh doesn't exist or is not executable."
		RETVAL=255
	fi
}

setprogdir()
{
	PRG="$0"
	LSCMD=$(ls -ld "$PRG")
	LINK=$(expr "$LSCMD" : '.*-> \(.*\)$')

	if expr "$LINK" : '/.*' > /dev/null; then
		PRG="$LINK"
	else
		PRG=$(dirname "$PRG")/"$LINK"
	fi

	# Get program directory
	PRGDIR=`dirname "$PRG"`

	# Full path of program directory
	PRGDIR=$(cd "$PRGDIR" ; pwd -P)

	echo "PRGDIR = $PRGDIR"
}

status ()
{
#	setprogdir

	if [ -x "$MACHINE_AGENT_HOME/MachineAgent.sh" ]; then
		/bin/su $APPD_RUNTIME_USER $MACHINE_AGENT_HOME/MachineAgent.sh status
		RETVAL=$?
	else
		echo "Startup script $MACHINE_AGENT_HOME/MachineAgent.sh doesn't exist or is not executable."
		RETVAL=255
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
