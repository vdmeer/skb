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
## start-xterm - starts a new XTerm
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
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
COMMAND=bash
ARGS=
TITLE=sx-xterm



##
## set CLI options and parse CLI
##
CLI_OPTIONS=c:ht:
CLI_LONG_OPTIONS=help,command:,title:

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name start-xterm -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    ConsoleError "  ->" "unknown CLI options"
    exit 1
fi
eval set -- "$PARSED"

PRINT_PADDING=22
while true; do
    case "$1" in
        -c | --command)
            COMMAND="$2"
            shift 2
            ;;
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine h help    "<none>"    "print help screen and exit"                    $PRINT_PADDING
            BuildTaskHelpLine t title   "TITLE"     "title for the XTerm, default: command name"    $PRINT_PADDING
            exit 0
            ;;
        -t | --title)
            TITLE="$2"
            shift 2
            ;;

        --)
            shift
            if [[ -z ${1:-} ]]; then
                break
            fi
            COMMAND=$1
            shift
            ARGS=$(printf '%s' "$*")
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
ERRNO=0
ConsoleInfo "  -->" "sx: starting task"

if [[ -z "${CONFIG_MAP["XTERM"]:-}" ]]; then
    ConsoleError "  ->" "no setting for XTERM, cannot start any"
    ConsoleInfo "  -->" "sx: done"
    exit 3
fi

if [[ ! -n "$TITLE" ]]; then
    $TITLE=$COMMAND
fi


SCRIPT=${CONFIG_MAP["XTERM"]}
SCRIPT=${SCRIPT//%COMMAND%/"$COMMAND $ARGS"}
SCRIPT=${SCRIPT//%TITLE%/"$TITLE"}
$SCRIPT &
ERRNO=$?

ConsoleInfo "  -->" "sx: done"
exit $ERRNO
