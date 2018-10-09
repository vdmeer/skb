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
## list-options - list options
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
source $FW_HOME/bin/functions/describe/option.sh
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
PRINT_MODE=
LIST=false
TABLE=true
EXIT=
RUNTIME=
ALL=
CLI_SET=false



##
## set CLI options and parse CLI
##
CLI_OPTIONS=aehlp:rt
CLI_LONG_OPTIONS=all,exit,help,list,print-mode:,runtime,table

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name list-options -- "$@")
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
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"        $PRINT_PADDING
            BuildTaskHelpLine l list        "<none>"    "table format"                      $PRINT_PADDING
            BuildTaskHelpLine p print-mode  "MODE"      "print mode: ansi, text, adoc"      $PRINT_PADDING
            BuildTaskHelpLine t table       "<none>"    "help screen format"                $PRINT_PADDING
            printf "\n   filters\n"
            BuildTaskHelpLine a all         "<none>"    "all options, disables all other filters"       $PRINT_PADDING
            BuildTaskHelpLine e exit        "<none>"    "only exit options"                             $PRINT_PADDING
            BuildTaskHelpLine r runtime     "<none>"    "only runtime options"                          $PRINT_PADDING
            exit 0
            ;;
        -e | --exit)
            EXIT=yes
            CLI_SET=true
            shift
            ;;
        -l | --list)
            shift
            LIST=true
            TABLE=false
            ;;
        -p | --print-mode)
            PRINT_MODE="$2"
            shift 2
            ;;
        -r | --runtime)
            RUNTIME=yes
            CLI_SET=true
            shift
            ;;
        -t | --table)
            shift
            TABLE=true
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
## check CLI
############################################################################################
if [ $LIST == false ] && [ $TABLE == false ]; then
    ConsoleError "  ->" "no mode set: use list and/or table"
    exit 3
fi

if [ "$ALL" == "yes" ]; then
    EXIT=
    RUNTIME=
elif [ $CLI_SET == false ]; then
    EXIT=yes
    RUNTIME=yes
fi



############################################################################################
## top and bottom functions for list and table
############################################################################################
function TableTop() {
    printf "\n "
    printf "${CHAR_MAP["TOP_LINE"]}%.0s" {1..79}
    printf "\n"
    printf " ${EFFECTS["REVERSE_ON"]}Option                     Description                                     Type${EFFECTS["REVERSE_OFF"]}\n\n"
}

function TableBottom() {
    printf " "
    printf "${CHAR_MAP["BOTTOM_LINE"]}%.0s" {1..79}
    printf "\n\n"
}

function ListTop() {
    printf "\n%s - the %s\n\n" "${CONFIG_MAP["APP_SCRIPT"]}" "${CONFIG_MAP["APP_NAME"]}"
    printf "  Usage:  %s [options]\n\n" "${CONFIG_MAP["APP_SCRIPT"]}"
    printf "  Options\n"
}

function ListBottom() {
    printf "\n"
}



############################################################################################
## option print function
## $1: list | table
############################################################################################
PrintOptions() {
    local i
    local keys

    for ID in ${!OPT_DECL_MAP[@]}; do
        if [ -n "$EXIT" ]; then
            if [ -z "${OPT_META_MAP_EXIT[$ID]:-}" ]; then
                continue
            fi
        fi
        if [ -n "$RUNTIME" ]; then
            if [ -z "${OPT_META_MAP_RUNTIME[$ID]:-}" ]; then
                continue
            fi
        fi
        keys=(${keys[@]:-} $ID)
    done
    keys=($(printf '%s\n' "${keys[@]:-}"|sort))

    case $1 in
        list)
            declare -A OPTION_LIST
            FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/opt-list.${CONFIG_MAP["PRINT_MODE"]}
            if [ -n "$PRINT_MODE" ]; then
                FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/opt-list.$PRINT_MODE
            fi
            if [ -f $FILE ]; then
                source $FILE
            fi
            ;;
        table)
            declare -A OPTION_TABLE
            FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/opt-tab.${CONFIG_MAP["PRINT_MODE"]}
            if [ -n "$PRINT_MODE" ]; then
                FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/opt-tab.$PRINT_MODE
            fi
            if [ -f $FILE ]; then
                source $FILE
            fi
            ;;
    esac

    for i in ${!keys[@]}; do
        ID=${keys[$i]}
        case $1 in
            list)
                printf "   "
                if [ -z "${OPTION_LIST[$ID]:-}" ]; then
                    OptionInList $ID $PRINT_MODE
                else
                    printf "${OPTION_LIST[$ID]}"
                fi
                ;;
            table)
                if [ -z "${OPTION_TABLE[$ID]:-}" ]; then
                    OptionInTable $ID $PRINT_MODE
                else
                    printf "${OPTION_TABLE[$ID]}"
                fi
                DescribeOptionStatus $ID $PRINT_MODE
                ;;
        esac
        printf "\n"
    done
}



############################################################################################
##
## ready to go, check CLI
##
############################################################################################
ConsoleInfo "  -->" "lo: starting task"

if [ $LIST == true ]; then
    ListTop
    PrintOptions list
    ListBottom
fi
if [ $TABLE == true ]; then
    TableTop
    PrintOptions table
    TableBottom
fi

ConsoleInfo "  -->" "lo: done"
exit $TASK_ERRORS
