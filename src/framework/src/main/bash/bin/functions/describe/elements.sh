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
## Describe: element description, e.e pre-text for the manual 
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## DescribeElementCommands
## - description for commands
##
DescribeElementCommands() {
    case $TARGET in
        adoc)
            printf "\n\n== SHELL COMMANDS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/commands.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "SHELL COMMANDS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/commands.txt
            ;;
    esac
}



##
## DescribeElementOptions
## - description for options
##
DescribeElementOptions() {
    case $TARGET in
        adoc)
            printf "\n\n== OPTIONS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/options.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "\n\n  "
            PrintEffect bold "OPTIONS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/options.txt
            ;;
    esac
}



##
## DescribeElementExitStatus
## - description for exit status
##
DescribeElementExitStatus() {
    case $TARGET in
        adoc)
            printf "\n\n== EXIT STATUS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/exit-status.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "EXIT STATUS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/exit-status.txt
            ;;
    esac
}



##
## DescribeElementOptionsExit
## - description for exit options
##
DescribeElementOptionsExit() {
    case $TARGET in
        adoc)
            printf "\n\n=== Exit OPTIONS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/exit-options.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "    "
            PrintEffect bold "Exit OPTIONS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/exit-options.txt
            ;;
    esac
}



##
## DescribeElementOptionsRuntime
## - description for exit options
##
DescribeElementOptionsRuntime() {
    case $TARGET in
        adoc)
            printf "\n\n=== Runtime OPTIONS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/run-options.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "    "
            PrintEffect bold "Runtime OPTIONS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/run-options.txt
            ;;
    esac
}



##
## DescribeElementParameters
## - description for parameters
##
DescribeElementParameters() {
    case $TARGET in
        adoc)
            printf "\n\n== PARAMETERS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/parameters.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "PARAMETERS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/parameters.txt
            ;;
    esac
}



##
## DescribeElementDependencies
## - description for dependencies
##
DescribeElementDependencies() {
    case $TARGET in
        adoc)
            printf "\n\n== PARAMETERS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/parameters.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "PARAMETERS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/parameters.txt
            ;;
    esac
}



##
## DescribeElementTasks
## - description for tasks
##
DescribeElementTasks() {
    case $TARGET in
        adoc)
            printf "\n\n== TASKS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/tasks.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "TASKS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/framework/tasks.txt
            ;;
    esac
}
