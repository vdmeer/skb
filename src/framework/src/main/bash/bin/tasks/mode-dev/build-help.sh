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
## build-help - builds help files for loader and shell
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
source $FW_HOME/bin/functions/describe/_include
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##



##
## set CLI options and parse CLI
##
CLI_OPTIONS=h
CLI_LONG_OPTIONS=help

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name build-cache -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    ConsoleError "  ->" "unknown CLI options"
    exit 1
fi
eval set -- "$PARSED"

PRINT_PADDING=19
while true; do
    case "$1" in
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine h help    "<none>"    "print help screen and exit"                        $PRINT_PADDING
            exit 0
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
ConsoleInfo "  -->" "bdh: starting task"
ConsoleResetErrors


PRINT_MODES="ansi text"
ConsoleInfo "  -->" "build help for options and commands"

if [[ ! -d "${CONFIG_MAP["FW_HOME"]}/etc" ]]; then
    ConsoleError " ->" "\$FW_HOME/etc does not exist"
fi

ConsoleDebug "target: command help"
if [[ ! -z "${RTMAP_TASK_LOADED["list-commands"]}" ]]; then
    for MODE in $PRINT_MODES; do
        FILE=${CONFIG_MAP["FW_HOME"]}/etc/command-help.$MODE
            if [[ -f $FILE ]]; then
            rm $FILE
        fi
        set +e
        ${DMAP_TASK_EXEC["list-commands"]} -l -p $MODE > ${CONFIG_MAP["FW_HOME"]}/etc/command-help.$MODE
        set -e
    done
else
    ConsoleError " ->" "cmd-list: did not find task 'list-commands', not loaded?"
fi

ConsoleDebug "target: ooption help"
if [[ ! -z "${RTMAP_TASK_LOADED["list-options"]}" ]]; then
    for MODE in $PRINT_MODES; do
        FILE=${CONFIG_MAP["FW_HOME"]}/etc/option-help.$MODE
        if [[ -f $FILE ]]; then
            rm $FILE
        fi
        set +e
        ${DMAP_TASK_EXEC["list-options"]} -a -l -p $MODE > ${CONFIG_MAP["FW_HOME"]}/etc/option-help.$MODE
        set -e
    done
else
    ConsoleError " ->" "opt-list: did not find task 'list-options', not loaded?"
fi

ConsoleInfo "  -->" "bdh: done"
exit $TASK_ERRORS
