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
## start-pdfreader - starts a pdfreader with an optional FILE
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
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
FILE=


##
## set CLI options and parse CLI
##
CLI_OPTIONS=hf:
CLI_LONG_OPTIONS=help,file:

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name start-pdf -- "$@")
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
            BuildTaskHelpLine f file    "FILE"      "PDF file to open in reader"        $PRINT_PADDING
            exit 0
            ;;
        -f | --file)
            FILE="$2"
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
ConsoleInfo "  -->" "spdf: starting task"

if [ -z "${CONFIG_MAP["PDF_READER"]:-}" ]; then
    ConsoleError "  ->" "no setting for PDF_READER, cannot start any"
    ConsoleInfo "  -->" "spdf: done"
    exit 3
fi
if [ ! -n "$FILE" ]; then
    ConsoleError "  ->" "empty file? - '$FILE'"
    ConsoleInfo "  -->" "spdf: done"
    exit 4
fi
FILE=$(PathToCygwin $FILE)
if [ ! -r "$FILE" ]; then
    ConsoleError "  ->" "cannot read file '$FILE'"
    ConsoleInfo "  -->" "spdf: done"
    exit 4
fi

SCRIPT=${CONFIG_MAP["PDF_READER"]}
SCRIPT=${SCRIPT//%FILE%/$FILE}
$SCRIPT &
ERRNO=$?

ConsoleInfo "  -->" "spdf: done"
exit $ERRNO
