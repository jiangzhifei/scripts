#!/bin/sh
JARFile=$2
PIDFile=$3
LOGFile=$4

if [ $4 ]
then
  LOGFile=$4
else
  LOGFile="application.log"
fi

function print_process {
  if [  -f $PIDFile ]
  then
    echo $(<"$PIDFile")
  fi
}

function check_if_pid_file_exists {
  if [ ! -f $PIDFile ]
  then
    echo "PID file not found: $PIDFile,app may be shutdown"
    exit 1
  fi
}

function check_if_process_is_running {
  if [  $(print_process) ]
  then
    if [ `jps -v|grep $(print_process) | wc -l` ]
    then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

case "$1" in
  status)
    check_if_pid_file_exists
    if check_if_process_is_running
    then
      echo $(print_process)" is running"
    else
      echo "Process not running: $(print_process)"
    fi
    ;;

  stop)
    check_if_pid_file_exists
    if ! check_if_process_is_running
    then
      echo "Process $(print_process) already stopped"
      exit 0
    fi
      kill -TERM $(print_process)
      echo -ne "$(print_process) Waiting for process to stop"
      NOT_KILLED=1
    for i in {1..60}; do
      # echo $(check_if_process_is_running)
      if check_if_process_is_running
      then
        echo -ne "."
        sleep 1
      else
        NOT_KILLED=0
        # break
      fi
    done
    # echo
    if [ $NOT_KILLED = 1 ]
    then
      echo "Cannot kill process $(print_process)"
      exit 1
    fi
    echo "Process stopped"
    ;;

  start)
    if [ -f $PIDFile ] && check_if_process_is_running
    then
      echo "Process $(print_process) already running"
      exit 1
    fi
    nohup java -jar $JARFile >> $LOGFile 2>&1 &
    echo "Process $(print_process) started"
  ;;

  restart)
    $0 stop $2 $3 $4
    if [ $? = 4 ]
    then
      exit 1
    fi
      $0 start $2 $3 $4
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status} {app.jar} {pid.pid} {log.log},when logFile be ignored,the default logFile ./application.log will be used"
    exit 1
  esac
exit 0
