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


declare -A DMAP_DEP_ORIGIN              # map [id]=origin
declare -A DMAP_DEP_DECL                # map [id]=decl-file w/o .id eding
declare -A DMAP_DEP_CMD                 # map [id]=exec-script
declare -A DMAP_DEP_DESCR               # map [id]="descr-tag-line"
declare -A DMAP_DEP_REQ_DEP             # map [id]=(dep-id, ...)



##
## function: DeclareDependenciesOrigin
## - declares dependencies from origin
## $1: origin, CONFIG_MAP identifier, i.e. FW_HOME or HOME
##
DeclareDependenciesOrigin() {
    local ORIGIN=$1

    ConsoleDebug "scanning $ORIGIN"
    local DEPENDENCY_PATH=${CONFIG_MAP[$ORIGIN]}/${APP_PATH_MAP["DEP_DECL"]}
    if [[ ! -d $DEPENDENCY_PATH ]]; then
        ConsoleError " ->" "declare dependency - did not find dependency directory '$DEPENDENCY_PATH' at origin '$ORIGIN'"
    else
        local NO_ERRORS=true
        local ID
        local COMMAND
        local DESCRIPTION
        local REQUIRES
        local files
        local file

#         files=$(find -P $DEPENDENCY_PATH -type f -name '*.id')
#         if [[ -n "$files" ]]; then
            for file in $DEPENDENCY_PATH/**/*.id; do
                ID=${file##*/}
                ID=${ID%.*}

                local HAVE_ERRORS=false

                COMMAND=
                DESCRIPTION=
                REQUIRES=
                source "$file"

                if [[ -z "${DESCRIPTION:-}" ]]; then
                    ConsoleError " ->" "declare dependency - dependency '$ID' has no description"
                    HAVE_ERRORS=true
                fi

                if [[ -z "${COMMAND:-}" ]]; then
                    ConsoleError " ->" "declare dependency - dependency '$ID' has no command to test"
                    HAVE_ERRORS=true
                fi

                if [[ -z "${REQUIRES:-}" ]]; then
                    REQUIRES=""
                fi

                if [[ ! -z ${DMAP_DEP_ORIGIN[$ID]:-} ]]; then
                    ConsoleError "    >" "overwriting ${DMAP_DEP_ORIGIN[$ID]}:::$ID with $ORIGIN:::$ID"
                    HAVE_ERRORS=true
                fi
                if [[ $HAVE_ERRORS == true ]]; then
                    ConsoleError " ->" "declare dependency - could not declare dependency"
                    NO_ERRORS=false
                else
                    DMAP_DEP_ORIGIN[$ID]=$ORIGIN
                    DMAP_DEP_DECL[$ID]=${file%.*}
                    DMAP_DEP_REQ_DEP[$ID]=$REQUIRES
                    DMAP_DEP_DESCR[$ID]=$DESCRIPTION
                    DMAP_DEP_CMD[$ID]=$COMMAND
                    ConsoleDebug "declared $ORIGIN:::$ID"
                fi
            done
#             if [[ $NO_ERRORS == false ]]; then
#                 ConsoleError " ->" "declare dependency - could not declare all dependencies from '$ORIGIN'"
#             fi
#         else
#             ConsoleWarn "    >" "no dependencies (sh files) found at '$ORIGIN'"
#         fi
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
     for ID in "${!DMAP_DEP_ORIGIN[@]}"; do
         ORIGIN=${DMAP_DEP_ORIGIN[$ID]}
         REQUIRES=${DMAP_DEP_REQ_DEP[$ID]#*:::}
         if [[ -n "$REQUIRES" ]]; then
             for req in $REQUIRES; do
                 if [[ ${DMAP_DEP_ORIGIN[$req]+found} ]]; then
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
    if [[ "${CONFIG_MAP["FW_HOME"]}" != "$FLAVOR_HOME" ]]; then
        DeclareDependenciesOrigin HOME
    fi
    ValidateDependencyRequirements
}
