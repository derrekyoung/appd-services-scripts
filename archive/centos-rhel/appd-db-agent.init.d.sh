#!/bin/bash
#--------------------------------------------------------------------------------------------------
# Linux service script for the AppDynamics Database Agent
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
# description: AppDynamics Database Agent
#--------------------------------------------------------------------------------------------------

# Edit the following parameters to suit your environment
DBAGENT_AGENT_HOME="/opt/AppDynamics/DBAgent"
APPD_RUNTIME_USER="root"



################################################
# Do not edit below this line

start()
{
	if [ -x "$DBAGENT_AGENT_HOME/DBAgent.sh" ]; then
		/bin/su $APPD_RUNTIME_USER $DBAGENT_AGENT_HOME/DBAgent.sh start
		RETVAL=$?
	else
		echo "Startup script $DBAGENT_AGENT_HOME/DBAgent.sh doesn't exist or is not executable."
		RETVAL=255
	fi
}

stop()
{
	if [ -x "$DBAGENT_AGENT_HOME/DBAgent.sh" ]; then
		/bin/su $APPD_RUNTIME_USER $DBAGENT_AGENT_HOME/DBAgent.sh stop
		RETVAL=$?
	else
		echo "Startup script $DBAGENT_AGENT_HOME/DBAgent.sh doesn't exist or is not executable."
		RETVAL=255
	fi
}

status ()
{
	if [ -x "$DBAGENT_AGENT_HOME/DBAgent.sh" ]; then
		/bin/su $APPD_RUNTIME_USER $DBAGENT_AGENT_HOME/DBAgent.sh status
		RETVAL=$?
	else
		echo "Startup script $DBAGENT_AGENT_HOME/DBAgent.sh doesn't exist or is not executable."
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
