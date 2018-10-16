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
## list-parameters - list parameters
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
source $FW_HOME/bin/functions/describe/parameter.sh
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
PRINT_MODE=
TABLE=true
DEFAULT_TABLE=false
REQUESTED=
CLI_SET=false
ALL=



##
## set CLI options and parse CLI
##
CLI_OPTIONS=adhp:r
CLI_LONG_OPTIONS=all,def-table,help,print-mode:,requested

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name list-parameters -- "$@")
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
        -d | --def-table)
            shift
            DEFAULT_TABLE=true
            TABLE=false
            ;;
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine d def-table   "<none>"    "print default value table"                     $PRINT_PADDING
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"                    $PRINT_PADDING
            BuildTaskHelpLine p print-mode  "MODE"      "print mode: ansi, text, adoc"                  $PRINT_PADDING
            printf "\n   filters\n"
            BuildTaskHelpLine a all         "<none>"    "all options, disables all other filters"       $PRINT_PADDING
            BuildTaskHelpLine r requested   "<none>"    "only requested dependencies"                   $PRINT_PADDING
            exit 0
            ;;
        -r | --requested)
            REQUESTED=yes
            CLI_SET=true
            shift
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
## test CLI
############################################################################################
if [[ "$ALL" == "yes" ]]; then
    REQUESTED=
    ALL=
elif [[ $CLI_SET == false ]]; then
    ALL=
fi

for ID in ${!DMAP_PARAM_ORIGIN[@]}; do
    if [[ -n "$REQUESTED" ]]; then
        if [[ -z "${RTMAP_REQUESTED_PARAM[$ID]:-}" ]]; then
            continue
        fi
    fi
    keys=(${keys[@]:-} $ID)
done
keys=($(printf '%s\n' "${keys[@]:-}"|sort))



############################################################################################
##
## function: TABLE
##
############################################################################################
PrintTable() {
    printf "\n "
    printf "${CHAR_MAP["TOP_LINE"]}%.0s" {1..79}
    printf "\n"
    printf " ${EFFECTS["REVERSE_ON"]}Parameter         Description                                             O D S${EFFECTS["REVERSE_OFF"]}\n\n"

    declare -A PARAM_TABLE
    FILE=${CONFIG_MAP["CACHE_DIR"]}/param-tab.${CONFIG_MAP["PRINT_MODE"]}
    if [[ -n "$PRINT_MODE" ]]; then
        FILE=${CONFIG_MAP["CACHE_DIR"]}/param-tab.$PRINT_MODE
    fi
    if [[ -f $FILE ]]; then
        source $FILE
    fi

    for i in ${!keys[@]}; do
        ID=${keys[$i]}
        if [[ -z "${PARAM_TABLE[$ID]:-}" ]]; then
            ParameterInTable $ID $PRINT_MODE
        else
            printf "${PARAM_TABLE[$ID]}"
        fi
        DescribeParameterStatus $ID $PRINT_MODE
        printf "\n"
    done

    printf " "
    printf "${CHAR_MAP["MID_LINE"]}%.0s" {1..79}
    printf "\n\n"

    printf " define parameters in environemnt or '.skb' with prefix: '${CONFIG_MAP["FLAVOR"]}_'"

    printf "\n\n "
    printf "${CHAR_MAP["BOTTOM_LINE"]}%.0s" {1..79}
    printf "\n\n"
}



############################################################################################
##
## function: DEFAULT_TABLE
##
############################################################################################
PrintDefaultTable() {
    printf "\n "
    printf "${CHAR_MAP["TOP_LINE"]}%.0s" {1..79}
    printf "\n"
    printf " ${EFFECTS["REVERSE_ON"]}Parameter         Default Value                                                ${EFFECTS["REVERSE_OFF"]}\n\n"

    declare -A PARAM_TABLE
    FILE=${CONFIG_MAP["CACHE_DIR"]}/param-tab.${CONFIG_MAP["PRINT_MODE"]}
    if [[ -n "$PRINT_MODE" ]]; then
        FILE=${CONFIG_MAP["CACHE_DIR"]}/param-tab.$PRINT_MODE
    fi
    if [[ -f $FILE ]]; then
        source $FILE
    fi

    for i in ${!keys[@]}; do
        SPRINT=""
        ID=${keys[$i]}
        SPRINT+=$(printf " ")
        SPRINT+=$(DescribeParameter $ID standard "none" $PRINT_MODE)

        str_len=$(ParameterStringLength $ID standard "none" text)
        padding=$(( 18 - $str_len ))
        SPRINT=$SPRINT$(printf '%*s' "$padding")
        SPRINT+=$(DescribeParameter $ID default-value "none" $PRINT_MODE)
        printf "$SPRINT\n"
    done

    printf "\n "
    printf "${CHAR_MAP["BOTTOM_LINE"]}%.0s" {1..79}
    printf "\n\n"
}



############################################################################################
##
## ready to go
##
############################################################################################
ConsoleInfo "  -->" "lp: starting task"

if [[ $TABLE == true ]]; then
    PrintTable
else
    PrintDefaultTable
fi

ConsoleInfo "  -->" "lp: done"
exit $TASK_ERRORS
