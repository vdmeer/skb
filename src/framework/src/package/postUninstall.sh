#! /bin/sh
#
# This script is called after package software is removed
#

echo  "********************postrm*******************"
echo "arguments $*"
echo  "*********************************************"

# Check for debian upgrade case which calls postrm, in which we do nothing
if [ "$1" = "upgrade" ]; then
    exit 0
fi

# Check if a soft link for Framework exists, if so remove it
if [ -L "/usr/local/bin/skb-framework" ]; then
    rm /usr/local/bin/skb-framework
fi
if [ -L "/usr/local/share/man/man1/skb-framework.1" ]; then
    rm /usr/local/share/man/man1/skb-framework.1
fi

rm -fr /opt/skb/framework
