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
## Loader Initialisation: process settings
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##



##
## function: ProcessShellPromptLength
## - special treatment for shell prompt for length
##
ProcessShellPromptLength() {
    local TMP_PRINT_MODE=${CONFIG_MAP["PRINT_MODE"]}
    CONFIG_MAP["PRINT_MODE"]=text

    local ENV_KEY=${CONFIG_MAP["FLAVOR"]}_SHELL_PROMPT
    local SPROMPT
    case ${CONFIG_SRC["SHELL_PROMPT"]} in
        E)
            SPROMPT="${!ENV_KEY:-}"
            CONFIG_MAP["PROMPT_LENGTH"]=${#SPROMPT}
            ;;
        F)
            source ${CONFIG_MAP["CONFIG_FILE"]}
            SPROMPT="${!ENV_KEY:-}"
            CONFIG_MAP["PROMPT_LENGTH"]=${#SPROMPT}
            ;;
        D)
            SPROMPT=${DMAP_PARAM_DEFVAL["SHELL_PROMPT"]}
            CONFIG_MAP["PROMPT_LENGTH"]=${#SPROMPT}
            ;;
    esac

    CONFIG_MAP["PRINT_MODE"]=$TMP_PRINT_MODE
}



##
## function: ProcessSettingsEnvironment
## - process settings: envrironment
##
ProcessSettingsEnvironment() {
    ConsoleInfo "-->" "process settings: environment for flavor ${CONFIG_MAP["FLAVOR"]}"
    local ENV_KEY
    local KEY

    for KEY in "${!DMAP_PARAM_ORIGIN[@]}"; do
        ENV_KEY=${CONFIG_MAP["FLAVOR"]}_$KEY
        if [ ! -z "${!ENV_KEY:-}" ]; then
            if [ ! -z ${CONFIG_MAP[$KEY]:-} ]; then
                ConsoleWarn "    >" "overwriting $KEY"
            fi
            CONFIG_MAP[$KEY]="${!ENV_KEY}"
            CONFIG_SRC[$KEY]="E"
            ConsoleDebug "set $KEY = '${CONFIG_MAP[$KEY]}'"
        fi
    done
    ConsoleInfo "-->" "done"
}



##
## function: ProcessSettingsConfig
## - process settings: USER/.skb
##
ProcessSettingsConfig() {
    ConsoleInfo "-->" "process settings: ${CONFIG_MAP["CONFIG_FILE"]} for flavor ${CONFIG_MAP["FLAVOR"]}"
    local ENV_KEY
    local KEY

    if [ -f ${CONFIG_MAP["CONFIG_FILE"]} ]; then
        source ${CONFIG_MAP["CONFIG_FILE"]}
        for KEY in "${!DMAP_PARAM_ORIGIN[@]}"; do
            ENV_KEY=${CONFIG_MAP["FLAVOR"]}_$KEY
            if [ ! -z "${!ENV_KEY:-}" ]; then
                if [ -z "${CONFIG_MAP[$KEY]:-}" ]; then
                    CONFIG_MAP[$KEY]="${!ENV_KEY}"
                    CONFIG_SRC[$KEY]="F"
                    ConsoleDebug "set $KEY = '${CONFIG_MAP[$KEY]}'"
                fi
            fi
        done
    else
        ConsoleWarn "    >" "did not find config file, tried ${CONFIG_MAP["CONFIG_FILE"]}"
    fi
    ConsoleInfo "-->" "done"
}



##
## function: ProcessSettingsDefault
## - process settings: default values
##
ProcessSettingsDefault() {
    ConsoleInfo "-->" "process settings: default values"
    local DEFAULT_VALUE
    local KEY

    for KEY in "${!DMAP_PARAM_DEFVAL[@]}"; do
        if [ -n "$KEY" ]; then
            DEFAULT_VALUE=${DMAP_PARAM_DEFVAL[$KEY]}
            if [ ! -z ${DEFAULT_VALUE:-} ] && [ -z "${CONFIG_MAP[$KEY]:-}" ]; then
                CONFIG_MAP[$KEY]="$DEFAULT_VALUE"
                CONFIG_SRC[$KEY]="D"
                ConsoleDebug "set $KEY = '${CONFIG_MAP[$KEY]}'"
            fi
        fi
    done
    ConsoleInfo "-->" "done"
}



##
## function: ProcessSettings
## - process all settings
##
ProcessSettings() {
    ProcessSettingsEnvironment
    ProcessSettingsConfig
    ProcessSettingsDefault
    ProcessShellPromptLength
}
