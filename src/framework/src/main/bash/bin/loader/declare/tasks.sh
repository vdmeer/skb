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
## Declare: tasks
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


declare -A TASK_DECL_MAP            # map/export for tasks: [id]="CFG:::file.sh", CFG used as origin, i.e. FW_HOME or HOME
declare -A TASK_DECL_EXEC           # map/export for decl task: [id]=executable
declare -A TASK_MODE_MAP            # map/export for task modes: [id]="modes"
declare -A TASK_ALIAS_MAP           # map/export for task aliases: [alias]=[task-id]
declare -A TASK_DESCRIPTION_MAP     # map/export for task descriptions: [id]="tag-line"
declare -A TASK_STATUS_MAP          # map/export for task status: [id]=[N]ot-done, [S]uccess, [W]arning(s), [E]rrors

declare -A LOADED_TASKS             # array/export for unloaded tasks
declare -A UNLOADED_TASKS           # array/export for unloaded tasks

declare -A TASK_REQ_PARAM           # map/export for task requires parameter, [taskid]=(param-id, ...)
declare -A TASK_REQ_DEP             # map/export for task requires dependency, [taskid]=(dependency-id, ...)
declare -A TASK_REQ_TASK            # map/export for task depending on other tasks, [taskid]=(task-id, ...)
declare -A TASK_REQ_DIR             # map/export for task requires directory, [taskid]=(dir, ...)
declare -A TASK_REQ_FILE            # map/export for task requires directory, [taskid]=(file, ...)


##
## set dummies for the runtime maps, declare errors otherwise
##
LOADED_TASKS["DUMMY"]=dummy
UNLOADED_TASKS["DUMMY"]=dummy
TASK_REQ_PARAM["DUMMY"]=HOME
TASK_REQ_DEP["DUMMY"]=gradle
TASK_REQ_TASK["DUMMY"]=sb
TASK_REQ_DIR["DUMMY"]=$FW_HOME
TASK_REQ_FILE["DUMMY"]=$FW_HOME/etc/version.txt



##
## function TaskRequire
## - sets requirements for task, realizes DSL for tasks
## $1: task-id
## $2: requirement type, one of: param, dep, dir, file, task
## $3: requirement value, param-id, dep-id, directory, file, task-id
## $4: warning, if set to anything
##
TaskRequire() {
    if [ -z $1 ]; then
        ConsoleError " ->" "task-require - no task ID given"
        return
    elif [ -z $2 ]; then
        ConsoleError " ->" "task-require - missing requirement type for task '$1'"
        return
    elif [ -z $3 ]; then
        ConsoleError " ->" "task-require - missing requirement value for task '$1'"
        return
    fi

    local ID=$1
    local TYPE=$2
    local VALUE=$3
    local OPTIONAL=${4:-}
    ConsoleDebug "task $ID requires '$TYPE' value '$VALUE' option '$OPTIONAL'"

    if [ -z $OPTIONAL ]; then
        OPTIONAL="man:::"
    else
        OPTIONAL="opt:::"
    fi

    case "$TYPE" in
        param)  TASK_REQ_PARAM[$ID]="${TASK_REQ_PARAM[$ID]:-} $OPTIONAL$VALUE" ;;
        dep)    TASK_REQ_DEP[$ID]="${TASK_REQ_DEP[$ID]:-} $OPTIONAL$VALUE" ;;
        task)   TASK_REQ_TASK[$ID]="${TASK_REQ_TASK[$ID]:-} $OPTIONAL$VALUE" ;;
        dir)    TASK_REQ_DIR[$ID]="${TASK_REQ_DIR[$ID]:-} $OPTIONAL$VALUE" ;;
        file)   TASK_REQ_FILE[$ID]="${TASK_REQ_FILE[$ID]:-} $OPTIONAL$VALUE" ;;
        *)      ConsoleError " ->" "task-require -task $ID requires unknown type '$TYPE'" ;;
    esac
}



