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



declare -A RTMAP_TASK_STATUS        # map [id]="status" -> Not Error Warn Success
declare -A RTMAP_TASK_LOADED        # array of loaded tasks [id]=ok
declare -A RTMAP_TASK_UNLOADED      # map of loaded tasks [id]=ok

RTMAP_TASK_LOADED["DUMMY"]=dummy
RTMAP_TASK_UNLOADED["DUMMY"]=dummy


declare -A RTMAP_DEP_STATUS         # map/export for dependency status: [id]=[N]ot-done, [S]uccess, [W]arning(s), [E]rrors
declare -A RTMAP_TASK_TESTED        # array/export for tested dependencies
RTMAP_TASK_TESTED["DUMMY"]=dummy

declare -A RTMAP_REQUESTED_DEP      # map for required dependencies
declare -A RTMAP_REQUESTED_PARAM    # map for required parameters
RTMAP_REQUESTED_DEP["DUMMY"]=dummy
RTMAP_REQUESTED_PARAM["DUMMY"]=dummy




##
## function: MissingReqIsError
## - determines if a missing requirement is an error
## - true or false
## $1: warning argument
##
MissingReqIsError() {
    if [[ -n "$WARN" ]]; then
        if [[ ${CONFIG_MAP["STRICT"]} == true ]]; then
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

    case "$ST_OLD" in
        N)
            echo "$ST_NEW"
            ;;
        E)
            case "$ST_NEW" in
                N)  echo N ;;
                *)  echo E ;;
            esac
            ;;
        W)
            case "$ST_NEW" in
                N | S | W)  echo W ;;
                E)          echo E ;;
            esac
            ;;
        S)
            case "$ST_NEW" in
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

    local OLD

    case "$ARTIFACT_TYPE" in
        dep)
            if [[ -z ${DMAP_DEP_ORIGIN[$ID]:-} ]]; then
                ConsoleError " ->" "set-artifact-status - unknown dependency '$ID'"
                return
            fi
            OLD=${RTMAP_DEP_STATUS[$ID]:-}
            ;;
        task)
            ID=$(GetTaskID $ID)
            if [[ -z ${DMAP_TASK_ORIGIN[$ID]:-} ]]; then
                ConsoleError " ->" "set-artifact-status - unknown task '$ID'"
                return
            fi
            OLD=${RTMAP_TASK_STATUS[$ID]:-}
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
        dep)    RTMAP_DEP_STATUS[$ID]=$(CalculateNewArtifactStatus $OLD $STATUS) ;;
        task)   RTMAP_TASK_STATUS[$ID]=$(CalculateNewArtifactStatus $OLD $STATUS) ;;
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

    if [[ ! -z "${DMAP_TASK_REQ_PARAM_MAN[$ID]:-}" ]]; then
        for PARAM in ${DMAP_TASK_REQ_PARAM_MAN[$ID]}; do
            ConsoleTrace "   $ID - param man $PARAM"
            if [[ -z ${DMAP_PARAM_ORIGIN[$PARAM]:-} ]]; then
                ConsoleError " ->" "process-task/param - $ID unknown parameter '$PARAM'"
                RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} par-id::$PARAM"
                SetArtifactStatus task $ID E
            else
                RTMAP_REQUESTED_PARAM[$PARAM]=$PARAM
                if [[ -z "${CONFIG_MAP[$PARAM]:-}" ]]; then
                    ConsoleError " ->" "process-task/param - $ID with unset parameter '$PARAM'"
                    RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} par-set::$PARAM"
                    SetArtifactStatus task $ID E
                else
                    SetArtifactStatus task $ID S
