#!/bin/bash
#--------------------------------------------------------------------------------------------------
# Service script for starting or stopping a single node of the AppDynamics Events Service
#
#	Notes:
#		Edit all path names  to suit your particular installation.
#
#		When installing this file in the /etc/init.d directory, remove the '.sh' extension.
#
#		There may be differences in service scripts for CentOS/RedHat vs Ubuntu/Debian -
#			adjust scripts accordingly.
#
#--------------------------------------------------------------------------------------------------


# Change this directory to the correct path on your server. You may (optionally) need to set the JVM heap size of the API-Store down in the script.
APPD_EVENTS_SERVICE_DIR="/opt/AppDynamics/events-service"



validate() {
	if [ ! -d "$APPD_EVENTS_SERVICE_DIR" ]; then
		echo "ERROR: Unable to locate $APPD_EVENTS_SERVICE_DIR/. Correct the variable at the top of this script."
		exit 1
	fi
}

# Zookeeper
start-zookeeper() {
	cd $APPD_EVENTS_SERVICE_DIR
	echo "Starting Zookeeper..."
	export set JAVA_OPTS="-Xmx1G -Xms1G"
	bin/events-service.sh start -y conf/events-service-zookeeper.yml -p conf/events-service-zookeeper.properties
	echo " "
}
stop-zookeeper() {
	cd $APPD_EVENTS_SERVICE_DIR
	echo "Stopping Zookeeper..."
	bin/events-service.sh stop events-service-zookeeper.id
	echo " "
}
status-zookeeper() {
	cd $APPD_EVENTS_SERVICE_DIR
	echo "Health of Zookeeper..."
	java -jar bin/tool/tool-healthcheck.jar -hp localhost:9051
	echo " "
}

# API-Store
start-api-store() {
	cd $APPD_EVENTS_SERVICE_DIR
	echo "Starting API-Store..."
	export set JAVA_OPTS="-Xmx1G -Xms1G"
	bin/events-service.sh start -y conf/events-service-api-store.yml -p conf/events-service-api-store.properties
	echo " "
}
stop-api-store() {
	cd $APPD_EVENTS_SERVICE_DIR
	echo "Stopping API-Store..."
	bin/events-service.sh stop events-service-api-store.id
	echo " "
}
status-api-store() {
	cd $APPD_EVENTS_SERVICE_DIR
	echo "Health of API-Store..."
	java -jar bin/tool/tool-healthcheck.jar -hp localhost:9081
	echo " "
}

main() {
	case "$1" in

	# Both components
	start)
		$0 start-zookeeper
		$0 start-api-store
		exit
		;;
	stop)
		$0 stop-zookeeper
		$0 stop-api-store
		exit
		;;
	restart)
		$0 stop
		$0 start
		exit
		;;
	status)
		status-zookeeper
		status-api-store
		exit
		;;

	# Zookeeper
	start-zookeeper)
		start-zookeeper
		exit
		;;
	stop-zookeeper)
		stop-zookeeper
		exit
		;;
	restart-zookeeper)
		stop-zookeeper
		start-zookeeper
		exit
		;;
	status-zookeeper)
		status-zookeeper
		exit
		;;

	# API-Store
	start-api-store)
		start-api-store
		exit
		;;
	stop-api-store)
		stop-api-store
		exit
		;;
	restart-api-store)
		stop-api-store
		start-api-store
		exit
		;;
	status-api-store)
		status-api-store
		exit
		;;

	*)
		echo "Usage: $0 {start|stop|restart|status}"
		echo " "
		echo "Optionally, manipulate individual components:"
		echo "  Zookeeper: $0 {start-zookeeper|stop-zookeeper|restart-zookeeper|status-zookeeper}"
		echo "  API-Store: $0 {start-api-store|stop-api-store|restart-api-store|status-api-store}"
		exit
	esac
}

validate
main "$@"
