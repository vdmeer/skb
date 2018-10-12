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
## repeat-scenario - repeats a scenario
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
TIMES=1
SCENARIO=
WAIT=1



##
## set CLI options and parse CLI
##
CLI_OPTIONS=hs:t:
CLI_LONG_OPTIONS=help,scenario:,times:

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name repeat-scenario -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    ConsoleError "  ->" "unknown CLI options"
    exit 1
fi
eval set -- "$PARSED"

PRINT_PADDING=27
while true; do
    case "$1" in
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"        $PRINT_PADDING
            BuildTaskHelpLine s scenario    SCENARIO    "the scenario to repeat"            $PRINT_PADDING
            BuildTaskHelpLine t times       INT         "repeat INT times"                  $PRINT_PADDING
            BuildTaskHelpLine w wait        SEC         "wait SEC seconds between repeats"  $PRINT_PADDING
            exit 0
            ;;
        -s | --scenario)
            SCENARIO="$2"
            shift 2
            ;;
        -t | --times)
            TIMES="$2"
            shift 2
            ;;
        -w | --wait)
            WAIT="$2"
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
ERRNO=0
ConsoleInfo "  -->" "rs: starting task"

if [[ -z $SCENARIO ]]; then
    ConsoleError "  ->" "a scenario is required"
    exit 3
fi

FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["SCENARIOS"]}/$SCENARIO.scn
if [[ ! -f $FILE ]]; then
    ConsoleError " ->" "did not find scenario $SCENARIO"
    return
fi

case $TIMES in
    '' | *[!0-9.]* | '.' | *.*.*)
        ConsoleError " ->" "repeat times requires a number, got '$TIMES'"
        exit 5
        ;;
esac

case $WAIT in
    '' | *[!0-9.]* | '.' | *.*.*)
        ConsoleError " ->" "wait requires a number, got '$WAIT'"
        exit 5
        ;;
esac

source ${CONFIG_MAP["FW_HOME"]}/bin/shell/commands/execute-scenario.sh
source ${CONFIG_MAP["FW_HOME"]}/bin/shell/commands/execute-task.sh

for (( _repeat=1; _repeat<=$TIMES; _repeat++ )); do
    printf "\n\n    ["
    PrintColor light-blue "run $_repeat of $TIMES"
    printf ' %s %s' "--" $SCENARIO
    printf "]\n    "
    printf "${CHAR_MAP["MID_LINE"]}%.0s" {1..76}
    printf "\n\n"
    SARG=$SCENARIO
    ShellCmdExecuteScenario
    sleep $WAIT
    printf "\n"
done

ConsoleInfo "  -->" "rs: done"
exit $ERRNO