#                         RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} param"
                    RTMAP_TASK_LOADED[$ID]=ok
                    ConsoleDebug "process-task/param - processed '$ID' for parameter '$PARAM' with success"
                fi
            fi
        done
    fi

    if [[ ! -z "${DMAP_TASK_REQ_PARAM_OPT[$ID]:-}" ]]; then
        for PARAM in ${DMAP_TASK_REQ_PARAM_OPT[$ID]}; do
            ConsoleTrace "   $ID - param opt $PARAM"
            if [[ -z ${DMAP_PARAM_ORIGIN[$PARAM]:-} ]]; then
                ConsoleError " ->" "process-task/param - $ID unknown parameter '$PARAM'"
                RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} par-id::$PARAM"
                SetArtifactStatus task $ID E
            else
                RTMAP_REQUESTED_PARAM[$PARAM]=$PARAM
                if [[ -z "${CONFIG_MAP[$PARAM]:-}" ]]; then
                    ConsoleWarnStrict " ->" "process-task/param - $ID with unset parameter '$PARAM'"
                    if [[ ${CONFIG_MAP["STRICT"]} == "yes" ]]; then
                        RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} par-set::$PARAM"
                        SetArtifactStatus task $ID E
                    else
                        SetArtifactStatus task $ID W
#                                 RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} param"
                        RTMAP_TASK_LOADED[$ID]=ok
                        ConsoleDebug "process-task/param - processed '$ID' for parameter '$PARAM' with warn"
                    fi
                else
                    SetArtifactStatus task $ID S
#                             RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} param"
                    RTMAP_TASK_LOADED[$ID]=ok
                    ConsoleDebug "process-task/param - processed '$ID' for parameter '$PARAM' with success"
                fi
            fi
        done
    fi
}



##
## function: TestDependency
## - tests a dependency
## $1: dependency-id
##
TestDependency() {
    local DEP=$1

    RTMAP_REQUESTED_DEP[$DEP]=[$DEP]
    if [[ "${RTMAP_TASK_TESTED[$DEP]:-}" == "ok" ]]; then
        ConsoleDebug "process-task/dep - dependency '$DEP' already tested"
    else
        ConsoleDebug "process-task/dep - testing dependency '$DEP'"
        local COMMAND=${DMAP_DEP_CMD[$DEP]}
        if [[ "${COMMAND:0:1}" == "/" ]];then
            if [[ -n "$($COMMAND)" ]]; then
                RTMAP_TASK_TESTED[$DEP]="ok"
                SetArtifactStatus dep $DEP S
            else
                SetArtifactStatus dep $DEP E
            fi
        else
            if [[ -x "$(command -v $COMMAND)" ]]; then
                RTMAP_TASK_TESTED[$DEP]="ok"
                SetArtifactStatus dep $DEP S
            else
                SetArtifactStatus dep $DEP E
            fi
        fi
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

    if [[ ! -z "${DMAP_TASK_REQ_DEP_MAN[$ID]:-}" ]]; then
        for DEP in ${DMAP_TASK_REQ_DEP_MAN[$ID]}; do
            ConsoleTrace "   $ID - dep man $DEP"
            if [[ -z ${DMAP_DEP_ORIGIN[$DEP]:-} ]]; then
                ConsoleError " ->" "process-task/dep - $ID unknown dependency '$DEP'"
                RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} dep-id::$DEP"
                SetArtifactStatus task $ID E
            else
                TestDependency $DEP
                if [[ "${RTMAP_TASK_TESTED[$DEP]:-}" == "ok" ]]; then
                    SetArtifactStatus task $ID S
#                                 RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} dep"
                    RTMAP_TASK_LOADED[$ID]=ok
                    ConsoleDebug "process-task/dep - processed '$ID' for dependency '$DEP' with success"
                else
                    ConsoleError " ->" "process-task/dep - $ID dependency '$DEP' not found"
                    RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} dep-cmd::$DEP"
                    SetArtifactStatus task $ID E
                fi
            fi
        done
    fi

    if [[ ! -z "${DMAP_TASK_REQ_DEP_OPT[$ID]:-}" ]]; then
        for DEP in ${DMAP_TASK_REQ_DEP_OPT[$ID]}; do
            ConsoleTrace "   $ID - dep opt $DEP"
            if [[ -z ${DMAP_DEP_ORIGIN[$DEP]:-} ]]; then
                ConsoleError " ->" "process-task/dep - $ID unknown dependency '$DEP'"
                RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} dep-id::$DEP"
                SetArtifactStatus task $ID E
            else
                TestDependency $DEP
                if [[ "${RTMAP_TASK_TESTED[$DEP]:-}" == "ok" ]]; then
                    RTMAP_TASK_TESTED[$DEP]="ok"
                    SetArtifactStatus task $ID S
