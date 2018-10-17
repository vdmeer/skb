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
RUN=
ALL=
CLI_SET=false



##
## set CLI options and parse CLI
##
CLI_OPTIONS=aehlp:rt
CLI_LONG_OPTIONS=all,exit,help,list,print-mode:,run,table

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
            BuildTaskHelpLine r run         "<none>"    "only runtime options"                          $PRINT_PADDING
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
        -r | --run)
            RUN=yes
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
if [[ $LIST == false && $TABLE == false ]]; then
    ConsoleError "  ->" "no mode set: use list and/or table"
    exit 3
fi

if [[ "$ALL" == "yes" ]]; then
    EXIT=yes
    RUN=yes
elif [[ $CLI_SET == false ]]; then
    EXIT=yes
    RUN=yes
fi

declare -A OPTION_TABLE
FILE=${CONFIG_MAP["CACHE_DIR"]}/opt-tab.${CONFIG_MAP["PRINT_MODE"]}
if [[ -n "$PRINT_MODE" ]]; then
    FILE=${CONFIG_MAP["CACHE_DIR"]}/opt-tab.$PRINT_MODE
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
    printf "\n ${EFFECTS["REVERSE_ON"]}Option"
    printf "%*s" "$((OPT_PADDING - 6))" ''
    printf "Description"
    printf '%*s' "$((DESCRIPTION_LENGTH - 11))" ''
    printf "Type${EFFECTS["REVERSE_OFF"]}\n\n"
}

function TableBottom() {
    printf " "
    for ((x = 1; x < $COLUMNS; x++)); do
        printf %s "${CHAR_MAP["BOTTOM_LINE"]}"
    done
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

    for ID in ${!DMAP_OPT_ORIGIN[@]}; do
        if [[ -n "$EXIT" &&-n "$RUN" ]]; then
            :
        elif [[ -n "$EXIT" ]]; then
            if [[ "${DMAP_OPT_ORIGIN[$ID]}" != "exit" ]]; then
                continue
            fi
        elif [[ -n "$RUN" ]]; then
            if [[ "${DMAP_OPT_ORIGIN[$ID]}" != "run" ]]; then
                continue
            fi
        fi
        keys=(${keys[@]:-} $ID)
    done
    keys=($(printf '%s\n' "${keys[@]:-}"|sort))

    for i in ${!keys[@]}; do
        ID=${keys[$i]}
        case $1 in
            list)
                printf "   "
                if [[ -z "${OPTION_TABLE[$ID]:-}" ]]; then
                    OptionInTable $ID $PRINT_MODE
                else
                    printf "${OPTION_TABLE[$ID]}"
                fi
                DescribeOptionDescription $ID 3
                ;;
            table)
                if [[ -z "${OPTION_TABLE[$ID]:-}" ]]; then
                    OptionInTable $ID $PRINT_MODE
                else
                    printf "${OPTION_TABLE[$ID]}"
                fi
                DescribeOptionDescription $ID
                DescribeOptionStatus $ID
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

if [[ $LIST == true ]]; then
    ListTop
    PrintOptions list
    ListBottom
fi
if [[ $TABLE == true ]]; then
    TableTop
    PrintOptions table
    TableBottom
fi

ConsoleInfo "  -->" "lo: done"
exit $TASK_ERRORS
