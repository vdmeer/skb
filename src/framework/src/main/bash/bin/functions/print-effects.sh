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
## Functions for printing effects, e.g. bold, italic, reverse
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##



##
## function: PrintEffect
## $1: effect: bold, italic, reverse
## $2: message
## $3: print mode, opional
## - does not print a line feed
##
PrintEffect() {
    local PRINT_MODE=${3:-}
    if [ "$PRINT_MODE" == "" ]; then
        PRINT_MODE=${CONFIG_MAP["PRINT_MODE"]}
    fi

    case $PRINT_MODE in
        ansi)
            case "$1" in
                bold)           printf "${EFFECTS["INT_BOLD"]}%s${EFFECTS["INT_FAINT"]}${COLORS["WHITE"]}${COLORS["NORMAL"]}" "$2" ;;
                italic)         printf "${EFFECTS["ITALIC_ON"]}%s${EFFECTS["ITALIC_OFF"]}${COLORS["WHITE"]}${COLORS["NORMAL"]}" "$2" ;;
                reverse)        printf "${EFFECTS["REVERSE_ON"]}%s${EFFECTS["REVERSE_OFF"]}" "$2" ;;
                *)              ConsoleError "  -->" "print-effect: unknown effect: $1"
            esac
            ;;
        adoc | text)
            case "$1" in
                bold)           printf "*%s*" "$2" ;;
                italic)         printf "_%s_" "$2" ;;
                reverse)        printf "%s" "$2" ;;
                *)              ConsoleError "  -->" "print-effect: unknown effect: $1"
            esac
            ;;
    esac
}
