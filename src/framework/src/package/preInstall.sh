#! /bin/sh
#
# This script is called before package software is installed
#

echo  "********************preinst*******************"
echo "arguments $*"
echo  "**********************************************"

# Check if Framework is running
if [ -d /tmp/skb-framework ]; then
    if [ "`ls /tmp/skb-framework | wc -l`" != "0" ]; then
        echo "==> SKB Framework processes are running, stop prior to package upgrade"
        echo "==> alternatively: remove /tmp/skb-framework"
        exit 1
    fi
fi

mkdir -p /usr/local/share/man/man1/

if ! getent group "skbuser" >/dev/null 2>&1
then
    echo "creating group skbuser . . ."
    groupadd skbuser
fi

if ! getent passwd "skbuser" >/dev/null 2>&1
then
    echo "creating user skbuser . . ."
    useradd -g skbuser skbuser
fi

# Create the skbuser home directory
mkdir -p /home/skbuser
chown -R skbuser:skbuser /home/skbuser
