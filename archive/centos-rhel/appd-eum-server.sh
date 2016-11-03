#!/bin/sh
#--------------------------------------------------------------------------------------------------
# Service script for starting or stopping the AppDynamics EUM Server
#
#	Notes:
#		Edit all path names or agent options to suit your particular installation.
#
#		When installing this file in the /etc/init.d directory,
#			remove the '.sh' extension
#
#		There may be differences in service scripts for CentOS/RedHat vs Ubuntu/Debian -
#			adjust scripts accordingly
#
#--------------------------------------------------------------------------------------------------

# Change this directory to the correct path on your server
APPD_EUM_DIR="/opt/AppDynamics/EUEM/eum-processor"



validate() {
	if [ ! -d "$APPD_EUM_DIR" ]; then
		echo "ERROR: Unable to locate $APPD_EUM_DIR/. Correct the variable at the top of this script."
		exit 1
	fi
}

main() {
	case "$1" in
	start)
		cd $APPD_EUM_DIR
		exec bin/eum.sh start
	;;

	stop)
		cd $APPD_EUM_DIR
		exec bin/eum.sh stop
	;;

	restart)
		$0 stop
		$0 start
	;;

	status)
		exit 1
	;;

	*)
		echo "Usage: $0 {start|stop|restart|status}"
		exit 1
	esac
}

validate
main "$@"
