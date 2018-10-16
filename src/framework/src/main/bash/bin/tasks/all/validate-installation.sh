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
## validate-installation - validates an installation
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
source $FW_HOME/bin/functions/describe/_include
ConsoleResetErrors
ConsoleResetWarnings


##
## set local variables
##
DO_ALL=false
DO_STRICT=false
TARGET=
CLI_SET=false



##
## set CLI options and parse CLI
##
CLI_OPTIONS=ahs
CLI_LONG_OPTIONS=all,help,strict,man-src,cmd,dep,opt,param,task
CLI_LONG_OPTIONS+=,cmd-decl,cmd-tab
CLI_LONG_OPTIONS+=,dep-decl,dep-tab
CLI_LONG_OPTIONS+=,opt-decl,opt-tab,opt-list
CLI_LONG_OPTIONS+=,param-decl,param-tab
CLI_LONG_OPTIONS+=,task-decl,task-tab

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name validate-installation -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    ConsoleError "  ->" "unknown CLI options"
    exit 1
fi
eval set -- "$PARSED"

PRINT_PADDING=19
while true; do
    case "$1" in
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine h help    "<none>"    "print help screen and exit"        $PRINT_PADDING
            BuildTaskHelpLine s strict  "<none>"    "run in strict mode"                $PRINT_PADDING

            printf "\n   targets\n"
            BuildTaskHelpLine a all "<none>" "set all targets" $PRINT_PADDING

            BuildTaskHelpLine "<none>" man-src "<none>" "target: manual source" $PRINT_PADDING

            BuildTaskHelpLine "<none>" cmd "<none>" "target: commands" $PRINT_PADDING
            BuildTaskHelpLine "<none>" dep "<none>" "target: dependencies" $PRINT_PADDING
            BuildTaskHelpLine "<none>" opt "<none>" "target: options" $PRINT_PADDING
            BuildTaskHelpLine "<none>" param "<none>" "target: parameters" $PRINT_PADDING
            BuildTaskHelpLine "<none>" task "<none>" "target: tasks" $PRINT_PADDING
            exit 0
            ;;

        -s | --strict)
            shift
            DO_STRICT=true
            ;;

        -a | --all)
            shift
            DO_ALL=true
            CLI_SET=true
            ;;
        --man-src)
            shift
            TARGET=$TARGET" man-src"
            CLI_SET=true
            ;;

        --cmd)
            shift
            TARGET=$TARGET" cmd"
            CLI_SET=true
            ;;
        --dep)
            shift
            TARGET=$TARGET" dep"
            CLI_SET=true
            ;;
        --opt)
            shift
            TARGET=$TARGET" opt"
            CLI_SET=true
            ;;
        --param)
            shift
            TARGET=$TARGET" param"
            CLI_SET=true
            ;;
        --task)
            shift
            TARGET=$TARGET" task"
            CLI_SET=true
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
if [[ $DO_ALL == true ]]; then
    TARGET="man-src cmd dep opt param task"
elif [[ $CLI_SET == false ]]; then
    TARGET="man-src cmd dep opt param task"
fi



