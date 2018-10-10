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
## Describe: describe a parameter
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## DescribeParameter
## - describes a parameter using print options and print features
## $1: parameter id
## $2: print option: descr, origin, origin1, standard, full, default-value
## $3: print features: none, line-indent, enter, post-line, (adoc, ansi, text)
## optional $4: print mode (adoc, ansi, text)
##
DescribeParameter() {
    local ID=${1:-}
    local PRINT_OPTION="${2:-}"
    local PRINT_FEATURE="${3:-}"
    local SPRINT=""

    if [ -z ${PARAM_DECL_MAP[$ID]:-} ]; then
        ConsoleError " ->" "describe-param - unknown parameter '$ID'"
        return
    fi

    local FEATURE
    local SOURCE=""
    local LINE_INDENT=""
    local POST_LINE=""
    local ENTER=""
    local DEF_TEMPLATE=""

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
            adoc)
                SOURCE=${PARAM_DECL_MAP[$ID]#*:::}.adoc
                DEF_TEMPLATE="\n+\ndefault value:"
                ;;
            ansi | text)
                SOURCE=${PARAM_DECL_MAP[$ID]#*:::}.txt
                DEF_TEMPLATE="        default value:"
                ;;
            none | "")      ;;
            *)
                ConsoleError " ->" "describe-param - unknown print feature '$PRINT_FEATURE'"
                return
                ;;
        esac
    done

    SPRINT=$ENTER
    SPRINT+=$LINE_INDENT

    local DESCRIPTION=${PARAM_DESCRIPTION_MAP[$ID]:-}
    local ORIGIN=${PARAM_DECL_MAP[$ID]%:::*}
    local DEFAULT_VALUE=${PARAM_DECL_DEFVAL[$ID]}
    if [ "$DEFAULT_VALUE" == "" ]; then
        DEFAULT_VALUE="none defined"
    else
        DEFAULT_VALUE=${DEFAULT_VALUE/${CONFIG_MAP["FW_HOME"]}/\$FW_HOME}
        DEFAULT_VALUE=${DEFAULT_VALUE/${CONFIG_MAP["HOME"]}/\$HOME}
        if [ "${4:-}" == "adoc" ] || [ "${CONFIG_MAP["PRINT_MODE"]}" == "adoc" ]; then
            DEFAULT_VALUE="\`"$DEFAULT_VALUE"\`"
        else
            DEFAULT_VALUE='"'$DEFAULT_VALUE'"'
        fi
    fi

    local TEMPLATE="%ID%"
    if [ "$PRINT_OPTION" == "full" ]; then
        TEMPLATE+=" - %DESCRIPTION%"
    fi
    if [ "$PRINT_OPTION" == "default-value" ]; then
        TEMPLATE="%DEFAULT_VALUE%"
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
        standard | full | default-value)
            local TMP_MODE=${4:-}
            if [ "$TMP_MODE" == "" ]; then
                TMP_MODE=${CONFIG_MAP["PRINT_MODE"]}
            fi
            TEMPLATE=${TEMPLATE//%ID%/$(PrintEffect bold "$ID" $TMP_MODE)}
            TEMPLATE=${TEMPLATE//%DEFAULT_VALUE%/$(PrintEffect italic "$DEFAULT_VALUE" $TMP_MODE)}
            TEMPLATE=${TEMPLATE//%DESCRIPTION%/"$DESCRIPTION"}
            SPRINT+=$TEMPLATE
            ;;
        *)
            ConsoleError " ->" "describe-param - unknown print option '$PRINT_OPTION'"
            return
            ;;
    esac

    SPRINT+=$POST_LINE
    printf "$SPRINT"

    if [ -n "$SOURCE" ]; then
        printf "\n"
        cat $SOURCE
    fi
    if [ -n "$DEF_TEMPLATE" ]; then
        printf "$DEF_TEMPLATE $DEFAULT_VALUE\n\n"
    fi
}



##
## function: DescribeParameterStatus
## - describes the parameter status for the parameter screen
## $1: task ID
## optional $2: print mode (adoc, ansi, text)
##
DescribeParameterStatus() {
    local ID=$1
    local DEFAULT
    local STATUS

    if [ -z ${PARAM_DECL_MAP[$ID]:-} ]; then
        ConsoleError " ->" "describe-parameter/status - unknown task '$ID'"
    else
        if [ -n "${PARAM_DECL_DEFVAL[$ID]:-}" ]; then
            PrintColor green ${CHAR_MAP["AVAILABLE"]}
        else
            PrintColor light-red ${CHAR_MAP["NOT_AVAILABLE"]}
        fi
        printf " "
        case ${CONFIG_SRC[$ID]:-} in
            "O")        PrintColor light-blue ${CHAR_MAP["DIAMOND"]} ;;
            "E")        PrintColor green ${CHAR_MAP["DIAMOND"]} ;;
            "F")        PrintColor brown ${CHAR_MAP["DIAMOND"]} ;;
            "D")        PrintColor yellow ${CHAR_MAP["DIAMOND"]} ;;
            *)          printf "${CHAR_MAP["DIAMOND"]}"
        esac
    fi
}



##
## function: ParameterStringLength
## - returns the length of a parameter string
## $*: same as for DescribeParameter
##
ParameterStringLength() {
    local SPRINT
    SPRINT=$(DescribeParameter $*)
    printf ${#SPRINT}
}



##
## function: ParameterInTable
## - main parameter details for table views
## $1: ID
## optional $2: print mode (adoc, ansi, text)
##
ParameterInTable() {
    local ID=$1
    local PRINT_MODE=${2:-}

    local TEXT
    local padding
    local str_len
    local SPRINT

    SPRINT=""
    SPRINT=$SPRINT" "$(DescribeParameter $ID standard "none" $PRINT_MODE)

    str_len=$(ParameterStringLength $ID standard "none" text)
    padding=$(( 18 - $str_len ))
    SPRINT=$SPRINT$(printf '%*s' "$padding")

    TEXT=$(DescribeParameter $ID descr "none" $PRINT_MODE)
    SPRINT=$SPRINT$TEXT

    str_len=${#TEXT}
    padding=$(( 56 - $str_len ))
    SPRINT=$SPRINT$(printf '%*s' "$padding")

    SPRINT=$SPRINT$(DescribeParameter $ID origin1 "none" $PRINT_MODE)" "

    printf "$SPRINT"
}

