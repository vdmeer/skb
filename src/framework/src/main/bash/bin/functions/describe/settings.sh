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
## Screen: settings
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##



##
## function: PrintSettingsLevel
## - prints the level (loader, shell, task) in color
## $1: level
##
PrintSettingsLevel() {
    local LEVEL=$1
    case "$LEVEL" in
        all)            PrintColor light-cyan      $LEVEL;;
        fatal)          PrintColor red             $LEVEL;;
        error)          PrintColor light-red       $LEVEL;;
        warn-strict)    PrintColor yellow "warn"; printf "-"; PrintColor light-red "strict";;
        warn)           PrintColor yellow          $LEVEL;;
        info)           PrintColor green           $LEVEL;;
        debug | trace)  PrintColor light-blue      $LEVEL;;
        off)            PrintColor light-purple    $LEVEL;;
        *)              PrintColor light-purple    $LEVEL;;
    esac
}



##
## function: SettingScreen()
## - prints settings, i.e. CONFIG_MAP
##
SettingScreen() {
    local ID
    local VALUE
    local padding
    local str_len
    local sc_str

    printf "\n "
    printf "${CHAR_MAP["TOP_LINE"]}%.0s" {1..79}
    printf "\n"
    printf " ${EFFECTS["REVERSE_ON"]}Name             Value                                                        S${EFFECTS["REVERSE_OFF"]}\n\n"

    for ID in ${!CONFIG_MAP[@]}; do
        printf " %-17s" "$ID"
        sc_str=${CONFIG_MAP[$ID]}

        case $ID in
            LOADER-LEVEL | SHELL-LEVEL | TASK-LEVEL)
                PrintSettingsLevel "$sc_str"
                ;;
            STRICT)
                if [ $sc_str == false ]; then
                    printf "false"
                    sc_str="false"
                else
                    PrintColor light-red "true"
                    sc_str="true"
                fi
                ;;
            MODE)
                case "$sc_str" in
                    dev)    PrintColor light-red        $sc_str ;;
                    build)  PrintColor yellow           $sc_str ;;
                    use)    PrintColor light-green      $sc_str ;;
                    *)      PrintColor light-purple     $sc_str ;;
                esac
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
        padding=$(( 60 - $str_len ))
        printf '%*s' "$padding"

        printf " "
        case ${CONFIG_SRC[$ID]:-} in
            "E")    PrintColor green        ${CHAR_MAP["DIAMOND"]} ;;
            "F")    PrintColor yellow       ${CHAR_MAP["DIAMOND"]} ;;
            "D")    PrintColor light-red    ${CHAR_MAP["DIAMOND"]} ;;
            "O")    PrintColor light-cyan   ${CHAR_MAP["DIAMOND"]} ;;
            *)      PrintColor light-blue   ${CHAR_MAP["DIAMOND"]} ;;
        esac
        printf "\n"
    done | sort -t : -k 2n

    printf " "
    printf "${CHAR_MAP["MID_LINE"]}%.0s" {1..79}
    printf "\n\n"

    printf " source:"
    printf " internal ";        PrintColor light-blue   ${CHAR_MAP["LEGEND"]}
    printf " , CLI ";           PrintColor light-cyan   ${CHAR_MAP["LEGEND"]}
    printf " , environment ";   PrintColor light-green  ${CHAR_MAP["LEGEND"]}
    printf " , file ";          PrintColor yellow       ${CHAR_MAP["LEGEND"]}
    printf " default ";         PrintColor light-red    ${CHAR_MAP["LEGEND"]}

    printf "\n\n "
    printf "${CHAR_MAP["BOTTOM_LINE"]}%.0s" {1..79}
    printf "\n\n"
}
