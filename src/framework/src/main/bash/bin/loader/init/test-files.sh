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
## Loader Initialisation: test files
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: TestFiles
## -test all parameters and settings declared as file
##
TestFiles() {
    ConsoleInfo "-->" "test files"
    local FILE

    for FILE in ${FILES[@]}; do
        if [ -z ${CONFIG_MAP[$FILE]:-} ]; then
            ConsoleWarn "    >" "value for parameter '$FILE' not set"
        else
            if [ ! -f ${CONFIG_MAP[$FILE]} ]; then
                ConsoleError "-> test files:" "not a regular file for parameter '$FILE' as '${CONFIG_MAP[$FILE]}'"
            fi
            if [ ! -r ${CONFIG_MAP[$FILE]} ]; then
                ConsoleError "-> test files:" "file not readable for parameter '$FILE' as '${CONFIG_MAP[$FILE]}'"
            fi
        fi
    done
    ConsoleInfo "-->" "done"
}

