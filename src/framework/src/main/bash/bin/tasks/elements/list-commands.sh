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
## list-command - list command
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##

## put bugs into errors, safer
set -o errexit -o pipefail -o noclobber -o nounset


##
## Test if we are run from parent with configuration
## - load configuration
##
if [[ -z ${FW_HOME:-} || -z ${FW_L1_CONFIG-} ]]; then
    printf " ==> please run from framework or application\n\n"
    exit 10
fi
source $FW_L1_CONFIG
CONFIG_MAP["RUNNING_IN"]="task"


##
## load main functions
## - reset errors and warnings
##
source $FW_HOME/bin/functions/_include
source $FW_HOME/bin/functions/describe/command.sh
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
PRINT_MODE=
LIST=false
TABLE=true



##
## set CLI options and parse CLI
##
CLI_OPTIONS=hlp:t
CLI_LONG_OPTIONS=help,list,print-mode:,table

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name list-commands -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    ConsoleError "  ->" "unknown CLI options"
    exit 1
fi
eval set -- "$PARSED"

PRINT_PADDING=25
while true; do
    case "$1" in
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"        $PRINT_PADDING
            BuildTaskHelpLine l list        "<none>"    "table format"                      $PRINT_PADDING
            BuildTaskHelpLine p print-mode  "MODE"      "print mode: ansi, text, adoc"      $PRINT_PADDING
            BuildTaskHelpLine t table       "<none>"    "help screen format"                $PRINT_PADDING
            exit 0
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
if [[ $LIST == false && $TABLE == false ]]; then
    ConsoleError "  ->" "no mode set: use list and/or table"
    exit 3
fi

declare -A COMMAND_TABLE
FILE=${CONFIG_MAP["CACHE_DIR"]}/cmd-tab.${CONFIG_MAP["PRINT_MODE"]}
if [[ -n "$PRINT_MODE" ]]; then
    FILE=${CONFIG_MAP["CACHE_DIR"]}/cmd-tab.$PRINT_MODE
fi
if [[ -f $FILE ]]; then
    source $FILE
fi


############################################################################################
## top and bottom functions for list and table
############################################################################################
function TableTop() {
    printf "\n "
    for ((x = 1; x < $COLUMNS; x++)); do
        printf %s "${CHAR_MAP["TOP_LINE"]}"
    done
    printf "\n ${EFFECTS["REVERSE_ON"]}Command"
    printf "%*s" "$((CMD_PADDING - 7))" ''
    printf "Description"
    printf '%*s' "$((DESCRIPTION_LENGTH - 11))" ''
    printf "${EFFECTS["REVERSE_OFF"]}\n\n"
}

function TableBottom() {
    printf " "
    for ((x = 1; x < $COLUMNS; x++)); do
        printf %s "${CHAR_MAP["MID_LINE"]}"
    done
    printf "\n\n"

    printf " All other input will be treated as an attempt to run a task with parameters.\n"
    printf " 'list-tasks' or 'lt' for a list of all tasks.\n\n"

    printf " "
    for ((x = 1; x < $COLUMNS; x++)); do
        printf %s "${CHAR_MAP["BOTTOM_LINE"]}"
    done
    printf "\n\n"
}

function ListTop() {
    printf "\n  Shell Commands\n\n"
}

function ListBottom() {
    printf "\n\n  All other input will be treated as an attempt to run a task with parameters.\n"
    printf "  'list-tasks' or 'lt' for a list of all tasks.\n\n"
}



############################################################################################
## command print function
## $1: list | table
############################################################################################
PrintCommands() {
    local i
    local keys

    for i in ${!DMAP_CMD[@]}; do
        keys=(${keys[@]:-} $i)
    done
    keys=($(printf '%s\n' "${keys[@]:-}"|sort))

    for i in ${!keys[@]}; do
        ID=${keys[$i]}
        case $1 in
            list)
                printf "   "
                if [[ -z "${COMMAND_TABLE[$ID]:-}" ]]; then
                    CommandInTable $ID $PRINT_MODE
                else
                    printf "${COMMAND_TABLE[$ID]}"
                fi
                DescribeCommandStatus $ID 3
                ;;
            table)
                if [[ -z "${COMMAND_TABLE[$ID]:-}" ]]; then
                    CommandInTable $ID $PRINT_MODE
                else
                    printf "${COMMAND_TABLE[$ID]}"
                fi
                DescribeCommandStatus $ID
                ;;
        esac
        printf "\n"
    done
}



############################################################################################
##
## ready to go
##
############################################################################################
ConsoleInfo "  -->" "lc: starting task"

if [[ $LIST == true ]]; then
    ListTop
    PrintCommands list
    ListBottom
fi
if [[ $TABLE == true ]]; then
    TableTop
    PrintCommands table
    TableBottom
fi

ConsoleInfo "  -->" "lc: done"
exit $TASK_ERRORS
