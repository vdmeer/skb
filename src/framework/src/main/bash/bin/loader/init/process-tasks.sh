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
## Loader Initialisation: process tasks
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: MissingReqIsError
## - determines if a missing requirement is an error
## - true or false
## $1: warning argument
##
MissingReqIsError() {
    if [ -n "$WARN" ]; then
        if [ ${CONFIG_MAP["STRICT"]} == true ]; then
            return 0
        else
            return 1
        fi
    else
        return 0
    fi
}



##
## funct: CalculateNewArtifactStatus
## - calculates the new status
## $1: old status
## $2: new status
##
CalculateNewArtifactStatus() {
    local ST_OLD=$1
    local ST_NEW=$2

    case $ST_OLD in
        N)
            echo $ST_NEW
            ;;
        E)
            case $ST_NEW in
                N)  echo N ;;
                *)  echo E ;;
            esac
            ;;
        W)
            case $ST_NEW in
                N | S | W)  echo W ;;
                E)          echo E ;;
            esac
            ;;
        S)
            case $ST_NEW in
                N | S)      echo S ;;
                W)          echo W ;;
                E)          echo E ;;
            esac
            ;;
    esac
}



##
## function: SetArtifactStatus
## - sets the status of an artifact if new status is higher than old one
## $1: type, one of: task, dep
## $2: artifact ID
## $3: new status: (N, notdone), (S, success), (W, warning), (E, error)
##
SetArtifactStatus() {
    local ARTIFACT_TYPE=$1
    local ID=$2
    local STATUS=$3

    local ALIAS
    local OLD

    case "$ARTIFACT_TYPE" in
        dep)
            if [ -z ${DEP_DECL_MAP[$ID]:-} ]; then
                ConsoleError " ->" "set-artifact-status - unknown dependency '$ID'"
                return
            fi
            OLD=${DEP_STATUS_MAP[$ID]:-}
            ;;
        task)
            ID=$(GetTaskID $ID)
            if [ -z ${TASK_DECL_MAP[$ID]:-} ]; then
                ConsoleError " ->" "set-artifact-status - unknown task '$ID'"
                return
            fi
            OLD=${TASK_STATUS_MAP[$ID]:-}
            ;;
        *)
            ConsoleError " ->" "set-artifact-status - unknown artifact type '$ARTIFACT_TYPE'"
            return
            ;;
    esac

    case "$STATUS" in
        N | notdone)    STATUS=N ;;
        S | success)    STATUS=S ;;
        W | warning)    STATUS=W ;;
        E | error)      STATUS=E ;;
        *)
            ConsoleError " ->" "set-artifact-status - unknown status '$STATUS'"
            return
            ;;
    esac

    case "$ARTIFACT_TYPE" in
        dep)    DEP_STATUS_MAP[$ID]=$(CalculateNewArtifactStatus $OLD $STATUS) ;;
        task)   TASK_STATUS_MAP[$ID]=$(CalculateNewArtifactStatus $OLD $STATUS) ;;
    esac
}



##
## function: ProcessTaskReqParam
## - tests all required parameters for a task
## $1: task id
##
ProcessTaskReqParam() {
    local ID=$1
    local PARAM
    local MODE

    if [ ! -z "${TASK_REQ_PARAM[$ID]:-}" ]; then
        for PARAM in ${TASK_REQ_PARAM[$ID]}; do
            MODE=${PARAM%:::*}
            PARAM=${PARAM##*:::}

            if [ -z ${PARAM_DECL_MAP[$PARAM]:-} ]; then
                ConsoleError " ->" "process-task/param - $ID unknown parameter '$PARAM'"
                UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} par-id::$PARAM"
                SetArtifactStatus task $ID E
            else
                case $MODE in
                    man)
                        if [ -z "${CONFIG_MAP[$PARAM]:-}" ]; then
                            ConsoleError " ->" "process-task/param - $ID with unset parameter '$PARAM'"
                            UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} par-set::$PARAM"
                            SetArtifactStatus task $ID E
                        else
                            SetArtifactStatus task $ID S
                            LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} param"
                            ConsoleDebug "process-task/param - processed '$ID' for parameter '$PARAM' with success"
                        fi
                        ;;
                    opt)
                        if [ -z "${CONFIG_MAP[$PARAM]:-}" ]; then
                            ConsoleWarnStrict " ->" "process-task/param - $ID with unset parameter '$PARAM'"
                            if [ ${CONFIG_MAP["STRICT"]} == "yes" ]; then
                                UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} par-set::$PARAM"
                                SetArtifactStatus task $ID E
                            else
                                SetArtifactStatus task $ID W
                                LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} param"
                                ConsoleDebug "process-task/param - processed '$ID' for parameter '$PARAM' with warn"
                            fi
                        else
                            SetArtifactStatus task $ID S
                            LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} param"
                            ConsoleDebug "process-task/param - processed '$ID' for parameter '$PARAM' with success"
                        fi
                        ;;
                    *)
                        ConsoleError " ->" "process-task/param - $ID with unknown mode: $MODE"
                        ;;
                esac
            fi
        done
    fi
}



