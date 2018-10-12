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
## Console functions for loader, shell, and tasks
## - these functions print tagged messages according to CONSOLE/SHELL/TASK-LEVEL
## - they behave similar to Java logging frameworks
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: ConsoleMessage
## - prints a message to console
## $1: the message
##
ConsoleMessage() {
    local LEVEL=
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader)
            LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
            ;;
        shell)
            LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
            ;;
        task)
            LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
            ;;
    esac

    case $LEVEL in
        all | fatal | error | warn-strict | warn | info | debug | trace)
            printf %b "$1"
            ;;
        off)
            ;;
    esac
}



##
## function: ConsoleFatal
## - prints a fatal error message with [Fatal] tag, increases *_ERRORS
## - $1: error prefix, e.g. script name with colon
## - $2: the error message
##
ConsoleFatal() {
    local LEVEL=
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader)
            LOADER_ERRORS=$(($LOADER_ERRORS + 1))
            LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
            ;;
        shell)
            SHELL_ERRORS=$(($SHELL_ERRORS + 1))
            LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
            ;;
        task)
            TASK_ERRORS=$(($TASK_ERRORS + 1))
            LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
            ;;
    esac

    case $LEVEL in
        all | fatal | error | warn-strict | warn | info | debug | trace)
            printf "%s [" "$1"
            PrintColor red "Fatal"
            printf "] %s\n" "$2"
            ;;
        off)
            ;;
    esac
}



##
## function: ConsoleError
## - prints an error message with [Error] tag, increases *_ERRORS
## - $1: error prefix, e.g. script name with colon
## - $2: the error message
##
ConsoleError() {
    local LEVEL=
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader)
            LOADER_ERRORS=$(($LOADER_ERRORS + 1))
            LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
            ;;
        shell)
            SHELL_ERRORS=$(($SHELL_ERRORS + 1))
            LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
            ;;
        task)
            TASK_ERRORS=$(($TASK_ERRORS + 1))
            LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
            ;;
    esac

    case $LEVEL in
        all | error | warn-strict | warn | info | debug | trace)
            printf "%s [" "$1"
            PrintColor light-red "Error"
            printf "] %s\n" "$2"
            ;;
        *)
            ;;
    esac
}



##
## function ConsoleResetErrors
## - resets the error counter *_ERRORS
##
ConsoleResetErrors() {
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader) LOADER_ERRORS=0 ;;
        shell)  SHELL_ERRORS=0 ;;
        task)   TASK_ERRORS=0 ;;
    esac
}



##
## function ConsoleGetErrors
## - returns the current error counter *_ERRORS
##
ConsoleGetErrors() {
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader) return $LOADER_ERRORS ;;
        shell)  return $SHELL_ERRORS ;;
        task)   return $TASK_ERRORS ;;
    esac
}



##
## function ConsoleHasErrors
## - returns true if counter *_ERRORS is larger than 0, i.e. there are errors
##
ConsoleHasErrors() {
    local COUNTER
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader) COUNTER=$LOADER_ERRORS ;;
        shell)  COUNTER=$SHELL_ERRORS ;;
        task)   COUNTER=$TASK_ERRORS ;;
    esac
    if (( $COUNTER > 0 )); then
        return 0
    else
        return 1
    fi
}



##
## function: ConsoleWarnStrict
## - in non-strict mode: prints a warning message with [Warn/Strict] tag, increases *_WARNINGS
## - in strict mode: prints a error message with [Error/Strict] tag, increases *_ERRORS
## - $1: warning/error prefix, e.g. script name with colon
## - $2: the warning/error message
##
ConsoleWarnStrict() {
    local LEVEL=

    if [[ ${CONFIG_MAP["STRICT"]} == "yes" ]]; then
        ## all warnings are errors

        case ${CONFIG_MAP["RUNNING_IN"]} in
            loader)
                LOADER_ERRORS=$(($LOADER_ERRORS + 1))
                LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
                ;;
            shell)
                SHELL_ERRORS=$(($SHELL_ERRORS + 1))
                LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
                ;;
            task)
                TASK_ERRORS=$(($TASK_ERRORS + 1))
                LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
                ;;
        esac
        case $LEVEL in
            all | error | warn-strict | warn | info | debug | trace)
                printf "%s [" "$1"
                PrintColor light-red "Error"
                printf "/"
                PrintColor yellow "strict"
                printf "] %s\n" "$2"
                ;;
            *)
                ;;
        esac
    else
        ## warnings are just warnings
        case ${CONFIG_MAP["RUNNING_IN"]} in
            loader)
                LOADER_WARNINGS=$(($LOADER_WARNINGS + 1))
                LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
                ;;
            shell)
                SHELL_WARNINGS=$(($SHELL_WARNINGS + 1))
                LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
                ;;
            task)
                TASK_WARNINGS=$(($TASK_WARNINGS + 1))
                LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
                ;;
        esac
        case $LEVEL in
            all | warn-strict | warn | info | debug | trace)
                printf "%s [" "$1"
                PrintColor yellow "Warning"
                printf "/"
                PrintColor light-red "strict"
                printf "] %s\n" "$2"
                ;;
            *)
                ;;
        esac
    fi
}



