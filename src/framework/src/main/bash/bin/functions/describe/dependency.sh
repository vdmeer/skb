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

DEP_PADDING=20
DEP_STATUS_LENGHT=3
DEP_LINE_MIN_LENGTH=43
COLUMNS=$(tput cols)
COLUMNS=$((COLUMNS - 2))
DESCRIPTION_LENGTH=$((COLUMNS - DEP_PADDING - DEP_STATUS_LENGHT - 1))


##
## DescribeDependency
## - describes a dependency using print options and print features
## $1: dependency id
## $2: print option: standard, full
## $3: print features: none, line-indent, enter, post-line, (adoc, ansi, text*)
##
DescribeDependency() {
    local ID=${1:-}
    local PRINT_OPTION=${2:-}
    local PRINT_FEATURE=${3:-}
    local SPRINT=""

    if [[ -z ${DMAP_DEP_ORIGIN[$ID]:-} ]]; then
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
                if [[ -n "${4:-}" ]]; then
                    if [[ "$4" == "adoc" ]]; then
                        LINE_INDENT=
                    fi
                fi
            ;;
            post-line)      POST_LINE="::" ;;
            enter)          ENTER="\n" ;;
            adoc)           SOURCE=${DMAP_DEP_DECL[$ID]}.adoc ;;
            ansi | text*)   SOURCE=${DMAP_DEP_DECL[$ID]}.txt ;;
            none | "")      ;;
            *)
                ConsoleError " ->" "describe-dependency - unknown print feature '$PRINT_FEATURE'"
                return
                ;;
        esac
    done

    SPRINT=$ENTER
    SPRINT+=$LINE_INDENT

    local DESCRIPTION=${DMAP_DEP_DESCR[$ID]:-}

    local TEMPLATE="%ID%"
    if [[ "$PRINT_OPTION" == "full" ]]; then
        TEMPLATE+=" - %DESCRIPTION%"
    fi
    if [[ "${4:-}" == "adoc" || "${CONFIG_MAP["PRINT_MODE"]}" == "adoc" ]]; then
        TEMPLATE+=":: "
    fi

    case "$PRINT_OPTION" in
        standard | full)
            local TMP_MODE=${4:-}
            if [[ "$TMP_MODE" == "" ]]; then
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

    if [[ -n "$SOURCE" ]]; then
        printf "\n"
        cat $SOURCE
    fi

    if [[ "${4:-}" == "adoc" || "${CONFIG_MAP["PRINT_MODE"]}" == "adoc" ]]; then
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

    if [[ -z ${DMAP_DEP_ORIGIN[$ID]:-} ]]; then
        ConsoleError " ->" "help-dep/status - unknown dependency '$ID'"
    else

        DESCRIPTION=${DMAP_DEP_DESCR[$ID]}
        if [[ "${#DESCRIPTION}" -le "$DESCRIPTION_LENGTH" ]]; then
            printf "%s" "$DESCRIPTION"
            DESCR_EFFECTIVE=${#DESCRIPTION}
            PADDING=$((DESCRIPTION_LENGTH - DESCR_EFFECTIVE))
            printf '%*s' "$PADDING"
        else
            DESCR_EFFECTIVE=$((DESCRIPTION_LENGTH - 4))
            printf "%s... " "${DESCRIPTION:0:$DESCR_EFFECTIVE}"
        fi

        printf "%s " "${DMAP_DEP_ORIGIN[$ID]:0:1}"

        case ${RTMAP_DEP_STATUS[$ID]} in
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

    local padding
    local str_len
    local SPRINT

    SPRINT=" "$(DescribeDependency $ID standard "none" $PRINT_MODE)

    str_len=$(DependencyStringLength $ID standard "none" text)
    padding=$((DEP_PADDING - $str_len))
    SPRINT=$SPRINT$(printf '%*s' "$padding")

    printf "$SPRINT"
}

