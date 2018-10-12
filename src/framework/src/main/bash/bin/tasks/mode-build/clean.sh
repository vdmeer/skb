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
## clean - removes all created artifacts and folders
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
FORCE=false
SIMULATE=false


##
## set CLI options and parse CLI
##
CLI_OPTIONS=fhs
CLI_LONG_OPTIONS=force,help,simulate

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name clean -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    ConsoleError "  ->" "unknown CLI options"
    exit 1
fi
eval set -- "$PARSED"

PRINT_PADDING=19
while true; do
    case "$1" in
        -f | --force)
            shift
            FORCE=true
            ;;
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine f force       "<none>"    "force mode, not questions asked"                   $PRINT_PADDING
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"                        $PRINT_PADDING
            BuildTaskHelpLine s simulate    "<none>"    "print only, removes nothing, overwrites force"     $PRINT_PADDING
            exit 0
            ;;
        -s | --simulate)
            shift
            SIMULATE=true
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
## ready to go, do clean
##
############################################################################################
ERRNO=0
ConsoleInfo "  -->" "cl: starting task"
for ID in "${!RTMAP_TASK_LOADED[@]}"; do
    case $ID in
        build-* | compile-*)
            ConsoleDebug "cl: run clean on task $ID"
            if [[ $SIMULATE == true ]]; then
                printf "  ${DMAP_TASK_EXEC[$ID]} --clean\n"
            else
                ${DMAP_TASK_EXEC[$ID]} --clean
            fi
            ;;
    esac
done
if [[ -z ${CONFIG_MAP["TARGET"]} ]]; then
    ConsoleDebug "cl: target directory not set"
else
    if [[ -d ${CONFIG_MAP["TARGET"]} ]]; then
        ConsoleDebug "cl: removing target: ${CONFIG_MAP["TARGET"]}"
        if [[ $SIMULATE == true ]]; then
            printf "  rm -fr ${CONFIG_MAP["TARGET"]}\n"
        elif [[ $FORCE == true ]]; then
            rm -fr ${CONFIG_MAP["TARGET"]}
        else
            printf "%s\n" "${CONFIG_MAP["TARGET"]}"
            rm -frI ${CONFIG_MAP["TARGET"]}
        fi
    fi
fi
ConsoleInfo "  -->" "cl: done"
exit $ERRNO
