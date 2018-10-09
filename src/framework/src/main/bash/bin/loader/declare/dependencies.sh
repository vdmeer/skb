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
## Declare: dependencies
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


declare -A DEP_DECL_MAP             # map/export for dependency declarations: [id]="CFG:::file.sh", CFG used as origin, i.e. FW_HOME or HOME
declare -A DEP_DECL_REQ             # map/export for decl dep: [id]="requires other deps"
declare -A DEP_COMMAND_MAP          # map/export for dependency commands: [id]="tag-line"
declare -A DEP_DESCRIPTION_MAP      # map/export for dependency descriptions: [id]="tag-line"
declare -A DEP_STATUS_MAP           # map/export for dependency status: [id]=[N]ot-done, [S]uccess, [W]arning(s), [E]rrors

declare -A TESTED_DEPENDENCIES      # array/export for tested dependencies


##
## set dummies for the runtime maps, declare errors otherwise
##
TESTED_DEPENDENCIES["DUMMY"]=dummy



##
## function: DeclareDependenciesOrigin
## - declares dependencies from origin
## $1: origin, CONFIG_MAP identifier, i.e. FW_HOME or HOME
##
DeclareDependenciesOrigin() {
    local ORIGIN=$1

    ConsoleDebug "scanning $ORIGIN"
    local DEPENDENCY_PATH=${CONFIG_MAP[$ORIGIN]}/${APP_PATH_MAP["DEP_DECL"]}
    if [ ! -d $DEPENDENCY_PATH ]; then
        ConsoleError " ->" "declare dependency - did not find dependency directory '$DEPENDENCY_PATH' at origin '$ORIGIN'"
    else
        local NO_ERRORS=true
        local ID
        local COMMAND
        local DESCRIPTION
        local REQUIRES
        local files
        local file

        files=$(find -P $DEPENDENCY_PATH -type f -name '*.id')
        if [ -n "$files" ]; then
            for file in $files; do
                ID=${file##*/}
                ID=${ID%.*}

                local HAVE_ERRORS=false

                COMMAND=
                DESCRIPTION=
                REQUIRES=
                source "$file"

                if [ -z "${DESCRIPTION:-}" ]; then
                    ConsoleError " ->" "declare dependency - dependency '$ID' has no description"
                    HAVE_ERRORS=true
                fi

                if [ -z "${COMMAND:-}" ]; then
                    ConsoleError " ->" "declare dependency - dependency '$ID' has no command to test"
                    HAVE_ERRORS=true
                fi

                if [ -z "${REQUIRES:-}" ]; then
                    REQUIRES=""
                fi

                if [ ! -z ${DEP_DECL_MAP[$ID]:-} ]; then
                    ConsoleError "    >" "overwriting ${DEP_DECL_MAP[$ID]%:::*}:::$ID with $ORIGIN:::$ID"
                    HAVE_ERRORS=true
                fi
                if [ $HAVE_ERRORS == true ]; then
                    ConsoleError " ->" "declare dependency - could not declare dependency"
                    NO_ERRORS=false
                else
                    DEP_DECL_MAP[$ID]="$ORIGIN:::${file%.*}"
                    DEP_DECL_REQ[$ID]=$REQUIRES
                    DEP_DESCRIPTION_MAP[$ID]=$DESCRIPTION
                    DEP_COMMAND_MAP[$ID]=$COMMAND
                    ConsoleDebug "declared $ORIGIN:::$ID"
                fi
            done
            if [ $NO_ERRORS == false ]; then
                ConsoleError " ->" "declare dependency - could not declare all dependencies from '$ORIGIN'"
            fi
        else
            ConsoleWarn "    >" "no dependencies (sh files) found at '$ORIGIN'"
        fi
    fi
}



#
# function: ValidateDependencyRequirements
# - validates all "requires" for all dependencies
#
 ValidateDependencyRequirements() {
     local ID
     local ORIGIN
     local REQUIRES
     local req
 
     ConsoleDebug "validate dependency requirements"
     for ID in "${!DEP_DECL_MAP[@]}"; do
         ORIGIN=${DEP_DECL_MAP[$ID]%:::*}
         REQUIRES=${DEP_DECL_REQ[$ID]#*:::}
         if [ -n "$REQUIRES" ]; then
             for req in $REQUIRES; do
                 if [ ${DEP_DECL_MAP[$req]+found} ]; then
                     ConsoleDebug "$ID requires $req"
                 else
                     ConsoleError " ->" "declare dependency - $ORIGIN:::$ID requires unknown dependency $req"
                 fi
             done
         fi
     done
     ConsoleDebug "done"
 }



##
## function: DeclareDependencies
## - declares dependencies from multiple sources, writes to FLAVOR_HOME
##
DeclareDependencies() {
    ConsoleInfo "-->" "declare dependencies"
    ConsoleResetErrors

    DeclareDependenciesOrigin FW_HOME
    if [ "${CONFIG_MAP["FW_HOME"]}" != "$FLAVOR_HOME" ]; then
        DeclareDependenciesOrigin HOME
    fi
    ValidateDependencyRequirements
}
