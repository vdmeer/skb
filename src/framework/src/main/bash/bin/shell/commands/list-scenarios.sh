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
## Shell: function for shell command - list-scenarios
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: ShellCmdListScenarios
## - lists scenarios
##
ShellCmdListScenarios() {
    local FILE
    local DESCRIPTION
    local SPRINT
    local MAX_LEN=0
    local i
    local keys

    declare -A SC_MAP

    if [[ -d ${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["SCENARIOS"]} ]]; then
        for FILE in $(cd ${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["SCENARIOS"]}; find -type f | grep "\.scn"); do
            SPRINT=
            DESCRIPTION=$(cat ${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["SCENARIOS"]}/$FILE | grep Description:)
            DESCRIPTION=${DESCRIPTION#\#// Description: }
            FILE=${FILE#./}
            FILE=${FILE%.*}

            SC_MAP[$FILE]=$DESCRIPTION
            if (( $MAX_LEN < ${#FILE} )); then
                MAX_LEN=${#FILE}
            fi


        done
    fi
    MAX_LEN=$((MAX_LEN + 4))
    for i in ${!SC_MAP[@]}; do
        keys=(${keys[@]:-} $i)
    done
    keys=($(printf '%s\n' "${keys[@]:-}"|sort))

    printf "\n "
    printf "${CHAR_MAP["TOP_LINE"]}%.0s" {1..79}
    printf "\n"
    printf " ${EFFECTS["REVERSE_ON"]}Scenario"
    padding=$(( $MAX_LEN - 8 ))
    printf '%*s' "$padding"
    printf "Description"
    padding=$(( 79 - $MAX_LEN - 8 - -8 - 11 ))
    printf '%*s' "$padding"
    printf "${EFFECTS["REVERSE_OFF"]}\n\n"

    for i in ${keys[@]}; do
        SPRINT=$(printf " $i")
        padding=$(( $MAX_LEN - ${#i} ))
        SPRINT+=$(printf '%*s' "$padding")$DESCRIPTION
        printf "$SPRINT"
    done

    printf "\n "
    printf "${CHAR_MAP["TOP_LINE"]}%.0s" {1..79}
    printf "\n\n"
}
