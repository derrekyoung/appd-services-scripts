#!/bin/sh
#--------------------------------------------------------------------------------------------------
# Script which reports on the running status of the primary on-premise AppDynamics components.
#
#	Notes:
#		There is an optional parameter 'process' which if supplied, will also display the
#		results of 'ps' for the specified component.
#
#		At present, this script is written for Ubuntu / Debian flavors of Linux.  It is not
#		full tested (especially for ps command) for other flavors of Linux.
#--------------------------------------------------------------------------------------------------


################################################
# Do not edit below this line
RETVAL=$?
SHOW_PROCESS=$1
STATUS=""
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

printStatus()
{
	if [ $? -eq 0 ]; then
		printf "${GREEN}Running${NC}\n"

		if [ -n "$SHOW_PROCESS" ]; then
			printf "$STATUS\n"
		fi
	else
		printf "${RED}STOPPED${NC}\n"
	fi
	printf '\n'
}

controllerDatabaseStatus()
{
	printf '[=== Controller Database    ===]  '

	STATUS=$(ps -ef | grep db/bin/mysqld | grep -v grep)

	printStatus
}

controllerAppServerStatus()
{
	printf '[=== Controller AppServer   ===]  '

	STATUS=$(ps -ef | grep glassfish.jar | grep -v grep)

	printStatus
}

eumProcessorStatus()
{
	printf '[=== EUM Processor          ===]  '

	STATUS=$(ps -ef | grep eum-processor | grep -v grep)

	printStatus
}

eventsServiceStatus()
{
	printf '[=== Events Service         ===]  '

	STATUS=$(ps -ef | grep events_service | grep -v grep)

	printStatus
}

reportingServiceStatus()
{
	printf '[=== Reporting Service      ===]  '

	STATUS=$(ps -ef | grep reporting_service | grep -v grep)

	printStatus
}

databaseAgentStatus()
{
	printf '[=== Database Agent         ===]  '

	STATUS=$(ps -ef | grep db-agent.jar | grep -v grep)

	printStatus
}

machineAgentStatus()
{
	printf '[=== Machine Agent ============]  '

	STATUS=$(ps -ef | grep machineagent.jar | grep -v grep)

	printStatus
}

printf '=========== AppDynamics Status ==========\n'
printf '\n'

controllerDatabaseStatus
controllerAppServerStatus
eumProcessorStatus
reportingServiceStatus
eventsServiceStatus
databaseAgentStatus
machineAgentStatus

printf '==========================================\n'

exit $RETVAL
