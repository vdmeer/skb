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
## function: WriteL1Config
## - writes level 1 configuration file
##
WriteL1Config() {
    local file=${CONFIG_MAP["FW_L1_CONFIG"]}
    rm $file
    echo > $file

    declare -p CONFIG_MAP >> $file
    declare -p CONFIG_SRC >> $file
    declare -p FW_PATH_MAP >> $file
    declare -p APP_PATH_MAP >> $file

    declare -p CHAR_MAP >> $file
    declare -p COLORS >> $file
    declare -p EFFECTS >> $file


    declare -p DMAP_OPT_ORIGIN >> $file
    declare -p DMAP_OPT_SHORT >> $file
    declare -p DMAP_OPT_ARG >> $file


    declare -p DMAP_CMD >> $file
    declare -p DMAP_CMD_SHORT >> $file
    declare -p DMAP_CMD_ARG >> $file


    declare -p DMAP_PARAM_ORIGIN >> $file
    declare -p DMAP_PARAM_DECL >> $file
    declare -p DMAP_PARAM_DEFVAL >> $file
    declare -p DMAP_PARAM_DESCR >> $file


    declare -p DMAP_DEP_ORIGIN >> $file
    declare -p DMAP_DEP_DECL >> $file
    declare -p DMAP_DEP_REQ_DEP >> $file
    declare -p DMAP_DEP_CMD >> $file

    declare -p RTMAP_TASK_TESTED >> $file
    declare -p RTMAP_DEP_STATUS >> $file


    declare -p DMAP_TASK_ORIGIN >> $file
    declare -p DMAP_TASK_DECL >> $file
    declare -p DMAP_TASK_SHORT >> $file
    declare -p DMAP_TASK_EXEC >> $file
    declare -p DMAP_TASK_DESCR >> $file
    declare -p DMAP_TASK_MODES >> $file

    declare -p DMAP_TASK_REQ_PARAM_MAN >> $file
    declare -p DMAP_TASK_REQ_PARAM_OPT >> $file
    declare -p DMAP_TASK_REQ_DEP_MAN >> $file
    declare -p DMAP_TASK_REQ_DEP_OPT >> $file
    declare -p DMAP_TASK_REQ_TASK_MAN >> $file
    declare -p DMAP_TASK_REQ_TASK_OPT >> $file
    declare -p DMAP_TASK_REQ_DIR_MAN >> $file
    declare -p DMAP_TASK_REQ_DIR_OPT >> $file
    declare -p DMAP_TASK_REQ_FILE_MAN >> $file
    declare -p DMAP_TASK_REQ_FILE_OPT >> $file

    declare -p RTMAP_TASK_STATUS >> $file
    declare -p RTMAP_TASK_LOADED >> $file
    declare -p RTMAP_TASK_UNLOADED >> $file

    declare -p FILES >> $file
    declare -p DIRECTORIES >> $file
    declare -p DIRECTORIES_CD >> $file

    declare -p RTMAP_REQUESTED_DEP >> $file
    declare -p RTMAP_REQUESTED_PARAM >> $file

    declare -p DMAP_CMD_DESCR >> $file
    declare -p DMAP_DEP_DESCR >> $file
    declare -p DMAP_OPT_DESCR >> $file
    declare -p DMAP_PARAM_DESCR >> $file
}
