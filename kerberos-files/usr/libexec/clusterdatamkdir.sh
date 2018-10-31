#!/bin/sh

if ! test -e /common/clusterdata/MOUNTED ; then
  exit 0
fi
if test -e /common/clusterdata/$PAM_USER ; then
  exit 0
fi
install -d /common/clusterdata/$PAM_USER --mode 700 --owner $PAM_USER --group allusers