##
## function: ProcessTaskReqDep
## - tests all required dependencies for a task
## $1: task id
##
ProcessTaskReqDep() {
    local ID=$1
    local DEP
    local MODE
    local COMMAND
    local DEP_TEST

    if [ ! -z "${TASK_REQ_DEP[$ID]:-}" ]; then
        for DEP in ${TASK_REQ_DEP[$ID]}; do
            MODE=${DEP%:::*}
            DEP=${DEP##*:::}

            if [ -z ${DEP_DECL_MAP[$DEP]:-} ]; then
                ConsoleError " ->" "process-task/dep - $ID unknown dependency '$DEP'"
                UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} dep-id::$DEP"
                SetArtifactStatus task $ID E
            else
                if [ "${TESTED_DEPENDENCIES[$DEP]:-}" == "ok" ]; then
                    ConsoleDebug "process-task/dep - '$ID' for dependency '$DEP', already tested ok"
                else
                    ConsoleDebug "process-task/dep - processing '$ID' for dependency '$DEP'"
                    COMMAND=${DEP_COMMAND_MAP[$DEP]}
                    if [ "${COMMAND:0:1}" == "/" ];then
                        if [ -n "$($COMMAND)" ]; then
                            DEP_TEST=true
                            SetArtifactStatus dep $DEP S
                        else
                            DEP_TEST=false
                            SetArtifactStatus dep $DEP E
                        fi
                    else
                        if [ -x "$(command -v $COMMAND)" ]; then
                            DEP_TEST=true
                            SetArtifactStatus dep $DEP S
                        else
                            DEP_TEST=false
                            SetArtifactStatus dep $DEP E
                        fi
                    fi

                    case $MODE in
                        man)
                            if [ $DEP_TEST == false ]; then
                                ConsoleError " ->" "process-task/dep - $ID dependency '$DEP' not found"
                                UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} dep-cmd::$DEP"
                                SetArtifactStatus task $ID E
                            else
                                TESTED_DEPENDENCIES[$DEP]="ok"
                                SetArtifactStatus task $ID S
                                LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} dep"
                                ConsoleDebug "process-task/dep - processed '$ID' for dependency '$DEP' with success"
                            fi
                            ;;
                        opt)
                            if [ $DEP_TEST == false ]; then
                                ConsoleWarnStrict " ->" "process-task/dep - $ID dependency '$DEP' not found"
                                if [ ${CONFIG_MAP["STRICT"]} == "yes" ]; then
                                    UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} dep-cmd::$DEP"
                                    SetArtifactStatus task $ID E
                                else
                                    SetArtifactStatus task $ID W
                                    LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} dep"
                                    ConsoleDebug "process-task/dep - processed '$ID' for dependency '$DEP' with warn"
                                fi
                            else
                                TESTED_DEPENDENCIES[$DEP]="ok"
                                SetArtifactStatus task $ID S
                                LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} dep"
                                ConsoleDebug "process-task/dep - processed '$ID' for dependency '$DEP' with success"
                            fi
                            ;;
                        *)
                            ConsoleError " ->" "process-task/dep - $ID with unknown mode: $MODE"
                            ;;
                    esac
                fi
            fi
        done
    fi
}


