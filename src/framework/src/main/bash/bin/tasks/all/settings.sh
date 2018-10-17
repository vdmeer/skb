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
## settings - shows settings
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##

## put bugs into errors, safer
set -o errexit -o pipefail -o noclobber -o nounset


##
## Test if we are run from parent with configuration
## - load configuration
##
if [[ -z ${FW_HOME:-} || -z ${FW_L1_CONFIG-} ]]; then
    printf " ==> please run from framework or application\n\n"
    exit 10
fi
source $FW_L1_CONFIG
CONFIG_MAP["RUNNING_IN"]="task"


##
## load main functions
## - reset errors and warnings
##
source $FW_HOME/bin/functions/_include
source $FW_HOME/bin/functions/describe/task.sh
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
PRINT_MODE=
FILTER=
ALL=
CLI_SET=false



##
## set CLI options and parse CLI
##
CLI_OPTIONS=acdefhip:
CLI_LONG_OPTIONS=all,help,print-mode:
CLI_LONG_OPTIONS+=,cli,default,file,env,internal

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name settings -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    ConsoleError "  ->" "unknown CLI options"
    exit 1
fi
eval set -- "$PARSED"

PRINT_PADDING=25
while true; do
    case "$1" in
        -a | --all)
            ALL=yes
            CLI_SET=true
            shift
            ;;
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"                            $PRINT_PADDING
            BuildTaskHelpLine p print-mode  "MODE"      "print mode: ansi, text, adoc"                          $PRINT_PADDING
            printf "\n   filters\n"
            BuildTaskHelpLine a all         "<none>"    "all settings, disables all other filters"              $PRINT_PADDING
            BuildTaskHelpLine c cli         "<none>"    "only settings from CLI options"                        $PRINT_PADDING
            BuildTaskHelpLine d default     "<none>"    "only settings from default value"                      $PRINT_PADDING
            BuildTaskHelpLine e env         "<none>"    "only settings from environment"                        $PRINT_PADDING
            BuildTaskHelpLine f file        "<none>"    "only settings from configuration file"                 $PRINT_PADDING
            BuildTaskHelpLine i internal    "<none>"    "only internal settings"                                $PRINT_PADDING
            exit 0
            ;;
        -p | --print-mode)
            PRINT_MODE="$2"
            CLI_SET=true
            shift 2
            ;;

        -c | --cli)
            FILTER=$FILTER" cli"
            CLI_SET=true
            shift
            ;;
        -d | --default)
            FILTER=$FILTER" default"
            CLI_SET=true
            shift
            ;;
        -e | --env)
            FILTER=$FILTER" env"
            CLI_SET=true
            shift
            ;;
        -f | --file)
            FILTER=$FILTER" file"
            CLI_SET=true
            shift
            ;;
        -i | --internal)
            FILTER=$FILTER" internal"
            CLI_SET=true
            shift
            ;;

        --)
            shift
            break
            ;;
        *)
            ConsoleFatal "  ->" "internal error (task): CLI parsing bug"
            exit 2
    esac
done



############################################################################################
## test CLI
############################################################################################
if [[ $ALL == true  || $CLI_SET == false ]]; then
    FILTER="cli default env file internal"
fi



############################################################################################
##
## ready to go
##
############################################################################################
ConsoleInfo "  -->" "set: starting task"

STATUS_PADDING=17
STATUS_STATUS_LENGHT=1
STATUS_LINE_MIN_LENGTH=30
COLUMNS=$(tput cols)
COLUMNS=$((COLUMNS - 2))
VALUE_LENGTH=$((COLUMNS - STATUS_PADDING - STATUS_STATUS_LENGHT - 1))

if (( $STATUS_LINE_MIN_LENGTH > $COLUMNS )); then
    ConsoleError "  ->" "not enough columns for table, need $STATUS_LINE_MIN_LENGTH found $COLUMNS"
