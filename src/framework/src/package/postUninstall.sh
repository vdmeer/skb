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

if [ "`ls /opt/skb|wc -l`" == "0" ]; then
    # no more SKB software installed, remove directory, user, and group
    rmdir /opt/skb/

    if [ -e "/home/skbuser" ]; then
        echo "deleting home directory of user skbuser . . ."
        rm -fr /home/skbuser
    fi

    if getent passwd "skbuser" >/dev/null 2>&1
    then
        echo "deleting user skbuser . . ."
        userdel skbuser
    fi

    if getent group "skbuser" >/dev/null 2>&1
    then
        echo "deleting group skbuser . . ."
        groupdel skbuser
    fi
fi
