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
## Describe: describe a task
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##



##
## DescribeTask
## - describes a task using print options and print features
## $1: task id
## $2: print option: descr, origin, origin1, standard, full
## $3: print features: none, line-indent, enter, post-line, (adoc, ansi, text)
## optional $4: print mode (adoc, ansi, text)
##
DescribeTask() {
    local ID=${1:-}
    local PRINT_OPTION="${2:-}"
    local PRINT_FEATURE="${3:-}"
    local SPRINT=""

    local ALIAS
    if [ -z ${TASK_DECL_MAP[$ID]:-} ]; then
        for ALIAS in ${!TASK_ALIAS_MAP[@]}; do
            if [ "$ALIAS" == "$ID" ]; then
                ID=${TASK_ALIAS_MAP[$ALIAS]}
                break
            fi
        done
    fi
    if [ -z ${TASK_DECL_MAP[$ID]:-} ]; then
        ConsoleError " ->" "describe-task - unknown task ID '$ID'"
        return
    fi

    for ALIAS in ${!TASK_ALIAS_MAP[@]}; do
        if [ "${TASK_ALIAS_MAP[$ALIAS]}" == "$ID" ]; then
            break
        fi
    done

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
            adoc)           SOURCE=${TASK_DECL_MAP[$ID]#*:::}.adoc ;;
            ansi | text)    SOURCE=${TASK_DECL_MAP[$ID]#*:::}.txt ;;
            none | "")      ;;
            *)
                ConsoleError " ->" "describe-task - unknown print feature '$PRINT_FEATURE'"
                return
                ;;
        esac
    done

    SPRINT=$ENTER
    SPRINT+=$LINE_INDENT

    local DESCRIPTION=${TASK_DESCRIPTION_MAP[$ID]:-}
    local ORIGIN=${TASK_DECL_MAP[$ID]%:::*}

    local TEMPLATE="%ID%, %ALIAS%"
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
            TEMPLATE=${TEMPLATE//%ALIAS%/$(PrintEffect bold "$ALIAS" $TMP_MODE)}
            TEMPLATE=${TEMPLATE//%DESCRIPTION%/"$DESCRIPTION"}
            SPRINT+=$TEMPLATE
            ;;
        *)
            ConsoleError " ->" "describe-task - unknown print option '$PRINT_OPTION'"
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
## function: DescribeTaskStatus
## - describes the task status for the task screen
## $1: task ID
## optional $2: print mode (adoc, ansi, text)
##
DescribeTaskStatus() {
    local ID=$1
    local ALIAS
    local MODE
    local STATUS

    if [ -z ${TASK_DECL_MAP[$ID]:-} ]; then
        for ALIAS in ${!TASK_ALIAS_MAP[@]}; do
            if [ "$ALIAS" == "$ID" ]; then
                ID=${TASK_ALIAS_MAP[$ALIAS]}
                break
            fi
        done
    fi

    if [ -z ${TASK_DECL_MAP[$ID]:-} ]; then
        ConsoleError " ->" "describe-task/status - unknown task '$ID'"
    else
        MODE=${TASK_MODE_MAP[$ID]}
        case "$MODE" in
            *dev*)
                PrintColor green ${CHAR_MAP["AVAILABLE"]}
                ;;
            *)
                PrintColor light-red ${CHAR_MAP["NOT_AVAILABLE"]}
                ;;
        esac
        printf " "
        case "$MODE" in
            *build*)
                PrintColor green ${CHAR_MAP["AVAILABLE"]}
                ;;
            *)
                PrintColor light-red ${CHAR_MAP["NOT_AVAILABLE"]}
                ;;
        esac
        printf " "
        case "$MODE" in
            *use*)
                PrintColor green ${CHAR_MAP["AVAILABLE"]}
                ;;
            *)
                PrintColor light-red ${CHAR_MAP["NOT_AVAILABLE"]}
                ;;
        esac

        printf " "
        case ${TASK_STATUS_MAP[$ID]} in
            "N")        PrintColor light-blue ${CHAR_MAP["DIAMOND"]} ;;
            "S")        PrintColor green ${CHAR_MAP["DIAMOND"]} ;;
            "E")        PrintColor light-red ${CHAR_MAP["DIAMOND"]} ;;
            "W")        PrintColor yellow ${CHAR_MAP["DIAMOND"]} ;;
        esac
    fi
}



##
## function: TaskStringLength
## - returns the length of a task string
## $*: same as for DescribeTask
##
TaskStringLength() {
    local SPRINT
    SPRINT=$(DescribeTask $*)
    printf ${#SPRINT}
}



##
## function: TaskInTable
## - main task details for table views
## $1: ID
## optional $2: print mode (adoc, ansi, text)
##
TaskInTable() {
    local ID=$1
    local PRINT_MODE=${2:-}

    local ALIAS
    if [ -z ${TASK_DECL_MAP[$ID]:-} ]; then
        for ALIAS in ${!TASK_ALIAS_MAP[@]}; do
            if [ "$ALIAS" == "$ID" ]; then
                ID=${TASK_ALIAS_MAP[$ALIAS]}
                break
            fi
        done
    fi
    if [ -z ${TASK_DECL_MAP[$ID]:-} ]; then
        ConsoleError " ->" "unknown task ID '$ID'"
        return
    fi

    for ALIAS in ${!TASK_ALIAS_MAP[@]}; do
        if [ "${TASK_ALIAS_MAP[$ALIAS]}" == "$ID" ]; then
            break
        fi
    done

    local TEXT
    local padding
    local str_len
    local SPRINT

    SPRINT=""
    SPRINT=$SPRINT" "$(DescribeTask $ID standard "none" $PRINT_MODE)

    str_len=$(TaskStringLength $ID standard "none" text)
    padding=$(( 25 - $str_len ))
    SPRINT=$SPRINT$(printf '%*s' "$padding")

    TEXT=$(DescribeTask $ID descr "none" $PRINT_MODE)
    SPRINT=$SPRINT$TEXT

    str_len=${#TEXT}
    padding=$(( 45 - $str_len ))
    SPRINT=$SPRINT$(printf '%*s' "$padding")

    SPRINT=$SPRINT$(DescribeTask $ID origin1 "none" $PRINT_MODE)" "

    printf "$SPRINT"
}