#                                 RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} dep"
                    RTMAP_TASK_LOADED[$ID]=ok
                    ConsoleDebug "process-task/dep - processed '$ID' for dependency '$DEP' with success"
                else
                    ConsoleWarnStrict " ->" "process-task/dep - $ID dependency '$DEP' not found"
                    if [[ ${CONFIG_MAP["STRICT"]} == "yes" ]]; then
                        RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} dep-cmd::$DEP"
                        SetArtifactStatus task $ID E
                    else
                        SetArtifactStatus task $ID W
#                                     RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} dep"
                        RTMAP_TASK_LOADED[$ID]=ok
                        ConsoleDebug "process-task/dep - processed '$ID' for dependency '$DEP' with warn"
                    fi
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

    if [[ ! -z "${DMAP_TASK_REQ_TASK_MAN[$ID]:-}" ]]; then
        for TASK in ${DMAP_TASK_REQ_TASK_MAN[$ID]}; do
            ConsoleTrace "   $ID - task man $TASK"
            if [[ -z ${DMAP_TASK_ORIGIN[$TASK]:-} ]]; then
                ConsoleError " ->" "process-task/task - $ID unknown task '$TASK'"
                RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} task-id::$TASK"
                SetArtifactStatus task $ID E
            else
                if [[ ! -z "${RTMAP_TASK_UNLOADED[$TASK]:-}" ]]; then
                    ConsoleError " ->" "process-task/task - $ID with unloaded task '$TASK'"
                    RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} task-set::$TASK"
                    SetArtifactStatus task $ID E
                else
                    SetArtifactStatus task $ID S
#                             RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} task"
                    RTMAP_TASK_LOADED[$ID]=ok
                    ConsoleDebug "process-task/task - processed '$ID' for task '$TASK' with success"
                fi
            fi
        done
    fi

    if [[ ! -z "${DMAP_TASK_REQ_TASK_OPT[$ID]:-}" ]]; then
        for TASK in ${DMAP_TASK_REQ_TASK_OPT[$ID]}; do
            ConsoleTrace "   $ID - task opt $TASK"
            if [[ -z ${DMAP_TASK_ORIGIN[$TASK]:-} ]]; then
                ConsoleError " ->" "process-task/task - $ID unknown task '$TASK'"
                RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} task-id::$TASK"
                SetArtifactStatus task $ID E
            else
                if [[ ! -z "${RTMAP_TASK_UNLOADED[$TASK]:-}" ]]; then
                    ConsoleWarnStrict " ->" "process-task/task - $ID with unloaded task '$TASK'"
                    if [[ ${CONFIG_MAP["STRICT"]} == "yes" ]]; then
                        RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} task-set::$TASK"
                        SetArtifactStatus task $ID E
                    else
                        SetArtifactStatus task $ID W
#                                 RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} task"
                        RTMAP_TASK_LOADED[$ID]=ok
                        ConsoleDebug "process-task/task - processed '$ID' for task '$TASK' with warn"
                    fi
                else
                    SetArtifactStatus task $ID S
#                             RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} task"
                    RTMAP_TASK_LOADED[$ID]=ok
                    ConsoleDebug "process-task/task - processed '$ID' for task '$TASK' with success"
                fi
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

    if [[ ! -z "${DMAP_TASK_REQ_DIR_MAN[$ID]:-}" ]]; then
        for DIR in ${DMAP_TASK_REQ_DIR_MAN[$ID]}; do
            ConsoleTrace "   $ID - dir man $DIR"
            if [[ ! -d $DIR ]]; then
                ConsoleError " ->" "process-task/dir - $ID not a directory '$DIR'"
                RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} dir::$DIR"
                SetArtifactStatus task $ID E
            else
                SetArtifactStatus task $ID S
