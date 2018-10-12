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
## describe-option - describe-option
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
OPT_ID=
EXIT=
RUN=
ALL=
CLI_SET=false



##
## set CLI options and parse CLI
##
CLI_OPTIONS=aehi:p:r
CLI_LONG_OPTIONS=all,exit,help,id:,print-mode:,run

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name describe-option -- "$@")
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
            BuildTaskHelpLine a all         "<none>"    "all options, disables all other filters"       $PRINT_PADDING
            BuildTaskHelpLine e exit        "<none>"    "only exit options"                             $PRINT_PADDING
            BuildTaskHelpLine i id          "ID"        "option identifier"                             $PRINT_PADDING
            BuildTaskHelpLine r run         "<none>"    "only runtime options"                          $PRINT_PADDING
            exit 0
            ;;
        -e | --exit)
            EXIT=yes
            CLI_SET=true
            shift
            ;;
        -i | --id)
            OPT_ID="$2"
            CLI_SET=true
            shift 2
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
if [[ ! -n "$PRINT_MODE" ]]; then
    PRINT_MODE=${CONFIG_MAP["PRINT_MODE"]}
fi

if [[ "$ALL" == "yes" ]]; then
    EXIT=yes
    RUN=yes
elif [[ $CLI_SET == false ]]; then
    RUN=yes
else
    if [[ -n "$OPT_ID" ]]; then
        if [[ -z "${DMAP_OPT_ORIGIN[$OPT_ID]:-}" ]]; then
            for SHORT in ${!DMAP_OPT_SHORT[@]}; do
                if [[ "${DMAP_OPT_SHORT[$SHORT]}" == "$OPT_ID" ]]; then
                    OPT_ID=$SHORT
                    break
                fi
            done
        fi

        if [[ -z ${DMAP_OPT_ORIGIN[$OPT_ID]:-} ]]; then
            ConsoleError " ->" "unknown option ID '$OPT_ID'"
            exit 3
        fi
    fi
fi



############################################################################################
##
## ready to go
##
############################################################################################
ConsoleInfo "  -->" "do: starting task"

for ID in ${!DMAP_OPT_ORIGIN[@]}; do
    if [[ -n "$OPT_ID" ]]; then
        if [[ ! "$OPT_ID" == "$ID" ]]; then
            continue
        fi
    fi
    if [[ -n "$EXIT" ]]; then
        if [[ "${DMAP_OPT_ORIGIN[$ID]:-}" != "exit" ]]; then
            continue
        fi
    fi
    if [[ -n "$RUN" ]]; then
        if [[ "${DMAP_OPT_ORIGIN[$ID]:-}" != "run" ]]; then
            continue
        fi
    fi
    keys=(${keys[@]:-} $ID)
done
keys=($(printf '%s\n' "${keys[@]:-}"|sort))

for i in ${!keys[@]}; do
    ID=${keys[$i]}
    DescribeOption $ID full "$PRINT_MODE line-indent" $PRINT_MODE
done

ConsoleInfo "  -->" "do: done"
exit $TASK_ERRORS
