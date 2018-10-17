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
## Shell: function for shell command - execute-task
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: ShellCmdExecuteTask
## - executes a task
##
ShellCmdExecuteTask() {
    local COLUMNS=$(tput cols)
    COLUMNS=$((COLUMNS - 2))

    local TASK=$(echo $SARG | cut -d' ' -f1)
    ID=$(GetTaskID $TASK)

    if [[ ! -n "$ID" ]]; then
        ConsoleError " ->" "unknown task '$SARG'"
        printf "\n"
        return
    fi

    if [[ -z "${RTMAP_TASK_LOADED[$ID]:-}" ]]; then
        ConsoleError " ->" "task '$ID' unknown or not loaded in mode '${CONFIG_MAP["APP_MODE"]}'"
        printf "\n"
        return
    fi

    local TARG="$(echo $SARG | cut -d' ' -f2-)"
    if [[ "$TARG" == "$ID" || "$TARG" == "$TASK" ]]; then
        TARG=
    fi

    local ERRNO

    local DO_EXTRAS=true
    local DO_HELP=false
    local DO_WAIT=false
    case $ID in
        list-* | describe-* | s | "s "* | settings | "settings "*)
            DO_EXTRAS=false
            ;;
        w | wait)
            DO_EXTRAS=false
            DO_WAIT=true
    esac
    case "$TARG" in
        "-h" | "--help" | "-h "* | "--help "* | *" -h" | *" --help")
            DO_EXTRAS=false
            local DO_HELP=true
            ;;
    esac

    local TIME=
    local RUNTIME
    local TS
    local TE
    local SPRINT

    if $DO_EXTRAS; then
        printf "\n "
        for ((x = 1; x < $COLUMNS; x++)); do
            printf %s "${CHAR_MAP["TOP_LINE"]}"
        done
        printf "\n"

        TIME=$(date +"%T")

        PrintEffect bold "  $ID"
        PrintEffect italic " $TIME executing task"
        if [[ -n "$TARG" ]]; then
            printf " with option(s): "
            PrintEffect bold "$TARG"
        fi
        printf "\n\n"
    elif $DO_HELP; then
        SPRINT=$(DescribeTask $TASK full ${CONFIG_MAP["PRINT_MODE"]})
        printf "\n   %s\n" "$SPRINT"
    else
        printf "\n"
    fi

    TS=$(date +%s.%N)
    set +e
    ${DMAP_TASK_EXEC[$ID]} $TARG
    ERRNO=$?
    set -e
    TE=$(date +%s.%N)

    if $DO_EXTRAS; then
        TE=$(date +%s.%N)
        if [[ $ERRNO != 0 ]]; then
            ConsoleError " ->" "error executing: '$ID $TARG'"
        fi
        printf "\n"
        PrintEffect bold "  done"
        TIME=$(date +"%T")
        RUNTIME=$(echo "$TE-$TS" | bc -l)
        PrintEffect italic " $TIME, $RUNTIME seconds, status: $ERRNO"
        printf " - "
        if [[ $ERRNO == 0 ]]; then
            PrintColor light-green "success"
        else
            PrintColor light-red "error"
        fi

        printf "\n "
        for ((x = 1; x < $COLUMNS; x++)); do
            printf %s "${CHAR_MAP["TOP_LINE"]}"
        done
        printf "\n\n"
    elif $DO_WAIT; then
        RUNTIME=$(echo "$TE-$TS" | bc -l)
        printf "    wait: $RUNTIME seconds\n"
    else
        printf "\n"
    fi
}