##
## function: ProcessTaskReqTask
## - tests all required tasks for a task
## ! does not test against unloaded tasks!
## $1: task id
##
ProcessTaskReqTask() {
    local ID=$1
    local TASK
    local MODE

    if [ ! -z "${TASK_REQ_TASK[$ID]:-}" ]; then
        for TASK in ${TASK_REQ_TASK[$ID]}; do
            MODE=${TASK%:::*}
            TASK=${TASK##*:::}

            if [ -z ${TASK_DECL_MAP[$TASK]:-} ]; then
                ConsoleError " ->" "process-task/task - $ID unknown task '$TASK'"
                UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} task-id::$TASK"
                SetArtifactStatus task $ID E
            else
                case $MODE in
                    man)
                        if [ ! -z "${UNLOADED_TASKS[$TASK]:-}" ]; then
                            ConsoleError " ->" "process-task/task - $ID with unloaded task '$TASK'"
                            UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} task-set::$TASK"
                            SetArtifactStatus task $ID E
                        else
                            SetArtifactStatus task $ID S
                            LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} task"
                            ConsoleDebug "process-task/task - processed '$ID' for task '$TASK' with success"
                        fi
                        ;;
                    opt)
                        if [ ! -z "${UNLOADED_TASKS[$TASK]:-}" ]; then
                            ConsoleWarnStrict " ->" "process-task/task - $ID with unloaded task '$TASK'"
                            if [ ${CONFIG_MAP["STRICT"]} == "yes" ]; then
                                UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} task-set::$TASK"
                                SetArtifactStatus task $ID E
                            else
                                SetArtifactStatus task $ID W
                                LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} task"
                                ConsoleDebug "process-task/task - processed '$ID' for task '$TASK' with warn"
                            fi
                        else
                            SetArtifactStatus task $ID S
                            LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} task"
                            ConsoleDebug "process-task/task - processed '$ID' for task '$TASK' with success"
                        fi
                        ;;
                    *)
                        ConsoleError " ->" "process-task/task - $ID with unknown mode: $MODE"
                        ;;
                esac
            fi
        done
    fi
}



##
## function: ProcessTaskReqDir
## - tests all required directories for a task
## $1: task id
##
ProcessTaskReqDir() {
    local ID=$1
    local DIR
    local MODE

    if [ ! -z "${TASK_REQ_DIR[$ID]:-}" ]; then
        for DIR in ${TASK_REQ_DIR[$ID]}; do
            MODE=${DIR%:::*}
            DIR=${DIR##*:::}

            case $MODE in
                man)
                    if [ ! -d $DIR ]; then
                        ConsoleError " ->" "process-task/dir - $ID not a directory '$DIR'"
                        UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} dir::$DIR"
                        SetArtifactStatus task $ID E
                    else
                        SetArtifactStatus task $ID S
                        LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} dir"
                        ConsoleDebug "process-task/dir - processed '$ID' for directory '$DIR' with success"
                    fi
                    ;;
                opt)
                    if [ ! -d $DIR ]; then
                        ConsoleWarnStrict " ->" "process-task/dir - $ID not a directory '$DIR'"
                        if [ ${CONFIG_MAP["STRICT"]} == "yes" ]; then
                            UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} dir::$DIR"
                            SetArtifactStatus task $ID E
                        else
                            SetArtifactStatus task $ID W
                            LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} dir"
                            ConsoleDebug "process-task/dir - processed '$ID' for directory '$DIR' with warn"
                        fi
                    else
                        SetArtifactStatus task $ID S
                        LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} dir"
                        ConsoleDebug "process-task/dir - processed '$ID' for directory '$DIR' with success"
                    fi
                    ;;
                *)
                    ConsoleError " ->" "process-task/dir - $ID with unknown mode: $MODE"
                    ;;
            esac
        done
    fi
}



##
## function: ProcessTaskReqFile
## - tests all required files for a task
## $1: task id
##
ProcessTaskReqFile() {
    local ID=$1
    local FILE
    local MODE

    if [ ! -z "${TASK_REQ_FILE[$ID]:-}" ]; then
        for FILE in ${TASK_REQ_FILE[$ID]}; do
            MODE=${FILE%:::*}
            FILE=${FILE##*:::}

            case $MODE in
                man)
                    if [ ! -f $FILE ]; then
                        ConsoleError " ->" "process-task/file - $ID not a file '$FILE'"
                        UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} file::$FILE"
                        SetArtifactStatus task $ID E
                    else
                        SetArtifactStatus task $ID S
                        LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} file"
                        ConsoleDebug "process-task/file - processed '$ID' for file '$FILE' with success"
                    fi
                    ;;
                opt)
                    if [ ! -f $FILE ]; then
                        ConsoleWarnStrict " ->" "process-task/file - $ID not a file '$FILE'"
                        if [ ${CONFIG_MAP["STRICT"]} == "yes" ]; then
                            UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} file::$FILE"
                            SetArtifactStatus task $ID E
                        else
                            SetArtifactStatus task $ID W
                            LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} file"
                            ConsoleDebug "process-task/file - processed '$ID' for file '$FILE' with warn"
                        fi
                    else
                        SetArtifactStatus task $ID S
                        LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} file"
                        ConsoleDebug "process-task/file - processed '$ID' for file '$FILE' with success"
                    fi
                    ;;
                *)
                    ConsoleError " ->" "process-task/file - $ID with unknown mode: $MODE"
                    ;;
            esac
        done
    fi
}



