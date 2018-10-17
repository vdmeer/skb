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
## FW Shell
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
CONFIG_MAP["RUNNING_IN"]="shell"



##
## load main functions
## - reset errors and warnings
##
source $FW_HOME/bin/loader/declare/config.sh
source $FW_HOME/bin/loader/init/process-settings.sh
source $FW_HOME/bin/shell/commands/_include
source $FW_HOME/bin/functions/_include
source $FW_HOME/bin/functions/describe/task.sh

ConsoleResetErrors
ConsoleResetWarnings
ConsoleMessage "\n"



##
## initialize variables
##
TASK=                           # a task ID from input
SCMD=                           # a shell-command from input
SARG=                           # argument(s), if any, for a shell command
STIME=                          # time a command was entered
declare -A HISTORY              # the shell's history of executed commands
HISTORY[-1]="help"              # dummy first entry, size calcuation doesn't seem to work otherwise


##
## function: FWInterpreter
## - takes a command and runs it
##
FWInterpreter() {
    case "$SCMD" in
        list-scenarios | "list-scenarios "* | ls | "ls "*)
            ShellCmdListScenarios
            ShellAddCmdHistory
            ;;

        execute-scenario | es)
            printf "\n    execute-scenario/rs requires a scenario as argument\n\n"
            ;;
        "execute-scenario "*)
            SARG=${SCMD#*execute-scenario }
            ShellCmdExecuteScenario
            ShellAddCmdHistory
            ;;
        "es "*)
            SARG=${SCMD#*es }
            ShellCmdExecuteScenario
            ShellAddCmdHistory
            ;;

        shell-level | sl)
            printf "\n    shell-level/sl requires a new level as argument\n\n"
            ;;
        "shell-level "*)
            SARG=${SCMD#*shell-level }
            ShellCmdShellLevel
            ShellAddCmdHistory
            ;;
        "sl "*)
            SARG=${SCMD#*sl }
            ShellCmdShellLevel
            ShellAddCmdHistory
            ;;

        task-level | tl)
            printf "\n    task-level/tl requires a new level as argument\n\n"
            ;;
        "task-level "*)
            SARG=${SCMD#*task-level }
            ShellCmdTaskLevel
            ShellAddCmdHistory
            ;;
        "tl "*)
            SARG=${SCMD#*tl }
            ShellCmdTaskLevel
            ShellAddCmdHistory
            ;;

        clear-screen | "clear-screen "* | cls | "cls "*)
            printf "\033c"
            ShellAddCmdHistory
            ;;

        print-mode | p)
            printf "\n    print-mode/p requires a new mode as argument\n\n"
            ;;
        "print-mode "*)
            SARG=${SCMD#*print-mode }
            ShellCmdPrintMode
            ShellAddCmdHistory
            ;;
        "p "*)
            SARG=${SCMD#*p }
            ShellCmdPrintMode
            ShellAddCmdHistory
            ;;


        strict | "strict "*)
            ShellCmdStrict
            ShellAddCmdHistory
            ;;

        time | "time "* | t | "t "*)
            printf "\n    %s\n\n" "$STIME"
            ShellAddCmdHistory
            ;;

        "" | "#" | "#"* | "# "*)
            ;;
        *)
            SARG="$SCMD"
            ShellCmdExecuteTask
            ShellAddCmdHistory
            ;;
    esac
}



##
## function: FWShell
## - the main shell, takes input from STDIN and runs the commands
## - uses FWInterpreter for some commands
##
FWShell() {
    while read -a args; do
        SCMD="${args[@]:-}" <&3
        STIME=$(date +"%T")
        case "$SCMD" in
            help | h | "?")
                cat ${CONFIG_MAP["FW_HOME"]}/etc/command-help.${CONFIG_MAP["PRINT_MODE"]}
                ;;
            !*)
                SARG=${SCMD#*!}
                ShellCmdHistory
                ;;
            history*)
                SARG=${SCMD#*history}
                ShellCmdHistory
                ;;
            exit | quit | q | bye)
                break
                ;;
            *)
                FWInterpreter
                ;;
        esac
        ConsoleMessage "${CONFIG_MAP["SHELL_PROMPT"]}"
    done
}



##
## call the shell
## - redirect input to #3 while running the shell
##
exec 3</dev/tty || exec 3<&0
ConsoleMessage "${CONFIG_MAP["SHELL_PROMPT"]}"
FWShell
exec 3<&-
