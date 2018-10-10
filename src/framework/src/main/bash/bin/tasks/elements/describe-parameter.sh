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
## describe-parameter - describe-parameter
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
source $FW_HOME/bin/functions/describe/parameter.sh
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
PRINT_MODE=
PARAM_ID=
DEFAULT=
ORIGIN=
STATUS=
ALL=
CLI_SET=false



##
## set CLI options and parse CLI
##
CLI_OPTIONS=adhi:o:p:s:
CLI_LONG_OPTIONS=all,default,help,id:,origin:,print-mode:,status:

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name describe-parameter -- "$@")
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
        -d | --default)
            DEFAULT=yes
            CLI_SET=true
            shift
            ;;
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"    $PRINT_PADDING
            
            BuildTaskHelpLine p print-mode  "MODE"      "print mode: ansi, text, adoc"  $PRINT_PADDING

            printf "\n   filters\n"
            BuildTaskHelpLine a all         "<none>"    "all parameters, disables all other filters"            $PRINT_PADDING
            BuildTaskHelpLine d default     "<none>"    "only parameters with a defined default value"          $PRINT_PADDING
            BuildTaskHelpLine i id          "ID"        "parameter identifier"                                  $PRINT_PADDING
            BuildTaskHelpLine o origin      "ORIGIN"    "only parameters from origin: f(w), a(pp)"              $PRINT_PADDING
            BuildTaskHelpLine s status      "STATUS"    "only parameter for status: o, f, e, d"                 $PRINT_PADDING

            exit 0
            ;;
        -i | --id)
            PARAM_ID="${2^^}"
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
            shift 2
            ;;
        -s | --status)
            STATUS="$2"
            CLI_SET=true
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
if [ ! -n "$PRINT_MODE" ]; then
    PRINT_MODE=${CONFIG_MAP["PRINT_MODE"]}
fi

if [ "$ALL" == "yes" ] || [ $CLI_SET == false ]; then
    PARAM_ID=
    DEFAULT=
    ORIGIN=
    STATUS=
else
    if [ -n "$PARAM_ID" ]; then
        if [ -z ${PARAM_DECL_MAP[$PARAM_ID]:-} ]; then
            ConsoleError " ->" "unknown parameter: $PARAM_ID"
            exit 3
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
    if [ -n "$STATUS" ]; then
        case $STATUS in
            O | o | option)
                STATUS=O
                ;;
            E | e | env | environment)
                STATUS=E
                ;;
            F | f | file)
                STATUS=F
                ;;
            D | d | default)
                STATUS=D
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
ConsoleInfo "  -->" "dp: starting task"

for ID in ${!PARAM_DECL_MAP[@]}; do
    if [ -n "$PARAM_ID" ]; then
        if [ ! "$PARAM_ID" == "$ID" ]; then
            continue
        fi
    fi
    if [ -n "$DEFAULT" ]; then
        if [ ! -n "${PARAM_DECL_DEFVAL[$PARAM_ID]:-}" ]; then
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
    DescribeParameter $ID full "$PRINT_MODE line-indent" $PRINT_MODE
done

ConsoleInfo "  -->" "dp: done"
exit $TASK_ERRORS
