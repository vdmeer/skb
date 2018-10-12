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
## wait - sleep for specified time
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
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
SECONDS=1



##
## set CLI options and parse CLI
##
CLI_OPTIONS=hs:
CLI_LONG_OPTIONS=help,seconds:

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name wait -- "$@")
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
            BuildTaskHelpLine h help    "<none>"    "print help screen and exit"        $PRINT_PADDING
            BuildTaskHelpLine s seconds "SEC"       "wait SEC seconds, default is 1"    $PRINT_PADDING
            exit 0
            ;;
        -s | --seconds)
            SECONDS="$2"
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
ConsoleInfo "  -->" "wait: starting task"

case $SECONDS in
    '' | *[!0-9.]* | '.' | *.*.*)
        ConsoleError " ->" "wait requires a number, got '$SECONDS'"
        exit 5
        ;;
esac

ConsoleDebug "waiting for $SECONDS seconds"
sleep $SECONDS
# $(echo "$SECONDS-.9" | bc -l)

ConsoleInfo "  -->" "wait: done"
exit $ERRNO
