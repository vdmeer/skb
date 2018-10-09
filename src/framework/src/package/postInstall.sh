#! /bin/sh
#
# This script is called after package software is installed
#

echo  "********************postinst****************"
echo "arguments $*"
echo  "***********************************************"

# Check for debian abort-remove case which calls postinst, in which we do nothing
if [ "$1" = "abort-remove" ]; then
    exit 0
fi

# Ensure everything has the correct permissions
find /opt/skb/framework -type d -perm 755
chmod 555 /opt/skb/framework/bin/*
find /opt/skb/framework/bin -type f -perm 755
find /opt/skb/framework/etc -type f -perm 664
find /opt/skb/framework/man -type f -perm 644
find /opt/skb/framework/scenarios -type f -perm 644

mkdir -p /opt/skb/framework/cache
