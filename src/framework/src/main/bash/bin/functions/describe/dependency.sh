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
## Describe: describe a dependency
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## DescribeDependency
## - describes a dependency using print options and print features
## $1: dependency id
## $2: print option: descr, origin, origin1, standard, full
## $3: print features: none, line-indent, enter, post-line, (adoc, ansi, text)
##
DescribeDependency() {
    local ID=${1:-}
    local PRINT_OPTION=${2:-}
    local PRINT_FEATURE=${3:-}
    local SPRINT=""

    if [ -z ${DEP_DECL_MAP[$ID]:-} ]; then
        ConsoleError " ->" "describe-dependency - unknown dependency ID '$ID'"
        return
    fi

    local FEATURE
    local SOURCE=""
    local LINE_INDENT=""
    local POST_LINE=""
    local ENTER=""
    for FEATURE in $PRINT_FEATURE; do
        case "$FEATURE" in
            line-indent)
                LINE_INDENT="      "
                ## exception for adoc, no line indent even if requested
                if [ -n "${4:-}" ]; then
                    if [ "$4" == "adoc" ]; then
                        LINE_INDENT=
                    fi
                fi
            ;;
            post-line)      POST_LINE="::" ;;
            enter)          ENTER="\n" ;;
            adoc)           SOURCE=${DEP_DECL_MAP[$ID]#*:::}.adoc ;;
            ansi | text)    SOURCE=${DEP_DECL_MAP[$ID]#*:::}.txt ;;
            none | "")      ;;
            *)
                ConsoleError " ->" "describe-dependency - unknown print feature '$PRINT_FEATURE'"
                return
                ;;
        esac
    done

    SPRINT=$ENTER
    SPRINT+=$LINE_INDENT

    local ORIGIN=${DEP_DECL_MAP[$ID]%:::*}
    local DESCRIPTION=${DEP_DESCRIPTION_MAP[$ID]:-}

    local TEMPLATE="%ID%"
    if [ "$PRINT_OPTION" == "full" ]; then
        TEMPLATE+=" - %DESCRIPTION%"
    fi
    if [ "${4:-}" == "adoc" ] || [ "${CONFIG_MAP["PRINT_MODE"]}" == "adoc" ]; then
        TEMPLATE+=":: "
    fi

    case "$PRINT_OPTION" in
        descr)
            SPRINT+=$DESCRIPTION
            ;;
        origin)
            SPRINT+=$ORIGIN
            ;;
        origin1)
            SPRINT+=${ORIGIN:0:1}
            ;;
        standard | full)
            local TMP_MODE=${4:-}
            if [ "$TMP_MODE" == "" ]; then
                TMP_MODE=${CONFIG_MAP["PRINT_MODE"]}
            fi
            TEMPLATE=${TEMPLATE//%ID%/$(PrintEffect bold "$ID" $TMP_MODE)}
            TEMPLATE=${TEMPLATE//%DESCRIPTION%/"$DESCRIPTION"}
            SPRINT+=$TEMPLATE
            ;;
        *)
            ConsoleError " ->" "describe-dependency - unknown print option '$PRINT_OPTION'"
            return
            ;;
    esac

    SPRINT+=$POST_LINE
    printf "$SPRINT"

    if [ -n "$SOURCE" ]; then
        printf "\n"
        cat $SOURCE
    fi

    if [ "${4:-}" == "adoc" ] || [ "${CONFIG_MAP["PRINT_MODE"]}" == "adoc" ]; then
        printf "\n\n"
    fi
}



##
## function: DescribeDependencyStatus
## - describes the dependency status for the dependency screen
## $1: dependency ID
##
DescribeDependencyStatus() {
    local ID=$1
    local ORIGIN
    local STATUS

    if [ -z ${DEP_DECL_MAP[$ID]:-} ]; then
        ConsoleError " ->" "help-dep/status - unknown dependency '$ID'"
    else
        case ${DEP_STATUS_MAP[$ID]} in
            "N")        PrintColor light-blue ${CHAR_MAP["DIAMOND"]} ;;
            "S")        PrintColor green ${CHAR_MAP["DIAMOND"]} ;;
            "E")        PrintColor light-red ${CHAR_MAP["DIAMOND"]} ;;
            "W")        PrintColor yellow ${CHAR_MAP["DIAMOND"]} ;;
        esac
    fi
}



##
## function: DependencyStringLength
## - returns the length of a dependency string
## $*: same as for DescribeDependency
##
DependencyStringLength() {
    local SPRINT
    SPRINT=$(DescribeDependency $*)
    printf ${#SPRINT}
}



##
## function: DependencyInTable
## - main dependency details for table views
## $1: ID
## optional $2: print mode (adoc, ansi, text)
##
DependencyInTable() {
    local ID=$1
    local PRINT_MODE=${2:-}

    local TEXT
    local padding
    local str_len
    local SPRINT

    SPRINT=""
    SPRINT=$SPRINT" "$(DescribeDependency $ID standard "none" $PRINT_MODE)

    str_len=$(DependencyStringLength $ID standard "none" text)
    padding=$(( 20 - $str_len ))
    SPRINT=$SPRINT$(printf '%*s' "$padding")

    TEXT=$(DescribeDependency $ID descr "none" $PRINT_MODE)
    SPRINT=$SPRINT$TEXT

    str_len=${#TEXT}
    padding=$(( 56 - $str_len ))
    SPRINT=$SPRINT$(printf '%*s' "$padding")

    SPRINT=$SPRINT$(DescribeDependency $ID origin1 "none" $PRINT_MODE)" "

    printf "$SPRINT"
}

