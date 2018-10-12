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
## Shell: function for shell command - execute-scenario
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: ShellCmdExecuteScenario
## - executes a scenario
##
ShellCmdExecuteScenario() {
    local SCENARIO=$SARG
    local FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["SCENARIOS"]}/$SARG.scn
    local COUNT=1
    local LENGTH
    local TASK
    local TARG

    if [[ ! -f $FILE ]]; then
        ConsoleError " ->" "did not find scenario $SARG"
        return
    fi

    while IFS='' read -r line || [[ -n "$line" ]]; do
        LENGTH=${#line}
        if [[ "${line:0:1}" != "#" ]] && (( LENGTH > 1 )); then
            ConsoleResetErrors
            SARG="$line"
            ShellCmdExecuteTask
            if ConsoleHasErrors; then
                ConsoleError " ->" "error in line $COUNT of senario $SCENARIO"
                return
            fi
        fi
        COUNT=$(( COUNT + 1 ))
    done < "$FILE"
}