##
## function: ConsoleWarn
## - prints a warning message with [Warn] tag, increases *_WARNINGS
## - $1: warning prefix, e.g. script name with colon
## - $2: the warning message
##
ConsoleWarn() {
    local LEVEL=
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader)
            LOADER_WARNINGS=$(($LOADER_WARNINGS + 1))
            LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
            ;;
        shell)
            SHELL_WARNINGS=$(($SHELL_WARNINGS + 1))
            LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
            ;;
        task)
            TASK_WARNINGS=$(($TASK_WARNINGS + 1))
            LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
            ;;
    esac
    case ${CONFIG_MAP["LOADER-LEVEL"]} in
        all | warn | info | debug | trace)
            printf "%s [" "$1"
            PrintColor yellow "Warning"
            printf "] %s\n" "$2"
            ;;
        *)
            ;;
    esac
}



##
## function ConsoleResetWarnings
## - resets the error counter *_WARNINGS
##
ConsoleResetWarnings() {
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader) LOADER_WARNINGS=0 ;;
        shell)  SHELL_WARNINGS=0 ;;
        task)   TASK_WARNINGS=0 ;;
    esac
}



##
## function ConsoleGetWarnings
## - returns the current warning counter *_WARNINGS
##
ConsoleGetWarnings() {
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader) return $LOADER_WARNINGS ;;
        shell)  return $SHELL_WARNINGS ;;
        task)   return $TASK_WARNINGS ;;
    esac
}



##
## function ConsoleHasWarnings
## - returns true if counter *_WARNINGS is larger than 0, i.e. there are warnings
##
ConsoleHasWarnings() {
    local COUNTER
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader) COUNTER=$LOADER_WARNINGS ;;
        shell)  COUNTER=$SHELL_WARNINGS ;;
        task)   COUNTER=$TASK_WARNINGS ;;
    esac
    if (( $COUNTER > 0 )); then
        return 0
    else
        return 1
    fi
}



##
## function: ConsoleInfo
## - prints an info message with [Info] tag
## - adds extra line for message "done"
## - $1: info prefix, e.g. script name with colon
## - $2: the info message
##
ConsoleInfo() {
    local LEVEL=
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader)
            LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
            ;;
        shell)
            LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
            ;;
        task)
            LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
            ;;
    esac
    case $LEVEL in
        all | info | debug | trace)
            printf "%s [" "$1"
            PrintColor light-blue "Info"
            printf "] %s\n" "$2"
            if [[ "$2" == "done" ]]; then
                printf "\n"
            fi
            ;;
        *)
            ;;
    esac
}



##
## function: ConsoleDebug
## - prints a debug message
## - $1: the debug message
##
ConsoleDebug() {
    local LEVEL=
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader)
            LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
            ;;
        shell)
            LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
            ;;
        task)
            LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
            ;;
    esac
    case $LEVEL in
        all | debug | trace)
            PrintEffect bold "    >"
            printf " %s\n" "$1"
            ;;
        *)
            ;;
    esac
}



##
## function: ConsoleTrace
## - prints a trace message
## - $1: the trace message
##
ConsoleTrace() {
    local LEVEL=
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader)
            LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
            ;;
        shell)
            LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
            ;;
        task)
            LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
            ;;
    esac
    case $LEVEL in
        all | trace)
            PrintEffect italic "    >"
            printf " %s\n" "$1"
            ;;
        *)
            ;;
    esac
}



######################
#
# Test functions, return 0 on true and 1 on false
#
######################
ConsoleIsDebug() {
    local LEVEL=
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader)
            LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
            ;;
        shell)
            LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
            ;;
        task)
            LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
            ;;
    esac
    case $LEVEL in
        all | debug | trace)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

ConsoleIsTrace() {
    local LEVEL=
    case ${CONFIG_MAP["RUNNING_IN"]} in
        loader)
            LEVEL=${CONFIG_MAP["LOADER-LEVEL"]}
            ;;
        shell)
            LEVEL=${CONFIG_MAP["SHELL-LEVEL"]}
            ;;
        task)
            LEVEL=${CONFIG_MAP["TASK-LEVEL"]}
            ;;
    esac
    case $LEVEL in
        all | trace)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
