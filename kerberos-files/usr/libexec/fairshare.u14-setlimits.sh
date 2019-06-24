#!/bin/sh

# do not use this directly. Use fairshare-setlimits.sh
# it will load this file for ubuntu 14.

# set fair share per user. With systemd this is easy, but
# this is for ubuntu 14 and 16. In 14 we have to set up the
# cgroups. In 16 they're set up by systemd, but we still have
# to put the pids into the slice. In 18 it works like Centos 7

export PATH="/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/bin"

LOGIN=`getent passwd "$PAM_USER" | cut -d: -f3`

if ! getent -s files passwd "$PAM_USER"; then

  if ! test -e /sys/fs/cgroup/cpuacct,cpu/tasks ; then
     mkdir -p /sys/fs/cgroup/cpuacct,cpu
     mount -t cgroup -o cpuacct,cpu cpuacct,cpu /sys/fs/cgroup/cpuacct,cpu
  fi

  if ! test -e /sys/fs/cgroup/cpuacct,cpu/$LOGIN.user; then
     mkdir /sys/fs/cgroup/cpuacct,cpu/$LOGIN.user
  fi

# cgroups now set up. Put processes from current session into it
# I believe logind's idea of the proceses in a session, if we have it
  if test -n "$XDG_SESSION_ID" -a -e /sys/fs/cgroup/systemd/user/$LOGIN.user/$XDG_SESSION_ID.session/tasks; then
     for pid in `cat /sys/fs/cgroup/systemd/user/$LOGIN.user/$XDG_SESSION_ID.session/tasks`
     do
       echo $pid > /sys/fs/cgroup/cpuacct,cpu/$LOGIN.user/tasks
     done
  else
# session isn't set up. Put our parent into it. That should be sshd, etc
     echo `ps -h -o ppid --pid=$$` >  /sys/fs/cgroup/cpuacct,cpu/$LOGIN.user/tasks
  fi
  echo 100 > /sys/fs/cgroup/cpuacct,cpu/$LOGIN.user/cpu.shares

fi

   
