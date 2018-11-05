#!/bin/sh

export PATH="/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/bin"

LOGIN=`getent passwd "$PAM_USER" | cut -d: -f3`

# only set fair share scheduling

# if user is in /etc/passwd it is a system user. no limit
if ! getent -s files passwd "$PAM_USER"; then

# Systemd doesn't want to put processes into the user slice directly.
# Only if we turn on cpu accounting for the session will it start
# keeping track of which pid is in which group.
#
# This means that not only are we doing fair share between users but
# between sessions within the user's share. I don't see a way to do
# just users using systemd to manage the accounting of which pid is in
# which cgroup.
#
# XDG_SESSION_ID is set by pam_systemd.so, so it
# had better be present in the session PAM stack before this script

  if test -n "$XDG_SESSION_ID"; then
    systemctl set-property --runtime "session-${XDG_SESSION_ID}.scope" CPUAccounting=yes
  fi
  systemctl set-property --runtime "user-${LOGIN}.slice" CPUShares=100
fi

exit 0
