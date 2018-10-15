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
## Declare: parameters
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


declare -A DMAP_PARAM_ORIGIN            # map [id]=origin
declare -A DMAP_PARAM_DECL              # map [id]=decl-file w/o .id eding
declare -A DMAP_PARAM_DEFVAL            # map [id]="default value"
declare -A DMAP_PARAM_DESCR             # map [id]="descr-tag-line"

declare -A DMAP_PARAM_IS                # map [id]=none, file, dir, dir-cd

# declare -A DMAP_PARAM_FILES             # array for parameters that are files
# declare -A DMAP_PARAM_DIRS              # array for parameters that are directories
# declare -A DMAP_PARAM_DIRS_CD           # array for parameters that are directies subject to reas and write


##
## function: DeclareParametersOrigin
## - declares parameters from origin
## $1: origin, CONFIG_MAP identifier, i.e. FW_HOME or HOME
##
DeclareParametersOrigin() {
    local ORIGIN=$1

    ConsoleDebug "scanning $ORIGIN"
    local PARAM_PATH=${CONFIG_MAP[$ORIGIN]}/${APP_PATH_MAP["PARAM_DECL"]}
    if [[ ! -d $PARAM_PATH ]]; then
        ConsoleWarn " ->" "declare parameter - did not find parameter directory '$PARAM_PATH' at origin '$ORIGIN'"
    else
        local NO_ERRORS=true
        local ID
        local DESCRIPTION
        local DEFAULT_VALUE
        local IS_FILE
        local IS_DIRECTORY
        local IS_DIRECTORY_CD
        local files
        local file

        for file in $PARAM_PATH/**/*.id; do
            if [ ! -f $file ]; then
                continue    ## avoid any strange file, and empty directory
            fi
            ID=${file##*/}
            ID=${ID%.*}

            local HAVE_ERRORS=false

            DESCRIPTION=
            DEFAULT_VALUE=
            IS_FILE=
            IS_DIRECTORY=
            IS_DIRECTORY_CD=
            source "$file"

            if [[ -z "${DESCRIPTION:-}" ]]; then
                ConsoleError " ->" "declare param - param '$ID' has no description"
                HAVE_ERRORS=true
            fi

            if [[ -z ${DEFAULT_VALUE:-} ]]; then
                DEFAULT_VALUE=""
            fi

            if [[ ! -z ${DMAP_PARAM_ORIGIN[$ID]:-} ]]; then
                ConsoleError "    >" "overwriting ${DMAP_PARAM_ORIGIN[$ID]}:::$ID with $ORIGIN:::$ID"
                HAVE_ERRORS=true
            fi
            if [[ $HAVE_ERRORS == true ]]; then
                ConsoleError " ->" "declare parameter - could not declare parameter"
                NO_ERRORS=false
            else
                DMAP_PARAM_ORIGIN[$ID]=$ORIGIN
                DMAP_PARAM_DECL[$ID]=${file%.*}
                DMAP_PARAM_DEFVAL[$ID]="$DEFAULT_VALUE"
                DMAP_PARAM_DESCR[$ID]="$DESCRIPTION"

                if [[ ! -z ${IS_FILE:-} ]]; then
                    DMAP_PARAM_IS[$ID]=file
                fi
                if [[ ! -z ${IS_DIRECTORY:-} ]]; then
                    DMAP_PARAM_IS[$ID]=dir
                fi
                if [[ ! -z ${IS_DIRECTORY_CD:-} ]]; then
                    DMAP_PARAM_IS[$ID]=dir-cd
                fi

                ConsoleDebug "declared $ORIGIN:::$ID"
            fi
        done
    fi
}



##
## function: DeclareParameters
## - declares parameters from multiple sources, writes to FLAVOR_HOME
##
DeclareParameters() {
    ConsoleInfo "-->" "declare parameters"
    ConsoleResetErrors

    DeclareParametersOrigin FW_HOME
    if [[ "${CONFIG_MAP["FW_HOME"]}" != "$FLAVOR_HOME" ]]; then
        DeclareParametersOrigin HOME
    fi
}
