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
## Shell: function for shell command - history
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: ShellAddCmdHistory
## - adds a command to the shell history
##
ShellAddCmdHistory() {
    local HSIZE=${#HISTORY[@]}
    HISTORY[$HSIZE]=$STIME":::"$SCMD
}



##
## function: ShellCmdHistory
## - process shell command history
## - just '!' to show history, '!!' run last command, '!N' | '! N' run Nth command
##
ShellCmdHistory() {
    local CMD="${SARG#"${SARG%%[![:space:]]*}"}"

    local HTIME
    local HCMD
    local NUMBER

    local HSIZE=$(( ${#HISTORY[@]} -1 ))

    if [[ "!" == "$CMD" ]]; then
        ## '!!', run last history command
        if [[ "$HSIZE" == "0" ]]; then
            printf "\n  history is empty\n\n"
        else
            NUMBER=$(( ${#HISTORY[@]} -1 ))
            SCMD=${HISTORY[$NUMBER]#*:::}
            FWInterpreter
        fi
    elif [[ -n "$CMD" ]]; then
        ## something in the command, check
        if [[ ! -z "${HISTORY[$CMD]:-}" ]]; then
            SCMD=${HISTORY[$CMD]#*:::}
            FWInterpreter
        else
            printf "\n  no history found for '%s'\n\n" "$CMD"
        fi
    else
        ## empty string, print the history
        printf "\n  history with %s commands\n\n" "$HSIZE"

        local i
        local padding
        local keys
        for i in ${!HISTORY[@]}; do
            if [[ "$i" != "-1" ]]; then
                padding=$(printf "%03d\n" $i)
                keys=(${keys[@]:-} $padding)
            fi
        done
        keys=($(printf '%s\n' "${keys[@]:-}"|sort))
        for i in ${!keys[@]}; do
            NUMBER=${keys[$i]}
            NUMBER=$((10#$NUMBER))
            HTIME=${HISTORY[$NUMBER]%:::*}
            HCMD=${HISTORY[$NUMBER]#*:::}
            printf "    %4d  %s  %s\n" "$NUMBER" "$HTIME" "$HCMD"
        done
        printf "\n"
    fi
}
