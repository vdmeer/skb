#! /bin/sh
#
# This script is called before package software is removed
#

echo  "**********************prerm********************"
echo "arguments $*"
echo  "***********************************************"

# Check if Framework is running
running_check=`ps -ef | egrep "skb-framework" | egrep -v grep`
if [ ! -z "$running_check" -a "$running_check" != "" ]
then
    echo "SKB Framework processes are running, stop prior to package upgrade"
    exit 1
fi
