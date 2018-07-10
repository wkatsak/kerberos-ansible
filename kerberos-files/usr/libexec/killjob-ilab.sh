#!/bin/bash

# jobs runniing longer than a day
# column 7 will look like 13-18:54:10 with days as first. So if we
# just look for - we'll get everything longer than 1 day
LONGJOBS=`ps -ef | awk '$7 ~ /-/{print $2}'`

for i in $LONGJOBS
do
  # by default cpu limit is unlimited. If user has set a soft
  # limit, then don't kill the job. let his soft limit do it
  LIMIT=`grep '^Max cpu' /proc/$i/limits | cut -c27-35`
  if test "$LIMIT" = 'unlimited'
  then
     USER=`ps -h -p $i -o user`
     # if the user is in /etc/passwd it's a system user. no limit
     if getent -s files passwd "$USER"; then
        continue
     fi
     JOB=`ps -hu -p $i`
     logger "killjob: killed ` ps -hu -p $i`"
     kill $i
     sleep 10
     kill -9 $i
     mail -r help@cs.rutgers.edu -s "killed job on `hostname`" "$USER"@rutgers.edu <<EOF
The following job has used more than 24 hours of CPU time. We have killed it.
If you need to run jobs longer than 24 hours, please contact help@cs.rutgers.edu.

$JOB          
EOF
  fi
done