############################################################################################
##
## function: Validate MANUAL SOURCE
##
############################################################################################
ValidateManualSource() {
    ConsoleDebug "validating manual source"

    local files
    local found
    local EXPECTED
    local EXP
    local FILE
    local SOURCE
    local DIR=${CONFIG_MAP["MANUAL_SRC"]}

    if [[ ! -d ${CONFIG_MAP["MANUAL_SRC"]}/tags ]]; then
        ConsoleError " ->" "did not find tag directory"
    else
        EXPECTED="tags/name tags/authors"
        for FILE in $EXPECTED; do
            if [[ ! -f ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.txt ]]; then
                ConsoleWarnStrict "  ->" "missing file $FILE.txt"
            elif [[ ! -r ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.txt ]]; then
                ConsoleWarnStrict "  ->" "cannot read file $FILE.txt"
            fi
        done

        files=$(find -P ${CONFIG_MAP["MANUAL_SRC"]}/tags -type f)
        for FILE in $files; do
            found=false
            for EXP in $EXPECTED; do
                tmp=$EXP".txt"
                if [[ "$FILE" == *$tmp ]]; then
                    found=true
                fi
            done
            if [[ $found == false ]]; then
                ConsoleWarnStrict "  ->" "found extra file tags/${FILE##*/}"
            fi
        done
    fi

    if [[ ! -d ${CONFIG_MAP["MANUAL_SRC"]}/framework ]]; then
        ConsoleError " ->" "did not find tag directory"
    else
        EXPECTED="framework/commands framework/dependencies framework/exit-options framework/exit-status framework/options framework/parameters framework/run-options framework/tasks"
        for FILE in $EXPECTED; do
            if [[ ! -f ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.adoc ]]; then
                ConsoleWarnStrict "  ->" "missing file $FILE.adoc"
            elif [[ ! -r ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.adoc ]]; then
                ConsoleWarnStrict "  ->" "cannot read file $FILE.adoc"
            fi
            if [[ ! -f ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.txt ]]; then
                ConsoleWarnStrict "  ->" "missing file $FILE.txt"
            elif [[ ! -r ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.txt ]]; then
                ConsoleWarnStrict "  ->" "cannot read file $FILE.txt"
            fi
        done

        files=$(find -P ${CONFIG_MAP["MANUAL_SRC"]}/framework -type f)
        for FILE in $files; do
            found=false
            for EXP in $EXPECTED; do
                tmp=$EXP".adoc"
                if [[ "$FILE" == *$tmp ]]; then
                    found=true
                fi
                tmp=$EXP".txt"
                if [[ "$FILE" == *$tmp ]]; then
                    found=true
                fi
            done
            if [[ $found == false ]]; then
                ConsoleWarnStrict "  ->" "found extra file framework/${FILE##*/}"
            fi
        done
    fi

    if [[ ! -d ${CONFIG_MAP["MANUAL_SRC"]}/application ]]; then
        ConsoleError " ->" "did not find tag directory"
    else
        EXPECTED="application/description application/authors application/bugs application/copying application/resources application/security"
        for FILE in $EXPECTED; do
            if [[ ! -f ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.adoc ]]; then
                ConsoleWarnStrict "  ->" "missing file $FILE.adoc"
            elif [[ ! -r ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.adoc ]]; then
                ConsoleWarnStrict "  ->" "cannot read file $FILE.adoc"
            fi
            if [[ ! -f ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.txt ]]; then
                ConsoleWarnStrict "  ->" "missing file $FILE.txt"
            elif [[ ! -r ${CONFIG_MAP["MANUAL_SRC"]}/$FILE.txt ]]; then
                ConsoleWarnStrict "  ->" "cannot read file $FILE.txt"
            fi
        done

        files=$(find -P ${CONFIG_MAP["MANUAL_SRC"]}/application -type f)
        for FILE in $files; do
            found=false
            for EXP in $EXPECTED; do
                tmp=$EXP".adoc"
                if [[ "$FILE" == *$tmp ]]; then
                    found=true
                fi
                tmp=$EXP".txt"
                if [[ "$FILE" == *$tmp ]]; then
                    found=true
                fi
            done
            if [[ $found == false ]]; then
                ConsoleWarnStrict "  ->" "found extra file application/${FILE##*/}"
            fi
        done
    fi

    ConsoleDebug "done"
}



############################################################################################
##
## function: Validate COMMAND
##
############################################################################################
ValidateCommandDocs() {
    ConsoleDebug "validating command docs"

    local ID
    local SOURCE
    for ID in ${!DMAP_CMD[@]}; do
        SOURCE=${CONFIG_MAP["FW_HOME"]}/${FW_PATH_MAP["COMMANDS"]}/$ID
        if [[ ! -f $SOURCE.adoc ]]; then
            ConsoleWarnStrict " ->" "commands '$ID' without ADOC file"
        elif [[ ! -r $SOURCE.adoc ]]; then
            ConsoleWarnStrict " ->" "commands '$ID' ADOC file not readable"
        fi
        if [[ ! -f $SOURCE.txt ]]; then
            ConsoleWarnStrict " ->" "commands '$ID' without TXT file"
        elif [[ ! -r $SOURCE.txt ]]; then
            ConsoleWarnStrict " ->" "commands '$ID' TXT file not readable"
        fi
    done

    ConsoleDebug "done"
}

