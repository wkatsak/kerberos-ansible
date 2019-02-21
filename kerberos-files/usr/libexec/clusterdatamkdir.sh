#!/bin/sh

HOMEDIR=`getent passwd $PAM_USER | cut -d: -f6`
if sudo -u $PAM_USER test -e "$HOMEDIR"/.ccdmkdirdone; then
  exit 0
fi
if ! test -e /common/clusterdata/MOUNTED ; then
  exit 0
fi
if test -e /common/clusterdata/$PAM_USER ; then
  sudo -u $PAM_USER touch "$HOMEDIR"/.ccdmkdirdone
  exit 0
fi
install -d /common/clusterdata/$PAM_USER --mode 700 --owner $PAM_USER --group allusers
sudo -u $PAM_USER touch "$HOMEDIR"/.ccdmkdirdone

