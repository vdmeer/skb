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
source $FW_HOME/bin/functions/describe/command.sh
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
PRINT_MODE=



##
## set CLI options and parse CLI
##
CLI_OPTIONS=hp:
CLI_LONG_OPTIONS=help,print-mode:

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
            BuildTaskHelpLine p print-mode  "MODE"      "print mode: ansi, text, adoc"      $PRINT_PADDING
            exit 0
            ;;
        -p | --print-mode)
            PRINT_MODE="$2"
            shift 2
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
##
## ready to go
##
############################################################################################
ConsoleInfo "  -->" "lc: starting task"

printf "\n "
printf "${CHAR_MAP["TOP_LINE"]}%.0s" {1..79}
printf "\n"
printf " ${EFFECTS["REVERSE_ON"]}Command                         Description                                    ${EFFECTS["REVERSE_OFF"]}\n\n"

for i in ${!CMD_DECL_MAP[@]}; do
    keys=(${keys[@]:-} $i)
done
keys=($(printf '%s\n' "${keys[@]:-}"|sort))

declare -A COMMAND_TABLE
FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/cmd-tab.${CONFIG_MAP["PRINT_MODE"]}
if [ -n "$PRINT_MODE" ]; then
    FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/cmd-tab.$PRINT_MODE
fi
if [ -f $FILE ]; then
    source $FILE
fi

for i in ${!keys[@]}; do
    ID=${keys[$i]}
    if [ -z "${COMMAND_TABLE[$ID]:-}" ]; then
        CommandInTable $ID $PRINT_MODE
    else
        printf "${COMMAND_TABLE[$ID]}"
    fi
#     DescribeCommandStatus $ID $PRINT_MODE
    printf "\n"
done

printf " "
printf "${CHAR_MAP["MID_LINE"]}%.0s" {1..79}
printf "\n\n"

printf " All other input will be treated as an attempt to run a task with parameters.\n"
printf " 'list-tasks' or 'lt' for a list of all tasks.\n\n"

printf " "
printf "${CHAR_MAP["BOTTOM_LINE"]}%.0s" {1..79}
printf "\n\n"

ConsoleInfo "  -->" "lc: done"
exit $TASK_ERRORS
