#!/bin/sh
#
# Script for starting/stopping LibreOffice without restarting DevOps
# -------

    # JDK locations
    export JAVA_HOME="/usr/lib/jvm/java-8-oracle"
    export JRE_HOME=$JAVA_HOME/jre

    # User under which tomcat will run
    USER=devops
    DEVOPS_HOME=/home/devops
    cd "$DEVOPS_HOME"
    # export LC_ALL else openoffice may use en settings on dates etc
    export LC_ALL=@@LOCALESUPPORT@@
    export CATALINA_PID="${DEVOPS_HOME}/tomcat.pid"

    RETVAL=0

    start() {
        OFFICE_PORT=`ps ax|grep office|grep 8100|wc -l`
        if [ $OFFICE_PORT -ne 0 ]; then
            echo "DevOps Open Office service already started"
	        CURRENT_PROCID=`ps axf|grep office|grep 8100|awk -F " " 'NR==1 {print $1}'`
	        echo $CURRENT_PROCID
        else
            #Only start if DevOps is already running
            SHUTDOWN_PORT=`netstat -vatn|grep LISTEN|grep 8005|wc -l`
            export JAVA_HOME=$JAVA_HOME
            if [ $SHUTDOWN_PORT -ne 0 ]; then
            /bin/su -s /bin/bash $USER -c "/opt/libreoffice5.2/program/soffice.bin \"--accept=socket,host=localhost,port=8100;urp;StarOffice.ServiceManager\" \"-env:UserInstallation=file:///home/devops/devops_data/oouser\" --nologo --headless --nofirststartwizard --norestore --nodefault &" >/dev/null
            echo "DevOps Open Office starting"
	        logger DevOps Open Office service started
            fi

        fi
    }
    stop() {
        # Start Tomcat in normal mode
        OFFICE_PORT=`ps ax|grep office|grep 8100|wc -l`
        if [ $OFFICE_PORT -ne 0 ]; then
            echo "DevOps Open Office started, killing"
	        CURRENT_PROCID=`ps axf|grep office|grep 8100|awk -F " " 'NR==1 {print $1}'`
	        echo $CURRENT_PROCID
	        kill $CURRENT_PROCID
	        logger DevOps Open Office service stopped
        fi
    }
    status() {
        # Start Tomcat in normal mode
        OFFICE_PORT=`ps ax|grep office|grep 8100|wc -l`
        if [ $OFFICE_PORT -ne 0 ]; then
            echo "DevOps LibreOffice service started"
        else
            echo "DevOps LibreOffice service NOT started"
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
	    sleep 2
            start
            ;;
      status)
            status
            ;;
      *)
            echo "Usage: $0 {start|stop|restart|status}"
            exit 1
    esac

    exit $RETVAL