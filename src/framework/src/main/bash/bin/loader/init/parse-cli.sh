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
## Loader Initialisation: parse CLI and set CLI map
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: ParseCli
## -parse command line, use getopt for testing
## - uses getopt, see https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/29754866#29754866
## - $@: the CLI options
##
ParseCli() {
    ConsoleInfo "-->" "parse-cli"
    ConsoleResetErrors

    local CLI_OPTIONS=cd:e:hL:M:mo:p:P:r:sS:T:vV

    local CLI_LONG_OPTIONS=loader-level:,shell-level:,task-level:
    CLI_LONG_OPTIONS+=,manual,mode:,run-scenario:,settings,version,validate,help
    CLI_LONG_OPTIONS+=,option:,parameter:,dependency:
    CLI_LONG_OPTIONS+=,strict
    CLI_LONG_OPTIONS+=,print-mode:,clean-cache,execute-task:

    ConsoleDebug "running getopt"
    local PARSED
    ! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name skb -- "$@")
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        ConsoleError " ->" "unknown CLI options"
        return
    fi

    ConsoleDebug "getopt passed"
    eval set -- "$PARSED"
    DO_EXIT=false
    DO_EXIT_2=false
    CLI_EXTRA_ARGS=

    ConsoleDebug "looping through options"
    while true; do
        case "$1" in
            -c | --clean-cache)
                OPT_CLI_MAP["clean-cache"]=true
                shift 1
                ;;
            -d | --dependency)
                OPT_CLI_MAP["dependency"]=$2
                shift 2
                ;;
            -e | --execute-task)
                OPT_CLI_MAP["execute-task"]="$2"
                shift 2
                ;;
            -h | --help)
                OPT_CLI_MAP["help"]=true
                shift 1
                ;;
            -L | --loader-level)
                CONFIG_MAP["LOADER-LEVEL"]="$2"
                CONFIG_SRC["LOADER-LEVEL"]="O"
                shift 2
                ;;
            -M | --mode)
                CONFIG_MAP["APP_MODE"]="$2"
                CONFIG_SRC["APP_MODE"]="O"
                shift 2
                ;;
            -m | --manual)
                OPT_CLI_MAP["manual"]=true
                shift
                ;;
            -o | --option)
                OPT_CLI_MAP["option"]=$2
                shift 2
                ;;
            -P | --print-mode)
                CONFIG_MAP["PRINT_MODE"]="$2"
                CONFIG_SRC["PRINT_MODE"]="O"
                shift 2
                ;;
            -p | --parameter)
                OPT_CLI_MAP["parameter"]=$2
                shift 2
                ;;
            -r | --run-scenario)
                OPT_CLI_MAP["run-scenario"]="$2"
                shift 2
                ;;
            -s | --settings)
                OPT_CLI_MAP["settings"]=true
                shift
                ;;
            -S | --shell-level)
                CONFIG_MAP["SHELL-LEVEL"]="$2"
                CONFIG_SRC["SHELL-LEVEL"]="O"
                shift 2
                ;;
            --strict)
                CONFIG_MAP["STRICT"]="yes"
                CONFIG_SRC["STRICT"]="O"
                shift
                ;;
            -T | --task-level)
                CONFIG_MAP["TASK-LEVEL"]="$2"
                CONFIG_SRC["TASK-LEVEL"]="O"
                shift 2
                ;;
            -V | --validate)
                OPT_CLI_MAP["validate"]=true
                shift
                ;;
            -v | --version)
                OPT_CLI_MAP["version"]=true
                shift
                ;;
            --)
            shift
                if [[ -z ${1:-} ]]; then
                    break
                fi
                CLI_EXTRA_ARGS=$(printf '%s' "$*")
                break
                ;;
            *)
                ConsoleFatal " ->" "internal error: CLI parsing bug"
                exit 1
        esac
    done
    ConsoleInfo "-->" "done"
}

