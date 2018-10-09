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
## build-cache - builds cache for maps and screens
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##

## put bugs into errors, safer
set -o errexit -o pipefail -o noclobber -o nounset


##
## Test if we are run from parent with configuration
## - load configuration
##
if [ -z $FW_HOME ] || [ -z $FW_TMP_CONFIG ]; then
    printf " ==> please run from framework or application\n\n"
    exit 10
fi
source $FW_TMP_CONFIG
CONFIG_MAP["RUNNING_IN"]="task"


##
## load main functions
## - reset errors and warnings
##
source $FW_HOME/bin/functions/_include
source $FW_HOME/bin/functions/describe/_include
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
DO_BUILD=false
DO_CLEAN=false
DO_ALL=false
DO_DECL=false
DO_LIST=false
DO_TAB=false
TARGET=



##
## set CLI options and parse CLI
##
CLI_OPTIONS=abcdhlt
CLI_LONG_OPTIONS=all,build,clean,decl,help,list,tab
CLI_LONG_OPTIONS+=,cmd-decl,cmd-tab
CLI_LONG_OPTIONS+=,dep-decl,dep-tab
CLI_LONG_OPTIONS+=,opt-decl,opt-tab,opt-list
CLI_LONG_OPTIONS+=,param-decl,param-tab
CLI_LONG_OPTIONS+=,task-decl,task-tab

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name build-cache -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    ConsoleError "  ->" "unknown CLI options"
    exit 1
fi
eval set -- "$PARSED"

PRINT_PADDING=19
while true; do
    case "$1" in
        -b | --build)
            shift
            DO_BUILD=true
            ;;
        -c | --clean)
            DO_CLEAN=true
            shift
            ;;
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine b build   "<none>"    "builds cache, requires a target"                   $PRINT_PADDING
            BuildTaskHelpLine c clean   "<none>"    "removes all cached maps and screens"               $PRINT_PADDING
            BuildTaskHelpLine d decl    "<none>"    "set all declaration targets"                       $PRINT_PADDING
            BuildTaskHelpLine h help    "<none>"    "print help screen and exit"                        $PRINT_PADDING
            BuildTaskHelpLine l list    "<none>"    "set all list targets"                              $PRINT_PADDING
            BuildTaskHelpLine t tab     "<none>"    "set all table targets"                             $PRINT_PADDING
            printf "\n   targets\n"
            BuildTaskHelpLine a all "<none>" "set all targets" $PRINT_PADDING

            BuildTaskHelpLine "<none>" cmd-decl "<none>" "target: command declarations" $PRINT_PADDING
            BuildTaskHelpLine "<none>" cmd-tab "<none>" "target: command table" $PRINT_PADDING

            BuildTaskHelpLine "<none>" dep-decl "<none>" "target: dependency decclarations" $PRINT_PADDING
            BuildTaskHelpLine "<none>" dep-tab "<none>" "target: dependency table" $PRINT_PADDING

            BuildTaskHelpLine "<none>" opt-decl "<none>" "target: option declarations" $PRINT_PADDING
            BuildTaskHelpLine "<none>" opt-tab "<none>" "target: option table" $PRINT_PADDING
            BuildTaskHelpLine "<none>" opt-list "<none>" "target: option list" $PRINT_PADDING

            BuildTaskHelpLine "<none>" param-decl "<none>" "target: parameter declarations" $PRINT_PADDING
            BuildTaskHelpLine "<none>" param-tab "<none>" "target: parameter table" $PRINT_PADDING

            BuildTaskHelpLine "<none>" task-decl "<none>" "target: task declarations" $PRINT_PADDING
            BuildTaskHelpLine "<none>" task-tab "<none>" "target: task table" $PRINT_PADDING
            exit 0
            ;;

        -a | --all)
            shift
            DO_ALL=true
            ;;
        -d | --decl)
            shift
            DO_DECL=true
            ;;
        -l | --list)
            shift
            DO_LIST=true
            ;;
        -t | --tab)
            shift
            DO_TAB=true
            ;;

        --cmd-decl)
            shift
            TARGET=$TARGET" cmd-decl"
            ;;
        --cmd-tab)
            shift
            TARGET=$TARGET" cmd-tab"
            ;;

        --dep-decl)
            shift
            TARGET=$TARGET" dep-decl"
            ;;
        --dep-tab)
            shift
            TARGET=$TARGET" dep-tab"
            ;;

        --opt-decl)
            shift
            TARGET=$TARGET" opt-decl"
            ;;
        --opt-list)
            shift
            TARGET=$TARGET" opt-list"
            ;;
        --opt-tab)
            shift
            TARGET=$TARGET" opt-tab"
            ;;

        --param-decl)
            shift
            TARGET=$TARGET" param-decl"
            ;;
        --param-tab)
            shift
            TARGET=$TARGET" param-tab"
            ;;

        --task-decl)
            shift
            TARGET=$TARGET" task-decl"
            ;;
        --task-tab)
            shift
            TARGET=$TARGET" task-tab"
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


