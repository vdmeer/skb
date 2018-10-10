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
echo " ==> removing symlinks"
if [ -L "/usr/local/bin/skb-framework" ]; then
    rm /usr/local/bin/skb-framework
fi
if [ -L "/usr/local/share/man/man1/skb-framework.1" ]; then
    rm /usr/local/share/man/man1/skb-framework.1
fi

echo " ==> removing /opt/skb-framework"
rm -fr /opt/skb/framework

if [ -d "/opt/skb" ]; then
    echo " ==> found /opt/skb"

    if [ "`ls /opt/skb | wc -l`" != "0" ]; then
        echo " ==> none empty /opt/skb - leaving directory/group/user"
    else
        echo " ==> empty /opt/skb - removing directory/group/user"

        echo " ==> removing /opt/skb"
        rmdir /opt/skb/

        if [ -e "/home/skbuser" ]; then
            echo " ==> removing /home/skbuser"
            rm -fr /home/skbuser
        fi

        if getent passwd "skbuser" >/dev/null 2>&1
        then
            echo " ==> deleting user skbuser"
            userdel skbuser
        fi

        if getent group "skbuser" >/dev/null 2>&1
        then
            echo " ==> deleting group skbuser"
            groupdel skbuser
        fi

        echo " ==> done"
    fi
fi
