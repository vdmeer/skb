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
## describe-dependency - describe-dependency
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
if [ -z ${FW_HOME:-} ] || [ -z ${FW_L1_CONFIG-} ]; then
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
DEP_ID=
TESTED=
ORIGIN=
REQUESTED=
STATUS=
ALL=
CLI_SET=false



##
## set CLI options and parse CLI
##
CLI_OPTIONS=ahi:o:p:rs:t
CLI_LONG_OPTIONS=all,help,id:,origin:,print-mode:,status:,tested,requested

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name describe-dependency -- "$@")
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
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"    $PRINT_PADDING
            BuildTaskHelpLine p print-mode  "MODE"      "print mode: ansi, text, adoc"  $PRINT_PADDING
            printf "\n   filters\n"
            BuildTaskHelpLine a all         "<none>"    "all dependencies, disables all other filters"                              $PRINT_PADDING
            BuildTaskHelpLine i id          "ID"        "dependency identifier"                                                     $PRINT_PADDING
            BuildTaskHelpLine o origin      "ORIGIN"    "only dependencies from origin: f(w), a(pp)"                                $PRINT_PADDING
            BuildTaskHelpLine r requested   "<none>"    "only requested dependencies"                                                $PRINT_PADDING
            BuildTaskHelpLine s status      "STATUS"    "only dependencies with status: success, warnings, errors, not attempted"   $PRINT_PADDING
            BuildTaskHelpLine t tested      "<none>"    "only tested dependencies"                                                  $PRINT_PADDING
            exit 0
            ;;
        -i | --id)
            DEP_ID="$2"
            CLI_SET=true
            shift 2
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
if [ ! -n "$PRINT_MODE" ]; then
    PRINT_MODE=${CONFIG_MAP["PRINT_MODE"]}
fi

if [ "$ALL" == "yes" ]; then
    DEP_ID=
    TESTED=
    ORIGIN=
    REQUESTED=
    STATUS=
    ALL=
elif [ $CLI_SET == false ]; then
    TESTED=yes
else
    if [ -n "$DEP_ID" ]; then
        if [ -z ${DMAP_DEP_ORIGIN[$DEP_ID]:-} ]; then
            ConsoleError " ->" "unknown dependency: $DEP_ID"
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
                ConsoleError "  ->" "unknown origin: $ORIGIN"
                exit 3
        esac
    fi
    if [ -n "$STATUS" ]; then
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
ConsoleInfo "  -->" "dd: starting task"

for ID in ${!DMAP_DEP_ORIGIN[@]}; do
    if [ -n "$DEP_ID" ]; then
        if [ ! "$DEP_ID" == "$ID" ]; then
            continue
        fi
    fi
    if [ -n "$REQUESTED" ]; then
        if [ -z "${RTMAP_REQUESTED_DEP[$ID]:-}" ]; then
            continue
        fi
    fi
    if [ -n "$TESTED" ]; then
        if [ -z "${RTMAP_TASK_TESTED[$ID]:-}" ]; then
            continue
        fi
    fi
    if [ -n "$STATUS" ]; then
        case ${RTMAP_DEP_STATUS[$ID]} in
            $STATUS)
                ;;
            *)
                continue
                ;;
        esac
        #=
    fi
    if [ -n "$ORIGIN" ]; then
        if [ ! "$ORIGIN" == "${DMAP_DEP_ORIGIN[$ID]}" ]; then
            continue
        fi
    fi
    keys=(${keys[@]:-} $ID)
done
keys=($(printf '%s\n' "${keys[@]:-}"|sort))

for i in ${!keys[@]}; do
    ID=${keys[$i]}
    DescribeDependency $ID full "$PRINT_MODE line-indent" $PRINT_MODE
done

ConsoleInfo "  -->" "dd: done"
exit $TASK_ERRORS