if [ $DO_DECL == true ]; then
    TARGET="cmd-decl dep-decl opt-decl param-decl task-decl"
fi
if [ $DO_LIST == true ]; then
    TARGET="opt-list"
fi
if [ $DO_TAB == true ]; then
    TARGET="cmd-tab dep-tab opt-tab param-tab task-tab"
fi
if [ $DO_ALL == true ]; then
    TARGET="cmd-decl cmd-tab dep-decl dep-tab opt-decl opt-tab opt-list param-decl param-tab task-decl task-tab"
fi
if [ $DO_BUILD == true ]; then
    if [ ! -n "$TARGET" ]; then
        ConsoleError " ->" "build required, but no target set"
        exit 3
    fi
fi



############################################################################################
##
## ready to go
##
############################################################################################
ConsoleInfo "  -->" "bdc: starting task"
ConsoleResetErrors


PRINT_MODES="ansi text"

if [ $DO_CLEAN == true ]; then
    files=$(find -P ${CONFIG_MAP["HOME"]}/${APP_PATH_MAP["CACHE"]} -type f)
    if [ -n "$files" ]; then
        for file in $files; do
            rm $file
        done
    fi
fi

if [ $DO_BUILD == true ]; then
    ConsoleInfo "  -->" "build for target(s): $TARGET"
    for TODO in $TARGET; do
        ConsoleDebug "target: $TODO"
        case $TODO in
            cmd-decl)
                FILE=${CONFIG_MAP["HOME"]}/${APP_PATH_MAP["CACHE"]}/cmd-decl.map
                if [ -f $FILE ]; then
                    rm $FILE
                fi
                declare -p CMD_DECL_MAP > $FILE
                declare -p CMD_SHORT_MAP >> $FILE
                declare -p CMD_ARG_MAP >> $FILE
                declare -p CMD_DESCRIPTION_MAP >> $FILE
                ;;
            cmd-tab)
                for MODE in $PRINT_MODES; do
                    FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/cmd-tab.$MODE
                    if [ -f $FILE ]; then
                        rm $FILE
                    fi
                    declare -A COMMAND_TABLE
                    for ID in ${!CMD_DECL_MAP[@]}; do
                        COMMAND_TABLE[$ID]=$(CommandInTable $ID $MODE)
                    done
                    declare -p COMMAND_TABLE > $FILE
                done
                ;;
            dep-decl)
                FILE=${CONFIG_MAP["HOME"]}/${APP_PATH_MAP["CACHE"]}/dep-decl.map
                if [ -f $FILE ]; then
                    rm $FILE
                fi
                declare -p DEP_DECL_MAP > $FILE
                declare -p DEP_DECL_REQ >> $FILE
                declare -p DEP_COMMAND_MAP >> $FILE
                declare -p DEP_DESCRIPTION_MAP >> $FILE
                ;;
            dep-tab)
                for MODE in $PRINT_MODES; do
                    FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/dep-tab.$MODE
                    if [ -f $FILE ]; then
                        rm $FILE
                    fi
                    declare -A DEP_TABLE
                    for ID in ${!DEP_DECL_MAP[@]}; do
                        DEP_TABLE[$ID]=$(DependencyInTable $ID $MODE)
                    done
                    declare -p DEP_TABLE > $FILE
                done
                ;;
            opt-decl)
                FILE=${CONFIG_MAP["HOME"]}/${APP_PATH_MAP["CACHE"]}/opt-decl.map
                if [ -f $FILE ]; then
                    rm $FILE
                fi
                declare -p OPT_DECL_MAP > $FILE
                declare -p OPT_SHORT_MAP >> $FILE
                declare -p OPT_ARG_MAP >> $FILE
                declare -p OPT_DESCRIPTION_MAP >> $FILE
                declare -p OPT_META_MAP_EXIT >> $FILE
                declare -p OPT_META_MAP_RUNTIME >> $FILE
                ;;
            opt-tab)
                for MODE in $PRINT_MODES; do
                    FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/opt-tab.$MODE
                    if [ -f $FILE ]; then
                        rm $FILE
                    fi
                    declare -A OPTION_TABLE
                    for ID in ${!OPT_DECL_MAP[@]}; do
                        OPTION_TABLE[$ID]=$(OptionInTable $ID $MODE)
                    done
                    declare -p OPTION_TABLE > $FILE
                done
                ;;
            opt-list)
                for MODE in $PRINT_MODES; do
                    FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/opt-list.$MODE
                    if [ -f $FILE ]; then
                        rm $FILE
                    fi
                    declare -A OPTION_LIST
                    for ID in ${!OPT_DECL_MAP[@]}; do
                        OPTION_LIST[$ID]=$(OptionInList $ID $MODE)
                    done
                    declare -p OPTION_LIST > $FILE
                done
                if [ ! -z "${LOADED_TASKS["list-options"]}" ]; then
                    for MODE in $PRINT_MODES; do
                        FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/opt-list-help.$MODE
                        if [ -f $FILE ]; then
                            rm $FILE
                        fi
                        set +e
                        ${TASK_DECL_EXEC["list-options"]} -a -l -p $MODE > ${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/opt-list-help.$MODE
                        set -e
                    done
                else
                    ConsoleError " ->" "pdf: cannot test, task 'start-pdf' not loaded"
                fi
                ;;
            param-decl)
                FILE=${CONFIG_MAP["HOME"]}/${APP_PATH_MAP["CACHE"]}/param-decl.map
                if [ -f $FILE ]; then
                    rm $FILE
                fi
                declare -p PARAM_DECL_MAP > $FILE
                declare -p PARAM_DECL_DEFVAL >> $FILE
                declare -p PARAM_DESCRIPTION_MAP >> $FILE
                declare -p FILES >> $FILE
                declare -p DIRECTORIES >> $FILE
                declare -p DIRECTORIES_CD >> $FILE
                ;;
            param-tab)
                for MODE in $PRINT_MODES; do
                    FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/param-tab.$MODE
                    if [ -f $FILE ]; then
                        rm $FILE
                    fi
                    declare -A PARAM_TABLE
                    for ID in ${!PARAM_DECL_MAP[@]}; do
                        PARAM_TABLE[$ID]=$(ParameterInTable $ID $MODE)
                    done
                    declare -p PARAM_TABLE > $FILE
                done
                ;;
            task-decl)
                FILE=${CONFIG_MAP["HOME"]}/${APP_PATH_MAP["CACHE"]}/task-decl.map
                if [ -f $FILE ]; then
                    rm $FILE
                fi
                declare -p TASK_DECL_MAP > $FILE
                declare -p TASK_DECL_EXEC >> $FILE
                declare -p TASK_MODE_MAP >> $FILE
                declare -p TASK_ALIAS_MAP >> $FILE
                declare -p TASK_DESCRIPTION_MAP >> $FILE

                declare -p TASK_REQ_PARAM >> $FILE
                declare -p TASK_REQ_DEP >> $FILE
                declare -p TASK_REQ_TASK >> $FILE
                declare -p TASK_REQ_DIR >> $FILE
                declare -p TASK_REQ_FILE >> $FILE
                ;;
            task-tab)
                for MODE in $PRINT_MODES; do
                    FILE=${CONFIG_MAP["FW_HOME"]}/${APP_PATH_MAP["CACHE"]}/task-tab.$MODE
                    if [ -f $FILE ]; then
                        rm $FILE
                    fi
                    declare -A TASK_TABLE
                    for ID in ${!TASK_DECL_MAP[@]}; do
                        TASK_TABLE[$ID]=$(TaskInTable $ID $MODE)
                    done
                    declare -p TASK_TABLE > $FILE
                done
                ;;
            *)
                ConsoleError " ->" "bdc - unknown target $TODO"
        esac
        ConsoleDebug "done target - $TODO"
    done
    ConsoleInfo "  -->" "done build"
fi

ConsoleInfo "  -->" "bdc: done"
exit $TASK_ERRORS
