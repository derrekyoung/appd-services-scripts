#!/bin/bash

main() {
    # Check for parameters
    if [ -z "$1" ];then
        echo "Service script file is required as a parameter"
        echo -e "Usage:\n sudo ./$0 appd-controller.init.d.sh"
        exit 1
    fi

    TYPE=""
    RHEL="RHEL"
    UBUNTU="DEBIAN"

    if [ "$EUID" -ne 0 ]; then
        echo "ERROR: Please run $0 as root"
        exit 1
    fi

    if [ -f /etc/rc.d/init.d/functions ]; then
        # redhat flavor
        . /etc/rc.d/init.d/functions
        TYPE="$RHEL"
    elif [ -f /lib/lsb/init-functions ]; then
        # debian or suse flavor
        . /lib/lsb/init-functions
        TYPE="$UBUNTU"
    else
        echo "ERROR: Unable to find function library" 1>&2
        exit 1
    fi

    # Trim parameter file extensions
    script=$1
    service=${script%.init.d.sh}

    install
}

install() {
    echo "Deploying $script to /etc/init.d/$service"

    cp ./$script /etc/init.d/$service

    if [[ "$TYPE" == "$RHEL" ]]; then
        install-rhel
    elif [[ "$TYPE" == "$DEBIAN" ]]; then
        install-debian
    fi

    echo "Service enabled: $service"

    # Print out the usage
    service $service
}

install-rhel() {
    chkconfig --add $service
    chkconfig --level 2345 $service on
}

install-debian() {
    chmod a+rx /etc/init.d/$service
    chown root:root /etc/init.d/$service
    initctl reload-configuration

    update-rc.d $service defaults
    update-rc.d $service enable
}

main "$@"
