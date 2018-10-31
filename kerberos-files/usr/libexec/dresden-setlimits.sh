#!/bin/sh

export PATH="/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/bin"

LOGIN=`getent passwd "$PAM_USER" | cut -d: -f3`

# limit must be less than memsw.limit. Which to set first depends upon
# current values, so I try both orders
# must read the value to commit them

# if user is in /etc/passwd it is a system user. no limit
if ! getent -s files passwd "$PAM_USER"; then
  if test -n "$XDG_SESSION_ID"; then
    systemctl set-property --runtime "session-${XDG_SESSION_ID}.scope" CPUAccounting=yes
  fi
  if ! (groups "$PAM_USER" | grep '\bno-mem-limit\b' >/dev/null) ; then
   # limit is 1/2 of phys mem. use right shift so it stays integer
{% if memorylimit is defined %}
   LIMIT={{ memorylimit }}
{% else %}
   LIMIT=`vmstat -s | grep "total memory" | awk '{print rshift($1,1) "K"}'`
{% endif %}
   # need to do this to create the slice and turn on memory accounting
   systemctl set-property --runtime "user-${LOGIN}.slice" MemoryLimit=$LIMIT
   echo $LIMIT > /sys/fs/cgroup/memory/user.slice/user-${LOGIN}.slice/memory.memsw.limit_in_bytes   
   echo $LIMIT > /sys/fs/cgroup/memory/user.slice/user-${LOGIN}.slice/memory.limit_in_bytes
   cat /sys/fs/cgroup/memory/user.slice/user-${LOGIN}.slice/memory.limit_in_bytes > /dev/null
   cat /sys/fs/cgroup/memory/user.slice/user-${LOGIN}.slice/memory.memsw.limit_in_bytes > /dev/null
   systemctl set-property --runtime "user-${LOGIN}.slice" CPUShares=100
{% if nvidialimit is defined %}

   # device limits seem to apply to the session, not the user, though if you
   # set it on the user future sessions will inherit it. But that won't work
   # for the first session. So use session.
   if test -n "$XDG_SESSION_ID"; then
      # 8 devices. use the same for a given user, UID mod 8
      DEVNO=`expr $LOGIN % 8`
      NUMDEV={{ nvidialimit }}
      systemctl set-property --runtime "session-${XDG_SESSION_ID}.scope" DevicePolicy=closed
      systemctl set-property --runtime "session-${XDG_SESSION_ID}.scope" DeviceAllow="/dev/nvidiactl rw"
      systemctl set-property --runtime "session-${XDG_SESSION_ID}.scope" DeviceAllow="/dev/nvidia-uvm rw"
      systemctl set-property --runtime "session-${XDG_SESSION_ID}.scope" DeviceAllow="/dev/nvidia-uvm-tools rw"
      for ((DEV=$DEVNO; DEV < (DEVNO + NUMDEV); DEV++)); do
        IND=`expr $DEV % 8`
        systemctl set-property --runtime "session-${XDG_SESSION_ID}.scope" DeviceAllow="/dev/nvidia$IND rw"
      done
   fi

{% endif %}
  fi
fi

exit 0
