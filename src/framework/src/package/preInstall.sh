#! /bin/sh
#
# This script is called before package software is installed
#

echo  "********************preinst*******************"
echo "arguments $*"
echo  "**********************************************"

# Check if Framework is running
running_check=`ps -ef | egrep "skb-framework" | egrep -v grep`
if [ ! -z "$running_check" -a "$running_check" != "" ]
then
    echo "SKB Framework processes are running, stop prior to package upgrade"
    exit 1
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