ValidateCommand() {
    ConsoleDebug "validating command"

    ValidateCommandDocs

    local ID
    local ORIGIN_PATH=${CONFIG_MAP["FW_HOME"]}
    local files
    local file

    ## check that files in the command folder have a corresponding command declaration
    if [[ -d $ORIGIN_PATH/${FW_PATH_MAP["COMMANDS"]} ]]; then
        files=$(find -P $ORIGIN_PATH/${FW_PATH_MAP["COMMANDS"]} -type f)
        for file in $files; do
            ID=${file##*/}
            ID=${ID%.*}
            if [[ -z ${DMAP_CMD[$ID]:-} ]]; then
                ConsoleError " ->" "validate/cmd - found extra file FW_HOME/${FW_PATH_MAP["COMMANDS"]}, command '$ID' not declared"
            fi
        done
    fi

    ConsoleDebug "done"
}



############################################################################################
##
## function: Validate DEPENDENCY
##
############################################################################################
ValidateDependencyDocs() {
    ConsoleDebug "validating command docs"

    local ID
    local SOURCE
    for ID in ${!DMAP_DEP_DECL[@]}; do
        SOURCE=${DMAP_DEP_DECL[$ID]}
        if [[ ! -f $SOURCE.adoc ]]; then
            ConsoleWarnStrict " ->" "dependency '$ID' without ADOC file"
        elif [[ ! -r $SOURCE.adoc ]]; then
            ConsoleWarnStrict " ->" "dependency '$ID' ADOC file not readable"
        fi
        if [[ ! -f $SOURCE.txt ]]; then
            ConsoleWarnStrict " ->" "dependency '$ID' without TXT file"
        elif [[ ! -r $SOURCE.txt ]]; then
            ConsoleWarnStrict " ->" "dependency '$ID' TXT file not readable"
        fi
    done

    ConsoleDebug "done"
}

ValidateDependencyOrigin() {
    local ORIGIN=$1
    ConsoleDebug "validating command docs $ORIGIN"

    local ID
    local ORIGIN_PATH=${CONFIG_MAP[$ORIGIN]}
    local files
    local file

    ## check that files in the dependency folder have a corresponding dependency declaration
    if [[ -d $ORIGIN_PATH/${APP_PATH_MAP["DEP_DECL"]} ]]; then
        files=$(find -P $ORIGIN_PATH/${APP_PATH_MAP["DEP_DECL"]} -type f)
        for file in $files; do
            ID=${file##*/}
            ID=${ID%.*}
            if [[ -z ${DMAP_DEP_ORIGIN[$ID]:-} ]]; then
                ConsoleError " ->" "validate/dep - found extra file $ORIGIN/${APP_PATH_MAP["DEP_DECL"]}, dependency '$ID' not declared"
            fi
        done
    fi

    ConsoleDebug "done"
}

ValidateDependency() {
    ConsoleDebug "validating dependency"

    ValidateDependencyDocs
    ValidateDependencyOrigin FW_HOME
    if [[ "${CONFIG_MAP["FW_HOME"]}" != "${CONFIG_MAP["HOME"]}" ]]; then
        ValidateDependencyOrigin HOME
    fi

    ConsoleDebug "done"
}



############################################################################################
##
## function: Validate OPTION
##
############################################################################################
ValidateOptionDocs() {
    ConsoleDebug "validating option docs"

    local ID
    local SOURCE
    local OPT_PATH
    for ID in ${!DMAP_OPT_ORIGIN[@]}; do
        OPT_PATH=${DMAP_OPT_ORIGIN[$ID]:-}
        if [[ "$OPT_PATH" != "" ]]; then
            SOURCE=${CONFIG_MAP["FW_HOME"]}/${FW_PATH_MAP["OPTIONS"]}/$OPT_PATH/$ID
            if [[ ! -f $SOURCE.adoc ]]; then
                ConsoleWarnStrict " ->" "exit option '$ID' without ADOC file"
            elif [[ ! -r $SOURCE.adoc ]]; then
                ConsoleWarnStrict " ->" "exit option '$ID' ADOC file not readable"
            fi
            if [[ ! -f $SOURCE.txt ]]; then
                ConsoleWarnStrict " ->" "exit option '$ID' without TXT file"
            elif [[ ! -r $SOURCE.txt ]]; then
                ConsoleWarnStrict " ->" "exit option '$ID' TXT file not readable"
            fi
        fi
    done

    ConsoleDebug "done"
}

ValidateOption() {
    ConsoleDebug "validating option"

    ValidateOptionDocs

    local ID
    local ORIGIN_PATH=${CONFIG_MAP["FW_HOME"]}
    local files
    local file

    ## check that files in the option folder have a corresponding option declaration
    if [[ -d $ORIGIN_PATH/${FW_PATH_MAP["OPTIONS"]} ]]; then
        files=$(find -P $ORIGIN_PATH/${FW_PATH_MAP["OPTIONS"]} -type f)
        for file in $files; do
            ID=${file##*/}
            ID=${ID%.*}
            if [[ -z ${DMAP_OPT_ORIGIN[$ID]:-} ]]; then
                ConsoleError " ->" "validate/opt - found extra file FW_HOME/${FW_PATH_MAP["OPTIONS"]}, option '$ID' not declared"
            fi
        done
    fi

    ConsoleDebug "done"
}



############################################################################################
##
## function: Validate PARAMETER
##
############################################################################################
ValidateParameterDocs() {
    ConsoleDebug "validating parameter docs"

    local ID
    local SOURCE
    for ID in ${!DMAP_PARAM_DECL[@]}; do
        SOURCE=${DMAP_PARAM_DECL[$ID]}
        if [[ ! -f $SOURCE.adoc ]]; then
            ConsoleWarnStrict " ->" "parameter '$ID' without ADOC file"
        elif [[ ! -r $SOURCE.adoc ]]; then
            ConsoleWarnStrict " ->" "parameter '$ID' ADOC file not readable"
        fi
        if [[ ! -f $SOURCE.txt ]]; then
            ConsoleWarnStrict " ->" "parameter '$ID' without TXT file"
        elif [[ ! -r $SOURCE.txt ]]; then
            ConsoleWarnStrict " ->" "parameter '$ID' TXT file not readable"
        fi
    done

    ConsoleDebug "done"
}

ValidateParameterOrigin() {
    local ORIGIN=$1
    ConsoleDebug "validating parameter $ORIGIN"

    local ID
    local ORIGIN_PATH=${CONFIG_MAP[$ORIGIN]}
    local files
    local file

    ## check that files in the parameter folder have a corresponding parameter declaration
    if [[ -d $ORIGIN_PATH/${APP_PATH_MAP["PARAM_DECL"]} ]]; then
        files=$(find -P $ORIGIN_PATH/${APP_PATH_MAP["PARAM_DECL"]} -type f)
        for file in $files; do
            ID=${file##*/}
            ID=${ID%.*}
            if [[ -z ${DMAP_PARAM_ORIGIN[$ID]:-} ]]; then
                ConsoleError " ->" "validate/param - found extra file $ORIGIN/${APP_PATH_MAP["PARAM_DECL"]}, parameter '$ID' not declared"
            fi
        done
    fi

    ConsoleDebug "done"
}

ValidateParameter() {
    ConsoleDebug "validating parameter"

    ValidateParameterDocs
    ValidateParameterOrigin FW_HOME
    if [[ "${CONFIG_MAP["FW_HOME"]}" != "${CONFIG_MAP["HOME"]}" ]]; then
        ValidateParameterOrigin HOME
    fi

    ConsoleDebug "done"
}



############################################################################################
##
## function: Validate TASK
##
############################################################################################
ValidateTaskDocs() {
    ConsoleDebug "validating task docs"

    local ID
    local SOURCE
    for ID in ${!DMAP_TASK_DECL[@]}; do
        SOURCE=${DMAP_TASK_DECL[$ID]}
        if [[ ! -f $SOURCE.adoc ]]; then
            ConsoleWarnStrict " ->" "task '$ID' without ADOC file"
        elif [[ ! -r $SOURCE.adoc ]]; then
            ConsoleWarnStrict " ->" "task '$ID' ADOC file not readable"
        fi
        if [[ ! -f $SOURCE.txt ]]; then
            ConsoleWarnStrict " ->" "task '$ID' without TXT file"
        elif [[ ! -r $SOURCE.txt ]]; then
            ConsoleWarnStrict " ->" "task '$ID' TXT file not readable"
        fi
    done

    ConsoleDebug "done"
}

ValidateTaskOrigin() {
    local ORIGIN=$1
    ConsoleDebug "validating task $ORIGIN"

    local ID
    local ORIGIN_PATH=${CONFIG_MAP[$ORIGIN]}
    local files
    local file

    ## check that files in the task folder have a corresponding task declaration
    if [[ -d $ORIGIN_PATH/${APP_PATH_MAP["TASK_DECL"]} ]]; then
        files=$(find -P $ORIGIN_PATH/${APP_PATH_MAP["TASK_DECL"]} -type f)
        for file in $files; do
            ID=${file##*/}
            ID=${ID%.*}
            if [[ -z ${DMAP_TASK_DECL[$ID]:-} ]]; then
                ConsoleError " ->" "validate/task - found extra file $ORIGIN/${APP_PATH_MAP["TASK_DECL"]}, task '$ID' not declared"
            fi
        done
    fi

    ## check for extra files in task executables directory
    if [[ -d $ORIGIN_PATH/${APP_PATH_MAP["TASK_SCRIPT"]} ]]; then
        files=$(find -P $ORIGIN_PATH/${APP_PATH_MAP["TASK_SCRIPT"]}  -type f)
        for file in $files; do
            ID=${file##*/}
            ID=${ID%.*}
            if [[ -z ${DMAP_TASK_EXEC[$ID]:-} ]]; then
                ConsoleError " ->" "validate/task - found extra file $ORIGIN/${APP_PATH_MAP["TASK_SCRIPT"]}, task '$ID' not declared"
            fi
        done
    fi

    ConsoleDebug "done"
}

ValidateTask() {
    ConsoleDebug "validating task"

    ValidateTaskDocs
    ValidateTaskOrigin FW_HOME
    if [[ "${CONFIG_MAP["FW_HOME"]}" != "${CONFIG_MAP["HOME"]}" ]]; then
        ValidateTaskOrigin HOME
    fi

    ConsoleDebug "done"
}



############################################################################################
##
## ready to go
##
############################################################################################
ConsoleInfo "  -->" "vi: starting task"
ConsoleResetErrors

ConsoleInfo "  -->" "validate target(s): $TARGET"

OLD_STRICT=${CONFIG_MAP["STRICT"]}
if [[ "$DO_STRICT" == true ]]; then
    CONFIG_MAP["STRICT"]=yes
fi
for TODO in $TARGET; do
    ConsoleDebug "target: $TODO"
    case $TODO in
        man-src)
            ConsoleInfo "  -->" "validating manual source"
            ValidateManualSource
            ValidateCommandDocs
            ValidateOptionDocs
            ValidateDependencyDocs
            ValidateParameterDocs
            ValidateTaskDocs
            ConsoleInfo "  -->" "done"
            ;;
        cmd)
            ConsoleInfo "  -->" "validating command"
            ValidateCommand
            ConsoleInfo "  -->" "done"
            ;;
        dep)
            ConsoleInfo "  -->" "validating dependency"
            ValidateDependency
            ConsoleInfo "  -->" "done"
            ;;
        opt)
            ConsoleInfo "  -->" "validating option"
            ValidateOption
            ConsoleInfo "  -->" "done"
            ;;
        param)
            ConsoleInfo "  -->" "validating parameter"
            ValidateParameter
            ConsoleInfo "  -->" "done"
            ;;
        task)
            ConsoleInfo "  -->" "validating task"
            ValidateTask
            ConsoleInfo "  -->" "done"
            ;;
        *)
            ConsoleError " ->" "vi - unknown target $TODO"
    esac
    ConsoleDebug "done target - $TODO"
done
CONFIG_MAP["STRICT"]=OLD_STRICT

ConsoleInfo "  -->" "vi: done"
exit $TASK_ERRORS