##
## function: DeclareTasksOrigin
## - declares tasks from origin
## $1: origin, CONFIG_MAP identifier, i.e. FW_HOME or HOME
##
DeclareTasksOrigin() {
    local ORIGIN=$1

    ConsoleDebug "scanning $ORIGIN"
    local TASK_PATH=${CONFIG_MAP[$ORIGIN]}/${APP_PATH_MAP["TASK_DECL"]}
    if [ ! -d $TASK_PATH ]; then
        ConsoleError " ->" "declare task - did not find task directory '$TASK_PATH' at origin '$ORIGIN'"
    else
        local ID
        local TEST_ID
        local ALIAS
        local EXECUTABLE
        local EXEC_PATH
        local MODES
        local DESCRIPTION
        local NO_ERRORS=true
        local mode
        local files
        local file

        files=$(find -P $TASK_PATH -type f -name '*.id')
        if [ -n "$files" ]; then
            for file in $files; do
                ID=${file##*/}
                ID=${ID%.*}

                local HAVE_ERRORS=false

                ALIAS=
                EXEC_PATH=
                EXECUTABLE=
                MODES=
                DESCRIPTION=
                source "$file"

                if [ -z ${EXEC_PATH:-} ]; then
                    EXECUTABLE=${CONFIG_MAP[$ORIGIN]}/${APP_PATH_MAP["TASK_SCRIPT"]}/$ID.sh
                else
                    EXECUTABLE=${CONFIG_MAP[$ORIGIN]}/$EXEC_PATH/$ID.sh
                fi
                if [ ! -f $EXECUTABLE ]; then
                    ConsoleError " ->" "declare task - task '$ID' without script (executable)"
                    HAVE_ERRORS=true
                elif [ ! -x $EXECUTABLE ]; then
                    ConsoleError " ->" "declare task - task '$ID' script not executable"
                    HAVE_ERRORS=true
                fi

                if [ -z "${MODES:-}" ]; then
                    ConsoleError " ->" "declare task - task '$ID' has no modes defined"
                    HAVE_ERRORS=true
                else
                    for mode in $MODES; do
                        case $mode in
                            dev | build | use)
                                ConsoleDebug "task '$ID' found mode '$mode'"
                                ;;
                            *)
                                ConsoleError " ->" "declare task - task '$ID' with unknown mode '$mode'"
                                HAVE_ERRORS=true
                                ;;
                        esac
                    done
                fi

                if [ -z "${DESCRIPTION:-}" ]; then
                    ConsoleError " ->" "declare task - task '$ID' has no description"
                    HAVE_ERRORS=true
                fi

                if [ ! -z ${CMD_DECL_MAP[$ID]:-} ]; then
                    ConsoleError " ->" "declare task - task '$ID' already used as long shell command"
                    HAVE_ERRORS=true
                fi
                if [ ! -z ${CMD_SHORT_MAP[$ID]:-} ]; then
                    ConsoleError " ->" "declare task - task '$ID' already used as short shell command"
                    HAVE_ERRORS=true
                fi
                for TEST_ID in ${!CMD_DECL_MAP[@]}; do
                    if [ $TEST_ID == $ALIAS ];then
                        ConsoleError " ->" "declare task - task '$ID' alias '$ALIAS' already used as long shell command"
                        HAVE_ERRORS=true
                    fi
                done
                for TEST_ID in ${!CMD_SHORT_MAP[@]}; do
                    if [ "${CMD_SHORT_MAP[$TEST_ID]:-}" == "$ALIAS" ];then
                        ConsoleError " ->" "declare task - task '$ID' alias '$ALIAS' already used as short shell command"
                        HAVE_ERRORS=true
                    fi
                done

                if [ ! -z ${TASK_DECL_MAP[$ID]:-} ]; then
                    ConsoleError "    >" "overwriting ${TASK_DECL_MAP[$ID]%:::*}:::$ID with $ORIGIN:::$ID"
                    HAVE_ERRORS=true
                fi
                if [ ! -z ${ALIAS:-} ] && [ ! -z ${TASK_ALIAS_MAP[${ALIAS:-}]:-} ]; then
                    ConsoleError "    >" "overwriting task alias from ${TASK_ALIAS_MAP[$ALIAS]} to $ID"
                    HAVE_ERRORS=true
                fi
                if [ $HAVE_ERRORS == true ]; then
                    ConsoleError " ->" "declare task - could not declare task"
                    NO_ERRORS=false
                else
                    TASK_DECL_MAP[$ID]="$ORIGIN:::${file%.*}"
                    TASK_DECL_EXEC[$ID]=$EXECUTABLE
                    TASK_MODE_MAP[$ID]="$MODES"
                    TASK_DESCRIPTION_MAP[$ID]="$DESCRIPTION"
                    if [ ! -z ${ALIAS:-} ]; then
                        TASK_ALIAS_MAP[$ALIAS]=$ID
                    fi
                    ConsoleDebug "declared $ORIGIN:::$ID with alias '$ALIAS'"
                fi
            done
            if [ $NO_ERRORS == false ]; then
                ConsoleError " ->" "declare task - could not declare all tasks from '$ORIGIN'"
            fi
        else
            ConsoleWarn "    >" "no tasks (id files) found at '$ORIGIN'"
        fi
    fi
}



##
## function: DeclareTasks
## - declares tasks from multiple sources, writes to FLAVOR_HOME
##
DeclareTasks() {
    ConsoleInfo "-->" "declare tasks"
    ConsoleResetErrors

    DeclareTasksOrigin FW_HOME
    if [ "${CONFIG_MAP["FW_HOME"]}" != "$FLAVOR_HOME" ]; then
        DeclareTasksOrigin HOME
    fi
}
