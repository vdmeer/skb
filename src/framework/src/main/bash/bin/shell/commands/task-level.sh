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
## Shell: function for shell command - task-level
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: ShellCmdTaskLevel
## - sets a new shell (console) level
##
ShellCmdTaskLevel() {
    case $SARG in
        all | fatal | error | warn-strict | warn | info | debug | trace)
            CONFIG_MAP["TASK-LEVEL"]=$SARG
            WriteTmpConfig
            printf "  set task level to $SARG and wrote CONFIG_MAP\n"
            ;;
        *)
            ConsoleError " ->" "unknown level '$SARG'"
            ;;
    esac
}
