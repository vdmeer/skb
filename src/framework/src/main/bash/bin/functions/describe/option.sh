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
## Describe: describe a (CLI) option
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## DescribeOption
## - describes a option using print options and print features
## $1: option id
## $2: print option: descr, origin, standard, full
## $3: print features: none, line-indent, sl-indent, enter, post-line, (adoc, ansi, text*)
## optional $4: print mode (adoc, ansi, text)
##
DescribeOption() {
    local ID=${1:-}
    local PRINT_OPTION=${2:-}
    local PRINT_FEATURE=${3:-}
    local SPRINT=""
    local SHORT

    if [ -z "${DMAP_OPT_ORIGIN[$ID]:-}" ]; then
        for SHORT in ${!DMAP_OPT_SHORT[@]}; do
            if [ "${DMAP_OPT_SHORT[$SHORT]}" == "$ID" ]; then
                ID=$SHORT
                break
            fi
        done
    fi

    if [ -z ${DMAP_OPT_ORIGIN[$ID]:-} ]; then
        ConsoleError " ->" "describe-option - unknown option ID '$ID'"
        return
    fi

    local FEATURE
    local SOURCE=""
    local LINE_INDENT=""
    local SL_INDENT=""
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
            sl-indent)      SL_INDENT="    " ;;
            post-line)      POST_LINE="::" ;;
            enter)          ENTER="\n" ;;
            adoc)           SOURCE=$ID.adoc ;;
            ansi | text*)   SOURCE=$ID.txt ;;
            none | "")      ;;
            *)
                ConsoleError " ->" "describe-option - unknown print feature '$PRINT_FEATURE'"
                return
                ;;
        esac
    done

    SPRINT=$ENTER
    SPRINT+=$LINE_INDENT

    local DESCRIPTION=${DMAP_OPT_DESCR[$ID]:-}
    local ORIGIN=${DMAP_OPT_ORIGIN[$ID]:-}

    local LONG=$ID
    SHORT=${DMAP_OPT_SHORT[$ID]:-}
    local ARGUMENT=${DMAP_OPT_ARG[$ID]:-}

    local TEMPLATE=""
    if [ ! -n "$SHORT" ]; then
        TEMPLATE+=$SL_INDENT"%LONG%"
        LONG="--"$LONG
    elif [ ! -n "$LONG" ]; then
        TEMPLATE+="%SHORT%"
        SHORT="-"$SHORT
    else
        TEMPLATE+="%SHORT%, %LONG%"
        LONG="--"$LONG
        SHORT="-"$SHORT
    fi
    if [ -n "$ARGUMENT" ]; then
        TEMPLATE+=" %ARGUMENT%"
    fi
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
        standard | full)
            local TMP_MODE=${4:-}
            if [ "$TMP_MODE" == "" ]; then
                TMP_MODE=${CONFIG_MAP["PRINT_MODE"]}
            fi
            TEMPLATE=${TEMPLATE//%SHORT%/$(PrintEffect bold "$SHORT" $TMP_MODE)}
            TEMPLATE=${TEMPLATE//%LONG%/$(PrintEffect bold "$LONG" $TMP_MODE)}
            TEMPLATE=${TEMPLATE//%ARGUMENT%/$(PrintColor light-blue "$ARGUMENT" $TMP_MODE)}
            TEMPLATE=${TEMPLATE//%DESCRIPTION%/"$DESCRIPTION"}
            SPRINT+=$TEMPLATE
            ;;
        *)
            ConsoleError " ->" "describe-option - unknown print option '$PRINT_OPTION'"
            return
            ;;
    esac

    SPRINT+=$POST_LINE
    printf %b "$SPRINT"

    if [ -n "$SOURCE" ]; then
        printf "\n"
        case $ORIGIN in
            exit)
                cat ${CONFIG_MAP["FW_HOME"]}/${FW_PATH_MAP["OPTIONS"]}/exit/$SOURCE
                ;;
            run)
                cat ${CONFIG_MAP["FW_HOME"]}/${FW_PATH_MAP["OPTIONS"]}/run/$SOURCE
                ;;
        esac
    fi

    if [ "${4:-}" == "adoc" ] || [ "${CONFIG_MAP["PRINT_MODE"]}" == "adoc" ]; then
        printf "\n\n"
    fi
}



##
## function: DescribeOptionStatus
## - describes the option status
## $1: option ID
##
DescribeOptionStatus() {
    local ID=$1
    local TEXT
    local SPRINT=""

    TEXT=$(DescribeOption $ID origin)
    case $TEXT in
        exit)   SPRINT+=$(PrintColor green $TEXT) ;;
        run)    SPRINT+=$(PrintColor light-blue $TEXT) ;;
    esac

    printf "$SPRINT"
}



##
## function: OptionStringLength
## - returns the length of an option string
## $*: same as for DescribeOption
##
OptionStringLength() {
    local SPRINT
    SPRINT=$(DescribeOption $*)
    printf ${#SPRINT}
}



##
## function: OptionInList
## - main option details for list views
## $1: ID
## optional $2: print mode (adoc, ansi, text)
##
OptionInList() {
    local ID=$1
    local PRINT_MODE=${2:-}

    local TEXT
    local padding
    local str_len
    local SPRINT

    SPRINT=""

    TEXT=$(DescribeOption $ID standard sl-indent $PRINT_MODE)
    SPRINT+=" "$TEXT

    str_len=$(OptionStringLength $ID standard sl-indent text)
    padding=$(( 27 - $str_len ))
    SPRINT+=$(printf '%*s' "$padding")

    TEXT=$(DescribeOption $ID descr "none" $PRINT_MODE)
    SPRINT+=$TEXT

    printf "$SPRINT"
}



##
## function: OptionInTable
## - main option details for table views
## $1: ID
## optional $2: print mode (adoc, ansi, text)
##
OptionInTable() {
    local ID=$1
    local PRINT_MODE=${2:-}

    local SPRINT
    local TEXT

    SPRINT=$(OptionInList $1 $PRINT_MODE)

    TEXT=$(DescribeOption $ID descr "none" $PRINT_MODE)
    str_len=${#TEXT}
    padding=$(( 48 - $str_len ))
    SPRINT+=$(printf '%*s' "$padding")

    printf "$SPRINT"
}

