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
## Loader Initialisation: test directories
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: TestReadDirectories
## -test all parameters and settings declared as directories
##
TestReadDirectories() {
    ConsoleInfo "-->" "test read directories"
    local DIR

    for DIR in ${DIRECTORIES[@]}; do
        if [ -z ${CONFIG_MAP[$DIR]:-} ]; then
            ConsoleWarn "    >" "value for $DIR not set"
        else
            if [ ! -d ${CONFIG_MAP[$DIR]} ]; then
                ConsoleError "-> test directories:" "not a redable directory for $DIR as ${CONFIG_MAP[$DIR]}"
            fi
        fi
    done
    ConsoleInfo "-->" "done"
}



##
## function: TestCDDirectories
## -test all parameters and settings declared as directory
##
TestCDDirectories() {
    ConsoleInfo "-->" "test create/delete directories"
    local DIR
    local MD_OPT="-p"
    local MD_ERR

    for DIR in ${DIRECTORIES_CD[@]}; do
        if [ -z ${CONFIG_MAP[$DIR]:-} ]; then
            ConsoleWarn "    >" "value for $DIR not set"
        else
            if ConsoleIsDebug; then MD_OPT="$MD_OPT -v"; fi
            mkdir $MD_OPT ${CONFIG_MAP[$DIR]} 2> /dev/null
            MD_ERR=$?
            if (( $MD_ERR != 0 )) || [ ! -d ${CONFIG_MAP[$DIR]} ]; then
                ConsoleError "-> test directories:" "not a directory for $DIR as ${CONFIG_MAP[$DIR]}, tried mkdir"
            fi
        fi
    done
    ConsoleInfo "-->" "done"
}



##
## function: TestDirectories
## -test all parameters and settings declared as directory
##
TestDirectories() {
    TestReadDirectories
    TestCDDirectories
}
