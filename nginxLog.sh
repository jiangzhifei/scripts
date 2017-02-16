#!/bin/bash
#------------------------------------------
#每日凌晨打包前一日日志
#-----------------------------------------

LOG_PATH=/home/nginx/nginx-1.6.3/logs/
BCK_LOG_PATH=/usr/upload/


LAST_DATE=$(date -d "yesterday" +%Y%m%d)


#循环nginx日志路径，将.log文件打成tar.gz

for LOGFILE in `ls $LOG_PATH |grep "log$"`
 do
   tarName="$LOG_PATH$LOGFILE-$LAST_DATE.tar.gz"
   bckPath="${BCK_LOG_PATH}$LOGFILE-$LAST_DATE.tar.gz"
   if  tar -zcvf $tarName $LOGFILE && mv $tarName $bckPath >/dev/null
     then
       echo "$LOGFILE has been packaged as $tarName,and moved to $bckPath"
       rm -rf $LOGFILE
       echo "$LOGFILE has been removed!"
   fi
#重新打开日志
done
pidFile="${LOG_PATH}nginx.pid"
if kill -USR1 `cat $pidFile` >/dev/null
then
        echo "$LAST_DATE log has been packaged successfully"
else
        echo "$LAST_DATE log has been packaged failed"
fi
