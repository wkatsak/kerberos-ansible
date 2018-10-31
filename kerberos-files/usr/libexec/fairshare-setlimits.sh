#!/bin/sh

export PATH="/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/bin"

LOGIN=`getent passwd "$PAM_USER" | cut -d: -f3`

# only set fair share scheduling

# if user is in /etc/passwd it is a system user. no limit
if ! getent -s files passwd "$PAM_USER"; then
  systemctl set-property --runtime "user-${LOGIN}.slice" CPUShares=100
fi

exit 0
