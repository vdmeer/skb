#!/usr/bin/env bash

gradle -c java.settings clean
gradle -c java.settings

mkdir -p src/main/bash/doc/manual
mkdir -p src/main/bash/man/man1
mkdir -p src/main/bash/cache

mkdir -p src/main/bash/bin/java
cp build/libs/skb-framework-tool-0.0.0-all.jar src/main/bash/bin/java

#TOOL_DIR=`(cd build/libs;pwd)`
export SF_SKB_FW_TOOL=$TOOL_DIR/skb-framework-tool-0.0.0-all.jar
src/main/bash/bin/skb-framework -c
src/main/bash/bin/skb-framework -M dev -e bdh -S off
src/main/bash/bin/skb-framework -h

gradle -c distribution.settings
