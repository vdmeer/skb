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
## Functions: config - runtime configuration
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: WriteTmpConfig
## - writes the tmp configuration file
##
WriteTmpConfig() {
    rm ${CONFIG_MAP["FW_TMP_CONFIG"]}
    echo > ${CONFIG_MAP["FW_TMP_CONFIG"]}

    declare -p CONFIG_MAP >> $FW_TMP_CONFIG
    declare -p CONFIG_SRC >> $FW_TMP_CONFIG
    declare -p FW_PATH_MAP >> $FW_TMP_CONFIG
    declare -p APP_PATH_MAP >> $FW_TMP_CONFIG
    declare -p APP_FILE_MAP >> $FW_TMP_CONFIG

    declare -p CHAR_MAP >> $FW_TMP_CONFIG
    declare -p COLORS >> $FW_TMP_CONFIG
    declare -p EFFECTS >> $FW_TMP_CONFIG


    declare -p OPT_DECL_MAP >> $FW_TMP_CONFIG
    declare -p OPT_SHORT_MAP >> $FW_TMP_CONFIG
    declare -p OPT_ARG_MAP >> $FW_TMP_CONFIG
    declare -p OPT_DESCRIPTION_MAP >> $FW_TMP_CONFIG
    declare -p OPT_META_MAP_EXIT >> $FW_TMP_CONFIG
    declare -p OPT_META_MAP_RUNTIME >> $FW_TMP_CONFIG


    declare -p CMD_DECL_MAP >> $FW_TMP_CONFIG
    declare -p CMD_SHORT_MAP >> $FW_TMP_CONFIG
    declare -p CMD_ARG_MAP >> $FW_TMP_CONFIG
    declare -p CMD_DESCRIPTION_MAP >> $FW_TMP_CONFIG


    declare -p PARAM_DECL_MAP >> $FW_TMP_CONFIG
    declare -p PARAM_DECL_DEFVAL >> $FW_TMP_CONFIG
    declare -p PARAM_DESCRIPTION_MAP >> $FW_TMP_CONFIG
    declare -p FILES >> $FW_TMP_CONFIG
    declare -p DIRECTORIES >> $FW_TMP_CONFIG
    declare -p DIRECTORIES_CD >> $FW_TMP_CONFIG


    declare -p DEP_DECL_MAP >> $FW_TMP_CONFIG
    declare -p DEP_DECL_REQ >> $FW_TMP_CONFIG
    declare -p DEP_COMMAND_MAP >> $FW_TMP_CONFIG
    declare -p DEP_DESCRIPTION_MAP >> $FW_TMP_CONFIG

    declare -p TESTED_DEPENDENCIES >> $FW_TMP_CONFIG
    declare -p DEP_STATUS_MAP >> $FW_TMP_CONFIG


    declare -p TASK_DECL_MAP >> $FW_TMP_CONFIG
    declare -p TASK_DECL_EXEC >> $FW_TMP_CONFIG
    declare -p TASK_MODE_MAP >> $FW_TMP_CONFIG
    declare -p TASK_ALIAS_MAP >> $FW_TMP_CONFIG
    declare -p TASK_DESCRIPTION_MAP >> $FW_TMP_CONFIG

    declare -p TASK_REQ_PARAM >> $FW_TMP_CONFIG
    declare -p TASK_REQ_DEP >> $FW_TMP_CONFIG
    declare -p TASK_REQ_TASK >> $FW_TMP_CONFIG
    declare -p TASK_REQ_DIR >> $FW_TMP_CONFIG
    declare -p TASK_REQ_FILE >> $FW_TMP_CONFIG

    declare -p LOADED_TASKS >> $FW_TMP_CONFIG
    declare -p UNLOADED_TASKS >> $FW_TMP_CONFIG
    declare -p TASK_STATUS_MAP >> $FW_TMP_CONFIG
}

