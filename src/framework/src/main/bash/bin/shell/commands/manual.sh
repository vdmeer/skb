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
## Shell: function for shell command - manual
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: ShellCmdManual
## - show manual for a given type
##
ShellCmdManual() {
    case "$SARG" in
        "")
            if [[ -f ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.${CONFIG_MAP["PRINT_MODE"]} ]]; then
                set +e
                tput smcup
                clear
                less -r -C -f -M -d "${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.${CONFIG_MAP["PRINT_MODE"]}"
                tput rmcup
                set -e
            else
                ConsoleError "  ->" "did not find manual file: ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.${CONFIG_MAP["PRINT_MODE"]}"
            fi
            ;;
        ansi | text | adoc)
            if [[ -f ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.$SARG ]]; then
                set +e
                tput smcup
                clear
                less -r -C -f -M -d "${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.$SARG"
                tput rmcup
                set -e
            else
                ConsoleError "  ->" "did not find manual file: ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.$SARG"
            fi
            ;;
        pdf)
            if [[ -f ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.pdf ]]; then
                if [[ ! -z "${RTMAP_TASK_LOADED["start-pdf"]}" ]]; then
                    set +e
                    ${DMAP_TASK_EXEC["start-pdf"]} --file ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.pdf
                    set -e
                else
                    ConsoleError " ->" "pdf: cannot show PDF manual, task 'start-pdf' not loaded"
                fi
            else
                ConsoleError "  ->" "did not find manual file: ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.pdf"
            fi
            ;;
        html)
            if [[ -f ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.html ]]; then
                if [[ ! -z "${RTMAP_TASK_LOADED["start-browser"]}" ]]; then
                    set +e
                    ${DMAP_TASK_EXEC["start-browser"]} --url file://$(PathToCygwin ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.html)
                    set -e
                else
                    ConsoleError " ->" "html: cannot test, task 'start-browser' not loaded"
                fi
            else
                ConsoleError " -->" "did not find manual file: ${CONFIG_MAP["HOME"]}/doc/manual/${CONFIG_MAP["APP_SCRIPT"]}.html"
            fi
            ;;
        man)
            if [[ -f ${CONFIG_MAP["HOME"]}/man/man1/${CONFIG_MAP["APP_SCRIPT"]}.1 ]]; then
                set +e
                man -M ${CONFIG_MAP["HOME"]}/man ${CONFIG_MAP["APP_SCRIPT"]}
                set -e
            else
                ConsoleError " -->" "did not find manual file: ${CONFIG_MAP["HOME"]}/man/man1/${CONFIG_MAP["APP_SCRIPT"]}.1"
            fi
            ;;
        *)
            ConsoleError " ->" "unknown manual type: '$SARG'"
            ;;
    esac
}
