#!/bin/bash

# kill long jobs if user hasn't declared a limit

# 24 hours in nanosec
LONGJOB=86400000000000
# longest we allow user to declare, in hours, a bit over 3 days
MAXLIMIT=80

for s in `find /sys/fs/cgroup/cpu,cpuacct/ -name session'*'` ; do
  USAGE=`cat "$s/cpuacct.usage"`
  # don't do anything unless session is over 24 hours
  if test $USAGE -gt $LONGJOB; then
     SESSION=${s##*/session-}
     SESSION=${SESSION%.scope}
     USER=`loginctl show-session $SESSION --property=Name | cut -d= -f2`
     USERID=`loginctl show-session $SESSION --property=User | cut -d= -f2`
     # don't do this for system users
     if getent -s files passwd "$USER" >/dev/null; then
        continue
     fi
     # if they set a limit, honor it
     if test -e /var/run/user/$USERID/LongjobLimit; then 
        LIMIT=`cat /var/run/user/$USERID/LongjobLimit`
	# if it's not numeric, ignore it
        if ! expr "$LIMIT" : '^[0-9]*$' >/dev/null; then
	    LIMIT=0
	fi
	# if it's too big, use the max value
        if test "$LIMIT" -gt "$MAXLIMIT"; then
	    LIMIT="$MAXLIMIT"
	fi
	# convert to minutes
        LIMITM=`expr 60 '*' $LIMIT`
        # if file older than the limit, kill the job
        X=`find /var/run/user/$USERID/LongjobLimit -mmin "-$LIMITM"`
        if test -n "$X"; then
	    continue
        fi
     fi
     # if no limit declared; kill it

     logger -t killjob -p local1.info killing session "$SESSION" for user "$USER" usage "$USAGE"

     loginctl terminate-session $SESSION
     # echo kill $SESSION $USER $USERID $LIMIT
     mail -r help@cs.rutgers.edu -s "killed job on `hostname`" "$USER"@rutgers.edu <<EOF

Your job has used more than 24 hours of CPU time, and you have not
requested more time. We have terminated it.

If you need to run jobs longer than 24 CPU hours, see
url:www.cs.rutgers.edu/resources/limitation-enforced-on-cs-linux-machines

$JOB          
EOF

  fi
done


