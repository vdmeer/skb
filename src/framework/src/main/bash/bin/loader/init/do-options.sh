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
## Loader Initialisation: do exit and build options
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: DoOptions
## - do exit/build options
##
DoOptions() {
    local OPTION

    for OPTION in ${!DMAP_OPT_ORIGIN[@]}; do
        if [ "${DMAP_OPT_ORIGIN[$OPTION]}" == "exit" ]; then
            if [ "${OPT_CLI_MAP[$OPTION]}" != false ]; then
                source ${CONFIG_MAP["FW_HOME"]}/bin/loader/options/$OPTION.sh
                if [ ! -n "${OPT_CLI_MAP["execute-task"]}" ]; then
                    DO_EXIT=true
                fi
            fi
        fi
    done
}
