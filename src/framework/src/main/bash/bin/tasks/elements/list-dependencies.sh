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
## list-dependencies - list dependencies
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
source $FW_HOME/bin/functions/describe/dependency.sh
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
PRINT_MODE=
TESTED=
ORIGIN=
REQUESTED=
STATUS=
ALL=
CLI_SET=false



##
## set CLI options and parse CLI
##
CLI_OPTIONS=aho:p:rs:t
CLI_LONG_OPTIONS=all,help,origin:,print-mode:,requested,status:,tested

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name list-dependencies -- "$@")
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
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"                    $PRINT_PADDING
            BuildTaskHelpLine p print-mode  "MODE"      "print mode: ansi, text, adoc"                  $PRINT_PADDING
            printf "\n   filters\n"
            BuildTaskHelpLine a all         "<none>"    "all dependencies, disables all other filters"                              $PRINT_PADDING
            BuildTaskHelpLine o origin      "ORIGIN"    "only dependencies from origin: f(w), a(pp)"                                $PRINT_PADDING
            BuildTaskHelpLine r requested   "<none>"    "only requested dependencies"                                                $PRINT_PADDING
            BuildTaskHelpLine s status      "STATUS"    "only dependencies with status: success, warnings, errors, not attempted"   $PRINT_PADDING
            BuildTaskHelpLine t tested      "<none>"    "only tested dependencies"                                                  $PRINT_PADDING
            exit 0
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
        -r | --requested)
            REQUESTED=yes
            CLI_SET=true
            shift
            ;;
        -s | --status)
            STATUS="$2"
            CLI_SET=true
            shift 2
            ;;
        -t | --tested)
            TESTED=yes
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
if [[ "$ALL" == "yes" ]]; then
    TESTED=
    ORIGIN=
    STATUS=
    REQUESTED=
    ALL=
elif [[ $CLI_SET == false ]]; then
    TESTED=
else
    if [[ -n "$ORIGIN" ]]; then
        case $ORIGIN in
            F| f | fw | framework)
                ORIGIN=FW_HOME
                ;;
            A | a | app | application)
                ORIGIN=${CONFIG_MAP["FLAVOR"]}_HOME
                ;;
            *)
                ConsoleError "  ->" "unknown origin: $ORIGIN"
                exit 3
        esac
    fi
    if [[ -n "$STATUS" ]]; then
        case $STATUS in
            S | s | success)
                STATUS=S
                ;;
            E | e | errors | error)
                STATUS=E
                ;;
            W | w | warnings | warning)
                STATUS=W
                ;;
            N | n | not-attepmted)
                STATUS=N
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
ConsoleInfo "  -->" "ld: starting task"

printf "\n "
printf "${CHAR_MAP["TOP_LINE"]}%.0s" {1..79}
printf "\n"
printf " ${EFFECTS["REVERSE_ON"]}Dependency          Description                                             O S${EFFECTS["REVERSE_OFF"]}\n\n"

for ID in ${!DMAP_DEP_ORIGIN[@]}; do
    if [[ -n "$REQUESTED" ]]; then
        if [[ -z "${RTMAP_REQUESTED_DEP[$ID]:-}" ]]; then
            continue
        fi
    fi
    if [[ -n "$TESTED" ]]; then
        if [[ -z "${RTMAP_TASK_TESTED[$ID]:-}" ]]; then
            continue
        fi
    fi
    if [[ -n "$STATUS" ]]; then
        case ${RTMAP_DEP_STATUS[$ID]} in
            $STATUS)
                ;;
            *)
                continue
                ;;
        esac
        #=
    fi
    if [[ -n "$ORIGIN" ]]; then
        if [[ ! "$ORIGIN" == "${DMAP_DEP_ORIGIN[$ID]}" ]]; then
            continue
        fi
    fi
    keys=(${keys[@]:-} $ID)
done
keys=($(printf '%s\n' "${keys[@]:-}"|sort))


declare -A DEP_TABLE
FILE=${CONFIG_MAP["CACHE_DIR"]}/dep-tab.${CONFIG_MAP["PRINT_MODE"]}
if [[ -n "$PRINT_MODE" ]]; then
    FILE=${CONFIG_MAP["CACHE_DIR"]}/dep-tab.$PRINT_MODE
fi
if [[ -f $FILE ]]; then
    source $FILE
fi

for i in ${!keys[@]}; do
    ID=${keys[$i]}
    if [[ -z "${DEP_TABLE[$ID]:-}" ]]; then
        DependencyInTable $ID $PRINT_MODE
    else
        printf "${DEP_TABLE[$ID]}"
    fi
    DescribeDependencyStatus $ID $PRINT_MODE
    printf "\n"
done

printf " "
printf "${CHAR_MAP["MID_LINE"]}%.0s" {1..79}
printf "\n\n"

printf " flags: (O) origin, (S) status\n"

printf " colors: "
PrintColor light-green ${CHAR_MAP["LEGEND"]}
printf " success, "
PrintColor light-blue ${CHAR_MAP["LEGEND"]}
printf " not attempted, "
PrintColor light-red ${CHAR_MAP["LEGEND"]}
printf " errors"

printf "\n\n "
printf "${CHAR_MAP["BOTTOM_LINE"]}%.0s" {1..79}
printf "\n\n"

ConsoleInfo "  -->" "ld: done"
exit $TASK_ERRORS