##
## function: ProcessTasks
## - process all tasks
##
ProcessTasks() {
    ConsoleResetErrors
    ConsoleInfo "-->" "process tasks"

    local ID
    local PARAM

    ## initialize the status maps
    for ID in "${!DEP_DECL_MAP[@]}"; do
         DEP_STATUS_MAP[$ID]="N"
    done
    for ID in "${!TASK_DECL_MAP[@]}"; do
        TASK_STATUS_MAP[$ID]="N"
    done

    ## run for decl, params, dep, dir, file first
    for ID in "${!TASK_DECL_MAP[@]}"; do
        case ${TASK_MODE_MAP[$ID]} in
            *${CONFIG_MAP["APP_MODE"]}*)
                LOADED_TASKS[$ID]="${LOADED_TASKS[$ID]:-} mode"
                ConsoleDebug "process-task/mode - processed '$ID' for mode with success"
                SetArtifactStatus task $ID S

                ProcessTaskReqParam $ID
                ProcessTaskReqDep $ID
                ProcessTaskReqDir $ID
                ProcessTaskReqFile $ID
                ;;
            *)
                ConsoleDebug "task '$ID' not defined for current mode '${CONFIG_MAP["APP_MODE"]}', not loaded"
                SetArtifactStatus task $ID N
                ;;
        esac
    done

    ## run for tasks again
    for ID in "${!TASK_DECL_MAP[@]}"; do
        case ${TASK_MODE_MAP[$ID]} in
            *${CONFIG_MAP["APP_MODE"]}*)
                ProcessTaskReqTask $ID
                ;;
        esac
    done

    ## now remove all tasks from LOADED_TASKS that are in UNLOADED_TASKS
    for ID in "${!UNLOADED_TASKS[@]}"; do
        if [ ! -z "${LOADED_TASKS[$ID]:-}" ]; then
            unset LOADED_TASKS[$ID]
        fi
    done

    ConsoleInfo "-->" "done"
}



# UnloadTasks() {
#     if IsVerbose; then printf "\n"; PrintInfo "-->" "unloading tasks with $1"; fi
#     for _task_id in ${_remove_task[@]}; do
#         unset TASK_DECL_MAP[$_task_id]
#         unset TASK_DECL_MAP_DESCRIPTION[$_task_id]
#         unset TASK_ALIAS_MAP[$_task_id]
#         unset TASK_DEP_PARAM[$_task_id]
#         unset TASK_DEP_EXT[$_task_id]
#         unset TASK_DEP_PATH[$_task_id]
#         _unloaded_tasks=true
#     done
# }
# 
# if [ $__error == false ]; then
#     if IsVerbose; then PrintInfo "-->" "found all dependencies and requirements"; fi
# fi
# if [ $__error == true ]; then
#     if IsVerbose; then PrintWarn "   " "missing dependencies or requirements, some tasks not loaded"; fi
#     if [ "${CONFIG["STRICT_MODE"]:-}" == "yes" ]; then
#         PrintError "${CONFIG["NAME_SCRIPT"]}:" "missing dependencies or requirements in strict mode, cannot continue"
#         exit -9
#     fi
# fi


#     local TASK
#     for ID in ${!TASK_REQ_TASK[@]}; do
#         for TASK in ${TASK_REQ_TASK[$ID]}; do
#             case "${!UNLOADED_TASKS[@]}" in
#                 $TASK)
#                     ConsoleError " -> " "load-task - $ID depends on task unloaded '$TASK'"
#                     UNLOADED_TASKS[$ID]="${UNLOADED_TASKS[$ID]:-} tsk-unload::$TASK"
#                     SetArtifactStatus task $ID W
#                     ;;
#             esac
#         done
#     done