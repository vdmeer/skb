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
## Declare: (Shell) commands
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


declare -A CMD_DECL_MAP             # map/internal for long command, [id]="longcommand"
declare -A CMD_SHORT_MAP            # map/internal for short command, [id]='o' - not set if none
declare -A CMD_ARG_MAP              # map/internal for argument, [id]="argument" - not set if none
declare -A CMD_DESCRIPTION_MAP      # map/internal for argument, [id]="argument" - not set if none



##
## function: DeclareCommandsOrigin
## - declares Shell commands from FW_HOME directory
##
DeclareCommandsOrigin() {
    if [ ! -d $FW_HOME/${FW_PATH_MAP["COMMANDS"]} ]; then
        ConsoleError " ->" "declare-cmd - did not find command directory, tried \$FW_HOME/${FW_PATH_MAP["COMMANDS"]}"
        ConsoleInfo "-->" "done"
    else
        ConsoleDebug "building new declaration map from directory: \$FW_HOME/${FW_PATH_MAP["COMMANDS"]}"
        ConsoleResetErrors

        local file
        local ID
        local COMMAND
        local SHORT
        local ARGUMENT
        local DESCRIPTION
        local NO_ERRORS=true

        for file in $(cd $FW_HOME/${FW_PATH_MAP["COMMANDS"]}; find -type f | grep "\.id"); do
            ID=${file##*/}
            ID=${ID%.*}

            if [ ! -z ${CMD_DECL_MAP[$ID]:-} ]; then
                ConsoleError " ->" "internal error: CMD_DECL_MAP for id '$ID' already set"
            else
                local HAVE_ERRORS=false

                SHORT=
                ARGUMENT=
                DESCRIPTION=
                source $FW_HOME/${FW_PATH_MAP["COMMANDS"]}/$file

                if [ -z "${DESCRIPTION:-}" ]; then
                    ConsoleError " ->" "declare command - command '$ID' has no description"
                    HAVE_ERRORS=true
                fi

                if [ $HAVE_ERRORS == true ]; then
                    ConsoleError " ->" "declare command - could not declare command"
                    NO_ERRORS=false
                else
                    CMD_DECL_MAP[$ID]=$ID
                    CMD_SHORT_MAP[$ID]=$SHORT
                    CMD_ARG_MAP[$ID]=$ARGUMENT
                    CMD_DESCRIPTION_MAP[$ID]=$DESCRIPTION
                    ConsoleDebug "declared command $ID"
                fi
            fi
        done
    fi
}



##
## function: DeclareCommands
## - declares commands from FW_HOME
##
DeclareCommands() {
    ConsoleInfo "-->" "declare commands"
    ConsoleResetErrors

    DeclareCommandsOrigin
}
