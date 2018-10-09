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
## Shell: function for shell command - help
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: ShellCmdHelp
## - print command help screen
##
ShellCmdHelp() {
    local CMD_SCREEN_MAP
    local file=$FW_HOME/${FW_FILE_MAP["CMD_SCREEN"]}
    if [ ! -f $file ]&& [ ! -r $file ]; then
        ConsoleError " ->" "did not find map file, tried \$FW_HOME/${FW_FILE_MAP["CMD_SCREEN"]}"
        return
    else
        source $file
    fi

    printf "\n  Commands\n"

    local i
    local keys
    for i in ${!CMD_SCREEN_MAP[@]}; do
        keys=(${keys[@]:-} $i)
    done
    keys=($(printf '%s\n' "${keys[@]:-}"|sort))
    for i in ${!keys[@]}; do
        printf "    ${CMD_SCREEN_MAP[${keys[$i]}]}\n"
    done

    printf " "
    printf "${CHAR_MAP["MID_LINE"]}%.0s" {1..79}
    printf "\n\n"

    printf " All other input will be treated as an attempt to run a task with parameters.\n\n"

    printf "\n\n"
}
