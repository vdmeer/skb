#! /bin/sh
#
# This script is called before package software is removed
#

echo  "**********************prerm********************"
echo "arguments $*"
echo  "***********************************************"

# Check if Framework is running
if [ -d /tmp/skb-framework ]; then
    if [ "`ls /tmp/skb-framework | wc -l`" != "0" ]; then
        echo "==> SKB Framework processes are running, stop prior to package upgrade"
        echo "==> alternatively: remove /tmp/skb-framework"
        exit 1
    fi
fi
