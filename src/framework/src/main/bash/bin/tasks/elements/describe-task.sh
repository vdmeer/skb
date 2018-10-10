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
## describe-task - describe-task
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##

## put bugs into errors, safer
set -o errexit -o pipefail -o noclobber -o nounset


##
## Test if we are run from parent with configuration
## - load configuration
##
if [ -z $FW_HOME ] || [ -z $FW_TMP_CONFIG ]; then
    printf " ==> please run from framework or application\n\n"
    exit 10
fi
source $FW_TMP_CONFIG
CONFIG_MAP["RUNNING_IN"]="task"


##
## load main functions
## - reset errors and warnings
##
source $FW_HOME/bin/functions/_include
source $FW_HOME/bin/functions/describe/task.sh
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
PRINT_MODE=
TASK_ID=
LOADED=
UNLOADED=
APP_MODE=
ORIGIN=
STATUS=
ALL=
CLI_SET=false



##
## set CLI options and parse CLI
##
CLI_OPTIONS=ahi:lm:o:p:s:u
CLI_LONG_OPTIONS=all,mode:,help,id:,loaded,origin:,print-mode:,status:,unloaded

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name describe-task -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    ConsoleError "  ->" "unknown CLI options"
    exit 1
fi
eval set -- "$PARSED"

PRINT_PADDING=25
while true; do
    case "$1" in
        -a | --all)
            ALL=yes
            CLI_SET=true
            shift
            ;;
        -m | --mode)
            APP_MODE="$2"
            CLI_SET=true
            shift 2
            ;;
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"                $PRINT_PADDING
            BuildTaskHelpLine p print-mode  "MODE"      "print mode: ansi, text, adoc"              $PRINT_PADDING
            printf "\n   filters\n"
            BuildTaskHelpLine a all         "<none>"    "all tasks, disables all other filters"                 $PRINT_PADDING
            BuildTaskHelpLine i id          "ID"        "task identifier"                                       $PRINT_PADDING
            BuildTaskHelpLine l loaded      "<none>"    "only loaded tasks"                                     $PRINT_PADDING
            BuildTaskHelpLine m mode        "MODE"      "only tasks for application mode: dev, build, use"      $PRINT_PADDING
            BuildTaskHelpLine o origin      "ORIGIN"    "only tasks from origin: f(w), a(pp)"                   $PRINT_PADDING
            BuildTaskHelpLine s status      "STATUS"    "only tasks for status: success, warnings, errors"      $PRINT_PADDING
            BuildTaskHelpLine u unloaded    "<none>"    "only unloaded tasks"                                   $PRINT_PADDING
            exit 0
            ;;
        -i | --id)
            TASK_ID="$2"
            CLI_SET=true
            shift 2
            ;;
        -l | --loaded)
            LOADED=yes
            CLI_SET=true
            shift
            ;;
        -o | --origin)
            ORIGIN="$2"
            CLI_SET=true
            shift 2
            ;;
        -p | --print-mode)
            PRINT_MODE="$2"
            CLI_SET=true
            shift 2
            ;;
        -s | --status)
            STATUS="$2"
            CLI_SET=true
            shift 2
            ;;
        -u | --unloaded)
            UNLOADED=yes
            CLI_SET=true
            shift
            ;;

        --)
            shift
            break
            ;;
        *)
            ConsoleFatal "  ->" "internal error (task): CLI parsing bug"
            exit 2
    esac
done



############################################################################################
## test CLI
############################################################################################
if [ ! -n "$PRINT_MODE" ]; then
    PRINT_MODE=${CONFIG_MAP["PRINT_MODE"]}
fi

if [ "$ALL" == "yes" ]; then
    TASK_ID=
    LOADED=
    UNLOADED=
    APP_MODE=
    ORIGIN=
    STATUS=
elif [ $CLI_SET == false ]; then
    APP_MODE=${CONFIG_MAP["APP_MODE"]}
    LOADED=yes
else
    if [ -n "$TASK_ID" ]; then
        ORIG_TASK=$TASK_ID
        TASK_ID=$(GetTaskID $TASK_ID)
        if [ -z ${TASK_ID:-} ]; then
            ConsoleError " ->" "unknown task: $ORIG_TASK"
            exit 3
        else
            if [ -z ${TASK_DECL_MAP[$TASK_ID]:-} ]; then
                ConsoleError " ->" "unknown task: $ORIG_TASK"
                exit 3
            fi
        fi
    fi
    if [ -n "$ORIGIN" ]; then
        case $ORIGIN in
            F| f | fw | framework)
                ORIGIN=FW_HOME
                ;;
            A | a | app | application)
                ORIGIN=${CONFIG_MAP["FLAVOR"]}_HOME
                ;;
            *)
                ConsoleError " ->" "unknown origin: $ORIGIN"
                exit 3
        esac
    fi
    if [ -n "$APP_MODE" ]; then
        case $APP_MODE in
            d | dev)
                APP_MODE=dev
                ;;
            b| build)
                APP_MODE=build
                ;;
            u | use)
                APP_MODE=use
                ;;
            *)
                ConsoleError "  ->" "unknown application mode: $APP_MODE"
                exit 3
        esac
    fi
    if [ -n "$STATUS" ]; then
        case $STATUS in
            s | success)
                STATUS=S
                ;;
            e | errors | error)
                STATUS=E
                ;;
            w | warnings | warning)
                STATUS=W
                ;;
            *)
                ConsoleError "  ->" "unknown status: $STATUS"
                exit 3
        esac
    fi
fi


############################################################################################
##
## ready to go
##
############################################################################################
ConsoleInfo "  -->" "dt: starting task"

for ID in ${!TASK_DECL_MAP[@]}; do
    if [ -n "$TASK_ID" ]; then
        if [ ! "$TASK_ID" == "$ID" ]; then
            continue
        fi
    fi
    if [ -n "$LOADED" ]; then
        if [ -z "${LOADED_TASKS[$ID]:-}" ]; then
            continue
        fi
    fi
    if [ -n "$UNLOADED" ]; then
        if [ -z "${UNLOADED_TASKS[$ID]:-}" ]; then
            continue
        fi

    fi
    if [ -n "$STATUS" ]; then
        case ${TASK_STATUS_MAP[$ID]} in
            $STATUS)
                ;;
            *)
                continue
                ;;
        esac
        #=
    fi
    if [ -n "$APP_MODE" ]; then
        case ${TASK_MODE_MAP[$ID]} in
            *$APP_MODE*)
                ;;
            *)
                continue
                ;;
        esac
    fi
    if [ -n "$ORIGIN" ]; then
        if [ ! "$ORIGIN" == "${TASK_DECL_MAP[$ID]%:::*}" ]; then
            continue
        fi
    fi
    keys=(${keys[@]:-} $ID)
done
keys=($(printf '%s\n' "${keys[@]:-}"|sort))

for i in ${!keys[@]}; do
    ID=${keys[$i]}
    DescribeTask $ID full "$PRINT_MODE line-indent" $PRINT_MODE
done

ConsoleInfo "  -->" "dt: done"
exit $TASK_ERRORS
