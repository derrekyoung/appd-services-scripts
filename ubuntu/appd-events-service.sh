#!/bin/bash

. /home/ubuntu/AppDynamics/appd-env.sh

################################################
# Do not edit below this line

# Zookeeper
start-zookeeper() {
	cd $APPD_EVENTS_SERVICE_HOME
	echo "Starting Zookeeper..."
	export set JAVA_OPTS="-Xmx1G -Xms1G"
	bin/events-service.sh start -y conf/events-service-zookeeper.yml -p conf/events-service-zookeeper.properties
	echo " "
}
stop-zookeeper() {
	cd $APPD_EVENTS_SERVICE_HOME
	echo "Stopping Zookeeper..."
	bin/events-service.sh stop events-service-zookeeper.id
	echo " "
}
status-zookeeper() {
	cd $APPD_EVENTS_SERVICE_HOME
	echo "Health of Zookeeper..."
	java -jar bin/tool/tool-healthcheck.jar -hp localhost:9051
	echo " "
}

# API-Store
start-api-store() {
	cd $APPD_EVENTS_SERVICE_HOME
	echo "Starting API-Store..."
	export set JAVA_OPTS="-Xmx1G -Xms1G"
	bin/events-service.sh start -y conf/events-service-api-store.yml -p conf/events-service-api-store.properties
	echo " "
}
stop-api-store() {
	cd $APPD_EVENTS_SERVICE_HOME
	echo "Stopping API-Store..."
	bin/events-service.sh stop events-service-api-store.id
	echo " "
}
status-api-store() {
	cd $APPD_EVENTS_SERVICE_HOME
	echo "Health of API-Store..."
	java -jar bin/tool/tool-healthcheck.jar -hp localhost:9081
	echo " "
}

case "$1" in
	start)
		start-zookeeper
		start-api-store
		;;
	stop)
		stop-zookeeper
		stop-api-store
		;;
	restart)
		stop-zookeeper
		stop-api-store
		;;
	status)
		status-zookeeper
		status-api-store
		start-zookeeper
		start-api-store
		;;
	start-zookeeper)
		start-zookeeper
		;;
	stop-zookeeper)
		stop-zookeeper
		;;
	restart-zookeeper)
		stop-zookeeper
		start-zookeeper
		;;
	status-zookeeper)
		status-zookeeper
		;;
	start-api-store)
		start-api-store
		exit
		;;
	stop-api-store)
		stop-api-store
		;;
	restart-api-store)
		stop-api-store
		start-api-store
		;;
	status-api-store)
		status-api-store
		;;
	*)
		echo "Usage: $0 {start|stop|restart|status}"
		echo " "
		echo "Optionally, control individual components:"
		echo "  Zookeeper: $0 {start-zookeeper|stop-zookeeper|restart-zookeeper|status-zookeeper}"
		echo "  API-Store: $0 {start-api-store|stop-api-store|restart-api-store|status-api-store}"
		exit
esac