else
    for ID in ${!CONFIG_MAP[@]}; do
        found=false
        for fil in $FILTER; do
            SOURCE=${CONFIG_SRC[$ID]:-}
            case "$fil" in
                cli)
                    if [[ "$SOURCE" == "O" ]]; then
                        found=true
                    fi
                    ;;
                default)
                    if [[ "$SOURCE" == "D" ]]; then
                        found=true
                    fi
                    ;;
                env)
                    if [[ "$SOURCE" == "E" ]]; then
                        found=true
                    fi
                    ;;
                file)
                    if [[ "$SOURCE" == "F" ]]; then
                        found=true
                    fi
                    ;;
                internal)
                    if [[ "$SOURCE" == "" ]]; then
                        found=true
                    fi
                    ;;
            esac
        done
        if [[ $found == false ]]; then
            continue
        fi
        keys=(${keys[@]:-} $ID)
    done
    keys=($(printf '%s\n' "${keys[@]:-}"|sort))


    printf "\n "
    for ((x = 1; x < $COLUMNS; x++)); do
        printf %s "${CHAR_MAP["TOP_LINE"]}"
    done
    printf "\n ${EFFECTS["REVERSE_ON"]}Name"
    printf "%*s" "$((STATUS_PADDING - 4))" ''
    printf "Value"
    printf '%*s' "$((VALUE_LENGTH - 5))" ''
    printf "S${EFFECTS["REVERSE_OFF"]}\n\n"

    for i in ${!keys[@]}; do
        ID=${keys[$i]}
        printf " %s" "$ID"
        str_len=${#ID}
        padding=$((STATUS_PADDING - $str_len))
        printf '%*s' "$padding"

        sc_str=${CONFIG_MAP[$ID]}
        case $ID in
            LOADER-LEVEL | SHELL-LEVEL | TASK-LEVEL)
                PrintConsoleLevel "$sc_str"
                ;;
            STRICT)
                PrintStrict
                ;;
            APP_MODE)
                PrintAppMode
                ;;
            FLAVOR)
                PrintEffect bold "$sc_str"
                ;;
            FW_HOME | HOME)
                printf '%s' "$sc_str"
                ;;
            *)
                sc_str=${sc_str/${CONFIG_MAP["FW_HOME"]}/\$FW_HOME}
                sc_str=${sc_str/${CONFIG_MAP["HOME"]}/\$HOME}
                printf '%s' "$sc_str"
                ;;
        esac

        str_len=${#sc_str}
        if [[ "$ID" == "SHELL_PROMPT" ]]; then
            str_len=${CONFIG_MAP["PROMPT_LENGTH"]}
        fi
        PADDING=$((VALUE_LENGTH - str_len))
        printf '%*s' "$PADDING"

        case ${CONFIG_SRC[$ID]:-} in
            "E")    PrintColor green        ${CHAR_MAP["DIAMOND"]} ;;
            "F")    PrintColor yellow       ${CHAR_MAP["DIAMOND"]} ;;
            "D")    PrintColor light-red    ${CHAR_MAP["DIAMOND"]} ;;
            "O")    PrintColor light-cyan   ${CHAR_MAP["DIAMOND"]} ;;
            *)      PrintColor light-blue   ${CHAR_MAP["DIAMOND"]} ;;
        esac
        printf "\n"
    done

    printf " "
    for ((x = 1; x < $COLUMNS; x++)); do
        printf %s "${CHAR_MAP["MID_LINE"]}"
    done
    printf "\n\n"

    printf " source:"
    printf " internal ";        PrintColor light-blue   ${CHAR_MAP["LEGEND"]}
    printf " , CLI ";           PrintColor light-cyan   ${CHAR_MAP["LEGEND"]}
    printf " , environment ";   PrintColor light-green  ${CHAR_MAP["LEGEND"]}
    printf " , file ";          PrintColor yellow       ${CHAR_MAP["LEGEND"]}
    printf " default ";         PrintColor light-red    ${CHAR_MAP["LEGEND"]}

    printf "\n\n "
    for ((x = 1; x < $COLUMNS; x++)); do
        printf %s "${CHAR_MAP["BOTTOM_LINE"]}"
    done
    printf "\n\n"
fi

ConsoleInfo "  -->" "set: done"
exit $TASK_ERRORS