#                         RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} dir"
                RTMAP_TASK_LOADED[$ID]=ok
                ConsoleDebug "process-task/dir - processed '$ID' for directory '$DIR' with success"
            fi
        done
    fi

    if [[ ! -z "${DMAP_TASK_REQ_DIR_OPT[$ID]:-}" ]]; then
        for DIR in ${DMAP_TASK_REQ_DIR_OPT[$ID]}; do
            ConsoleTrace "   $ID - dir opt $DIR"
            if [[ ! -d $DIR ]]; then
                ConsoleWarnStrict " ->" "process-task/dir - $ID not a directory '$DIR'"
                if [[ ${CONFIG_MAP["STRICT"]} == "yes" ]]; then
                    RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} dir::$DIR"
                    SetArtifactStatus task $ID E
                else
                    SetArtifactStatus task $ID W
#                             RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} dir"
                    RTMAP_TASK_LOADED[$ID]=ok
                    ConsoleDebug "process-task/dir - processed '$ID' for directory '$DIR' with warn"
                fi
            else
                SetArtifactStatus task $ID S
#                         RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} dir"
                RTMAP_TASK_LOADED[$ID]=ok
                ConsoleDebug "process-task/dir - processed '$ID' for directory '$DIR' with success"
            fi
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

    if [[ ! -z "${DMAP_TASK_REQ_FILE_MAN[$ID]:-}" ]]; then
        for FILE in ${DMAP_TASK_REQ_FILE_MAN[$ID]}; do
            ConsoleTrace "   $ID - file man $FILE"
            if [[ ! -f $FILE ]]; then
                ConsoleError " ->" "process-task/file - $ID not a file '$FILE'"
                RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} file::$FILE"
                SetArtifactStatus task $ID E
            else
                SetArtifactStatus task $ID S
#                         RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} file"
                RTMAP_TASK_LOADED[$ID]=ok
                ConsoleDebug "process-task/file - processed '$ID' for file '$FILE' with success"
            fi
        done
    fi

    if [[ ! -z "${DMAP_TASK_REQ_FILE_OPT[$ID]:-}" ]]; then
        for FILE in ${DMAP_TASK_REQ_FILE_OPT[$ID]}; do
            ConsoleTrace "   $ID - file opt $FILE"
            if [[ ! -f $FILE ]]; then
                ConsoleWarnStrict " ->" "process-task/file - $ID not a file '$FILE'"
                if [[ ${CONFIG_MAP["STRICT"]} == "yes" ]]; then
                    RTMAP_TASK_UNLOADED[$ID]="${RTMAP_TASK_UNLOADED[$ID]:-} file::$FILE"
                    SetArtifactStatus task $ID E
                else
                    SetArtifactStatus task $ID W
#                             RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} file"
                    RTMAP_TASK_LOADED[$ID]=ok
                    ConsoleDebug "process-task/file - processed '$ID' for file '$FILE' with warn"
                fi
            else
                SetArtifactStatus task $ID S
#                         RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} file"
                RTMAP_TASK_LOADED[$ID]=ok
                ConsoleDebug "process-task/file - processed '$ID' for file '$FILE' with success"
            fi
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
    for ID in "${!DMAP_DEP_ORIGIN[@]}"; do
         RTMAP_DEP_STATUS[$ID]="N"
    done
    for ID in "${!DMAP_TASK_ORIGIN[@]}"; do
        RTMAP_TASK_STATUS[$ID]="N"
    done

    ## run for decl, params, dep, dir, file first
    for ID in "${!DMAP_TASK_ORIGIN[@]}"; do
        case ${DMAP_TASK_MODES[$ID]} in
            *${CONFIG_MAP["APP_MODE"]}*)
#                 RTMAP_TASK_LOADED[$ID]="${RTMAP_TASK_LOADED[$ID]:-} mode"
                RTMAP_TASK_LOADED[$ID]=ok
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
    for ID in "${!DMAP_TASK_ORIGIN[@]}"; do
        case ${DMAP_TASK_MODES[$ID]} in
            *${CONFIG_MAP["APP_MODE"]}*)
                ProcessTaskReqTask $ID
                ;;
        esac
    done

    ## now remove all tasks from RTMAP_TASK_LOADED that are in RTMAP_TASK_UNLOADED
    for ID in "${!RTMAP_TASK_UNLOADED[@]}"; do
        if [[ ! -z "${RTMAP_TASK_LOADED[$ID]:-}" ]]; then
            unset RTMAP_TASK_LOADED[$ID]
        fi
    done

    ConsoleInfo "-->" "done"
}
