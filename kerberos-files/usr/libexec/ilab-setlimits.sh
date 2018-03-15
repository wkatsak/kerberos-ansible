#!/bin/sh

export PATH="/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/bin"

LOGIN=`getent passwd "$PAM_USER" | cut -d: -f3`

# limit must be less than memsw.limit. Which to set first depends upon
# current values, so I try both orders
# must read the value to commit them

if [ "${LOGIN}" -ge 1000 ]; then
   # limit is 1/2 of phys mem. use right shift so it stays integer
   LIMIT=`vmstat -s | grep "total memory" | awk '{print rshift($1,1) "K"}'`
   # need to do this to create the slice and turn on memory accounting
   systemctl set-property --runtime "user-${LOGIN}.slice" MemoryLimit=$LIMIT
   echo $LIMIT > /sys/fs/cgroup/memory/user.slice/user-${LOGIN}.slice/memory.memsw.limit_in_bytes   
   echo $LIMIT > /sys/fs/cgroup/memory/user.slice/user-${LOGIN}.slice/memory.limit_in_bytes
   cat /sys/fs/cgroup/memory/user.slice/user-${LOGIN}.slice/memory.limit_in_bytes > /dev/null
   cat /sys/fs/cgroup/memory/user.slice/user-${LOGIN}.slice/memory.memsw.limit_in_bytes > /dev/null
   systemctl set-property --runtime "user-${LOGIN}.slice" CPUShares=100
fi

exit 0
