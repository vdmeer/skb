#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# ============LICENSE_START=======================================================
#  Copyright (C) 2018 Sven van der Meer. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#-------------------------------------------------------------------------------

##
## Functions for tasks
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##



##
## function: GetTaskID
## - returns a task ID for a given ID or SHORT, empty string if not declared
## $1: ID to process
##
GetTaskID() {
    local ID=$1

    if [ ! -z ${ID:-} ]; then
        if [ -z ${DMAP_TASK_ORIGIN[$ID]:-} ]; then
            for SHORT in ${!DMAP_TASK_SHORT[@]}; do
                if [ "$SHORT" == "$ID" ]; then
                    printf ${DMAP_TASK_SHORT[$SHORT]}
                fi
            done
        else
            printf $ID
        fi
    else
        printf ""
    fi
}



##
## function: BuildTaskHelpLine
## - builds a help line for a task CLI option
## - line is printed when finished, otherwise error messages
## $1: short option, "<none>" if none
## $2: long option
## $3: argument, will be converted to UPPER case, "<none>" if none
## $4: description, tag line
## $5: length of short/long/argument, default value used if empty or not used
##
BuildTaskHelpLine() {
    local SHORT=${1:-}
    local LONG=${2:-}
    local ARGUMENT=${3:-}
    local DESCRIPTION=${4:-}
    local LENGTH=${5:-}

    if [ -z $SHORT ]; then
        ConsoleError "  ->" "build task help: no short option set"
        return
    elif [ "$SHORT" == "<none>" ]; then
        SHORT=
    fi
    if [ -z $LONG ]; then
        ConsoleError "  ->" "build task help: no long option set"
        return
    fi
    if [ -z $ARGUMENT ]; then
        ConsoleError "  ->" "build task help: no argument set"
        return
    elif [ "$ARGUMENT" == "<none>" ]; then
        ARGUMENT=
    else
        ARGUMENT=${ARGUMENT^^}
    fi
    if [ -z "$DESCRIPTION" ]; then
        ConsoleError "  ->" "build task help: no description set"
        return
    fi
    if [ -z $LENGTH ]; then
        LENGTH=24
        return
    fi

    local TYPE=
    if [ -n "$ARGUMENT" ]; then
        # options with an argument
        if [ ! -n "$SHORT" ]; then
            # long-argument
            TYPE="la"
        elif [ ! -n "$LONG" ]; then
            # short-argument
            TYPE="sa"
        else
            # short-long-argument
            TYPE="sla"
        fi
    else
        # options w/o an argument
        if [ ! -n "$SHORT" ]; then
            # long
            TYPE="l"
        elif [ ! -n "$LONG" ]; then
            # short
            TYPE="s"
        else
            # short-long
            TYPE="sl"
        fi
    fi

    local SPRINT="   "
    case "${CONFIG_MAP["PRINT_MODE"]}" in
        ansi)
            case $TYPE in
                la)     SPRINT+="     "$(PrintEffect bold --$LONG)" "$(PrintColor light-blue $ARGUMENT) ;;
                sa)     SPRINT+=$(PrintEffect bold -$SHORT)" "$(PrintColor light-blue $ARGUMENT) ;;
                sla)    SPRINT+=$(PrintEffect bold -$SHORT)" | "$(PrintEffect bold --$LONG)" "$(PrintColor light-blue $ARGUMENT) ;;
                l)      SPRINT+="     "$(PrintEffect bold --$LONG) ;;
                s)      SPRINT+=$(PrintEffect bold -$SHORT) ;;
                sl)     SPRINT+=$(PrintEffect bold -$SHORT)" | "$(PrintEffect bold --$LONG) ;;
            esac
            ;;
        text)
            case $TYPE in
                la)     SPRINT+="     *--"$LONG"* _"$ARGUMENT"_" ;;
                sa)     SPRINT+="*-"$SHORT"* _"$ARGUMENT"_" ;;
                sla)    SPRINT+="*-"$SHORT"* | *--"$LONG"* _"$ARGUMENT"_" ;;
                l)      SPRINT+="     *--"$LONG"*" ;;
                s)      SPRINT+="*-"$SHORT"*" ;;
                sl)     SPRINT+="*-"$SHORT"* | *--"$LONG"*" ;;
            esac
            ;;
        plain)
            case $TYPE in
                la)     SPRINT+="     --"$LONG" "$ARGUMENT ;;
                sa)     SPRINT+="-"$SHORT" "$ARGUMENT ;;
                sla)    SPRINT+="-"$SHORT" | --"$LONG" "$ARGUMENT ;;
                l)      SPRINT+="     --"$LONG ;;
                s)      SPRINT+="-"$SHORT ;;
                sl)     SPRINT+="-"$SHORT" | --"$LONG ;;
            esac
            ;;

        *)
            ConsoleError " ->" "describe-task - unknown print option '$PRINT_OPTION'"
            return
            ;;
    esac

    local LINE="       "$LONG" "$ARGUMENT
    local LINE_LENGTH=${#LINE}
    padding=$(( $LENGTH - $LINE_LENGTH ))
    if [ ! -n "$ARGUMENT" ]; then
        padding=$(( $padding +1 ))
    fi
    SPRINT+=$(printf '%*s' "$padding")$DESCRIPTION

    printf "$SPRINT\n"
}
