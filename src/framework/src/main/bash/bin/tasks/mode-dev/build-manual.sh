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
## build-manual - builds the manual for different targets
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
DO_CLEAN=false
DO_BUILD=false
DO_TEST=false
DO_ALL=false
DO_PRIMARY=false
DO_SECONDARY=false
TARGET=



##
## set CLI options and parse CLI
##
CLI_OPTIONS=abchpst
CLI_LONG_OPTIONS=build,clean,help,test,all,adoc,html,manp,pdf,text,src

! PARSED=$(getopt --options "$CLI_OPTIONS" --longoptions "$CLI_LONG_OPTIONS" --name bdman -- "$@")
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
            shift
            DO_CLEAN=true
            ;;
        -h | --help)
            printf "\n   options\n"
            BuildTaskHelpLine a all         "<none>"    "set all targets, overwrites other options"         $PRINT_PADDING
            BuildTaskHelpLine b build       "<none>"    "builds a manual (manpage), requires a target"      $PRINT_PADDING
            BuildTaskHelpLine c clean       "<none>"    "removes all target artifacts"                      $PRINT_PADDING
            BuildTaskHelpLine h help        "<none>"    "print help screen and exit"                        $PRINT_PADDING
            BuildTaskHelpLine p primary     "<none>"    "set all primary targets"                           $PRINT_PADDING
            BuildTaskHelpLine s secondary   "<none>"    "set all secondary targets"                         $PRINT_PADDING
            BuildTaskHelpLine t test        "<none>"    "test a manual (show results), requires a target"   $PRINT_PADDING
            printf "\n   targets\n"
            BuildTaskHelpLine "<none>" adoc  "<none>" "secondary target: text versions: ansi, text"     $PRINT_PADDING
            BuildTaskHelpLine "<none>" html  "<none>" "secondary target: HTML file"                     $PRINT_PADDING
            BuildTaskHelpLine "<none>" manp  "<none>" "secondary target: man page file"                 $PRINT_PADDING
            BuildTaskHelpLine "<none>" pdf   "<none>" "secondary target: PDF file)"                     $PRINT_PADDING
            BuildTaskHelpLine "<none>" text  "<none>" "secondary target: text versions: ansi, text"     $PRINT_PADDING
            BuildTaskHelpLine "<none>" src   "<none>" "primary target: text source files from ADOC"     $PRINT_PADDING
            exit 0
            ;;

        -t | --test)
            shift
            DO_TEST=true
            ;;

        -a | --all)
            shift
            DO_ALL=true
            ;;
        -p | --primary)
            shift
            DO_PRIMARY=true
            ;;
        -s | --secondary)
            shift
            DO_SECONDARY=true
            ;;
        --adoc)
            shift
            TARGET=$TARGET" adoc"
            ;;
        --html)
            shift
            TARGET=$TARGET" html"
            ;;
        --manp)
            shift
            TARGET=$TARGET" manp"
            ;;
        --pdf)
            shift
            TARGET=$TARGET" pdf"
            ;;
        --text)
            shift
            TARGET=$TARGET" text"
            ;;
        --src)
            shift
            TARGET=$TARGET" src"
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


if [[ $DO_PRIMARY == true ]]; then
    TARGET="src"
fi
if [[ $DO_SECONDARY == true ]]; then
    TARGET="adoc text manp html pdf"
fi
if [[ $DO_ALL == true ]]; then
    TARGET="src adoc text manp html pdf"
fi
if [[ $DO_ALL == true ]]; then
    TARGET="src adoc text manp html pdf"
fi
if [[ $DO_BUILD == true || $DO_TEST == true ]]; then
    if [[ ! -n "$TARGET" ]]; then
        ConsoleError " ->" "build/test required, but no target set"
        exit 3
    fi
fi



############################################################################################
##
## ready to go
##
############################################################################################
ConsoleInfo "  -->" "bdman: starting task"



############################################################################################
## validate documentation first, exit in errors
############################################################################################
STRICT=${CONFIG_MAP["STRICT"]}
CONFIG_MAP["STRICT"]=yes
ConsoleResetErrors

set +e
${DMAP_TASK_EXEC["validate-installation"]} -s --man-src
__errno=$?
set -e

if (( $__errno > 0 )); then
    ConsoleError " ->" "bdman: found documentation errors, cannot continue"
    ConsoleInfo "  -->" "bdman: done"
    exit 4
fi
CONFIG_MAP["STRICT"]=$STRICT



############################################################################################
## core build function
############################################################################################
##
## function: BuildManualCore()
## - builds the core of the manual for ADOC, ANSI-TEXT, and TEXT
## $1: target to build: adoc, ansi, text
##
BuildManualCore() {
    local TARGET=$1

    local i
    local keys
    local SOURCE
    local OPTION
    local PARAM
    local DEP
    local TASK

    case $TARGET in
        adoc)
            printf "= %s(1)\n" "${CONFIG_MAP["APP_SCRIPT"]}"
            printf "Sven van der Meer\n"
            printf ":doctype: manpage\n"
            printf ":man manual: SKB Builder Manual\n"
            printf ":man source: SKB Builder %s\n" "${CONFIG_MAP["VERSION"]}"
            printf ":page-layout: base\n"
#             printf ":toc: left\n"
            printf ":toclevels: 4\n\n"
            printf "== NAME\n"
            ;;
        ansi)
            printf "\n  "
            PrintEffect bold "NAME" $TARGET
            printf "\n  "
            ;;
        text*)
            printf "\n  "
            PrintEffect bold "NAME" text-anon
            printf "\n  "
            ;;
    esac
    printf "%s - " "${CONFIG_MAP["APP_SCRIPT"]}"
    cat ${CONFIG_MAP["MANUAL_SRC"]}/tags/name.txt
    printf "\n\n"

    case $TARGET in
        adoc)
            printf "== SYNOPSIS\n\n"
            PrintEffect bold "${CONFIG_MAP["APP_SCRIPT"]}" $TARGET
            printf " "
            PrintEffect italic "OPTIONS" $TARGET
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "SYNOPSIS" $TARGET
            printf "\n\n    "
            PrintEffect bold "${CONFIG_MAP["APP_SCRIPT"]}" $TARGET
            printf " "
            PrintEffect italic "OPTIONS" $TARGET
            printf "\n"
            ;;
    esac
    printf "    - will process the options\n"

    case $TARGET in
        adoc)
            printf "\n"
            PrintEffect bold "${CONFIG_MAP["APP_SCRIPT"]}" $TARGET
            printf "\n\n"
            ;;
        ansi | text*)
            printf "\n    "
            PrintEffect bold "${CONFIG_MAP["APP_SCRIPT"]}" $TARGET
            printf "\n"
            ;;
    esac

    printf "    - will start the interactive shell\n"
    printf "    - type 'h' or 'help' in the shell for commands\n"
    printf "\n"

    case $TARGET in
        adoc)
            printf "== DESCRIPTION\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "DESCRIPTION" $TARGET
            printf "\n  "
            ;;
    esac

    printf "The %s(1) " "${CONFIG_MAP["APP_SCRIPT"]}"
    cat ${CONFIG_MAP["MANUAL_SRC"]}/tags/description.txt

    DescribeElementOptions

    DescribeElementOptionsRuntime
    set +e
    ${DMAP_TASK_EXEC["describe-option"]} --run --print-mode $TARGET
    set -e


    DescribeElementOptionsExit
    set +e
    ${DMAP_TASK_EXEC["describe-option"]} --exit --print-mode $TARGET
    set -e


    DescribeElementParameters
    set +e
    ${DMAP_TASK_EXEC["describe-parameter"]} --all --print-mode $TARGET
    set -e


    DescribeElementTasks
    set +e
    ${DMAP_TASK_EXEC["describe-task"]} --all --print-mode $TARGET
    set -e


    DescribeElementDependencies
    set +e
    ${DMAP_TASK_EXEC["describe-dependency"]} --all --print-mode $TARGET
    set -e


    DescribeElementDependencies
    set +e
    ${DMAP_TASK_EXEC["describe-command"]} --all --print-mode $TARGET
    set -e


    DescribeElementExitStatus


    case $TARGET in
        adoc)
            printf "\n\n== SECURITY CONCERNS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/security.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "SECURITY CONCERNS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/security.txt
            ;;
    esac


    case $TARGET in
        adoc)
            printf "\n\n== BUGS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/bugs.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "BUGS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/bugs.txt
            ;;
    esac


    case $TARGET in
        adoc)
            printf "\n\n== AUTHORS\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/authors.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "AUTHORS" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/authors.txt
            ;;
    esac


    case $TARGET in
        adoc)
            printf "\n\n== RESOURCES\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/resources.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "RESOURCES" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/resources.txt
            ;;
    esac


    case $TARGET in
        adoc)
            printf "\n\n== COPYING\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/copying.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "COPYING" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/copying.txt
            ;;
    esac

    printf "\n"
}



############################################################################################
##
## functions for SRC build (no test)
##
############################################################################################
BuildSrcPath() {
    local ADOC_PATH=$1
    local LEVEL=$2
    local JAR=${CONFIG_MAP["SKB_FW_TOOL"]}
    local FILE
    local TARGET

    for FILE in $(cd $ADOC_PATH; find -type f | grep "\.adoc"); do
        TARGET=${FILE%.*}
        (cd $ADOC_PATH; rm $TARGET.txt)
        (cd $ADOC_PATH; java -jar `PathToCygwin $JAR` `PathToCygwin $FILE` $LEVEL > $TARGET.txt)
        ConsoleTrace "  wrote file $TARGET.txt"
    done
}

BuildSrc() {
    ConsoleInfo "  -->" "build src"
    if [[ -z ${CONFIG_MAP["SKB_FW_TOOL"]:-} ]]; then
        ConsoleError " ->" "src: no setting for SKB_FW_TOOL found, cannot build"
        return
    fi
    if [[ ! -z ${RTMAP_TASK_TESTED["jre8"]:-} ]]; then
        ConsoleDebug "build src - manual"
        BuildSrcPath ${CONFIG_MAP["MANUAL_SRC"]} l1

        ConsoleDebug "build src - commands"
        BuildSrcPath ${CONFIG_MAP["FW_HOME"]}/${FW_PATH_MAP["COMMANDS"]} l2
#         ConsoleDebug "build src - error codes"
#         BuildSrcPath ${CONFIG_MAP["FW_HOME"]}/${FW_PATH_MAP["EXITCODES"]} l2
        ConsoleDebug "build src - options"
        BuildSrcPath ${CONFIG_MAP["FW_HOME"]}/${FW_PATH_MAP["OPTIONS"]} l2

        ConsoleDebug "build src - dependencies"
        BuildSrcPath ${CONFIG_MAP["HOME"]}/${APP_PATH_MAP["DEP_DECL"]} l2
        ConsoleDebug "build src - parameters"
        BuildSrcPath ${CONFIG_MAP["HOME"]}/${APP_PATH_MAP["PARAM_DECL"]} l2
        ConsoleDebug "build src - tasks"
        BuildSrcPath ${CONFIG_MAP["HOME"]}/${APP_PATH_MAP["TASK_DECL"]} l2

    else
        ConsoleError " ->" "src: dependency 'jre8' not loaded, could not build"
    fi
    ConsoleInfo "  -->" "done: build src"
}



############################################################################################
##
## set variables for files
##
############################################################################################
MAN_PAGE_DIR=${CONFIG_MAP["HOME"]}/man/man1
MAN_PAGE_FILE=$MAN_PAGE_DIR/${CONFIG_MAP["APP_SCRIPT"]}.1

MAN_DOC_DIR=${CONFIG_MAP["HOME"]}/doc/manual
MAN_ADOC_FILE=$MAN_DOC_DIR/${CONFIG_MAP["APP_SCRIPT"]}.adoc
MAN_HTML_FILE=$MAN_DOC_DIR/${CONFIG_MAP["APP_SCRIPT"]}.html
MAN_PDF_FILE=$MAN_DOC_DIR/${CONFIG_MAP["APP_SCRIPT"]}.pdf



############################################################################################
##
## functions for TEXT build/test
##
############################################################################################
BuildText() {
    local target
    local targets=${1:-}
    if [[ ! -n "$targets" ]]; then
        targets="adoc ansi text text-anon"
    fi
    local file

    ConsoleDebug "build target text"
    for target in $targets; do
        ConsoleDebug "building: $target"
        file=$MAN_DOC_DIR/${CONFIG_MAP["APP_SCRIPT"]}.$target
        if [[ -f $file ]]; then
            rm $file
        fi
        ConsoleTrace "  for $target"
        BuildManualCore $target 1> $file
    done
    ConsoleDebug "done"
}

TestText() {
    local targets=${1:-}
    if [[ ! -n "$targets" ]]; then
        targets="adoc ansi text text-anon"
    fi
    local found=true
    for target in $targets; do
        file=$MAN_DOC_DIR/${CONFIG_MAP["APP_SCRIPT"]}.$target
        if [[ ! -f $file ]]; then
            found=false
        fi
    done
    if ! $found; then BuildText; fi

    for target in $targets; do
        file=$MAN_DOC_DIR/${CONFIG_MAP["APP_SCRIPT"]}.$target
        tput smcup
        clear
        less -r -C -f -M -d $file
        tput rmcup
    done
}



############################################################################################
##
## functions for HTML build/test
##
############################################################################################
BuildHtml() {
    ConsoleDebug "build html"
    if [[ ! -f $MAN_ADOC_FILE ]]; then
        BuildText adoc
    fi
    if [[ ! -z ${RTMAP_TASK_TESTED["asciidoctor"]:-} ]]; then
        if [[ -f $MAN_HTML_FILE ]]; then
            rm $MAN_HTML_FILE
        fi
        if [[ -f $MAN_ADOC_FILE ]]; then
            asciidoctor $MAN_ADOC_FILE --backend html -a toc=left
        else
            ConsoleError " ->" "html: problem building ADOC"
        fi
    else
        ConsoleError " ->" "html: dependency 'asciidoctor' not loaded, could not build"
    fi
    ConsoleDebug "done: build html"
}

TestHtml() {
    if [[ ! -f $MAN_HTML_FILE ]]; then
        BuildHtml
    fi
    if [[ -f $MAN_HTML_FILE ]]; then
        if [[ ! -z "${RTMAP_TASK_LOADED["start-browser"]}" ]]; then
            set +e
            ${DMAP_TASK_EXEC["start-browser"]} --url file://$(PathToCygwin $MAN_HTML_FILE)
            set -e
        else
            ConsoleError " ->" "html: cannot test, task 'start-browser' not loaded"
        fi
    else
        ConsoleError " ->" "problem building HTML"
    fi
}



############################################################################################
##
## functions for MANP build/test
##
############################################################################################
BuildManp() {
    ConsoleDebug "build manp"
    if [[ ! -f $MAN_ADOC_FILE ]]; then
        BuildText adoc
    fi
    if [[ ! -z ${RTMAP_TASK_TESTED["asciidoctor"]:-} ]]; then
        if [[ -f $MAN_PAGE_FILE ]]; then
            rm $MAN_PAGE_FILE
        fi
        if [[ -f $MAN_ADOC_FILE ]]; then
            asciidoctor $MAN_ADOC_FILE --backend manpage --destination-dir $MAN_PAGE_DIR
        else
            ConsoleError " ->" "manp: problem building ADOC"
        fi
    else
        ConsoleError " ->" "manp: dependency 'asciidoctor' not loaded, could not build"
    fi
    ConsoleDebug "done: build manp"
}

TestManp() {
    if [[ ! -f $MAN_PAGE_FILE ]]; then
        BuildManp
    fi
    if [[ -f $MAN_PAGE_FILE ]]; then
        man -M $MAN_PAGE_DIR/.. ${CONFIG_MAP["APP_SCRIPT"]}
    else
        ConsoleError " ->" "problem building MANP"
    fi
}



############################################################################################
##
## functions for PDF build/test
##
############################################################################################
BuildPdf() {
    ConsoleDebug "build pdf"
    if [[ ! -f $MAN_ADOC_FILE ]]; then
        BuildText adoc
    fi
    if [[ ! -z ${RTMAP_TASK_TESTED["asciidoctor-pdf"]:-} ]]; then
        if [[ -f $MAN_PDF_FILE ]]; then
            rm $MAN_PDF_FILE
        fi
        if [[ -f $MAN_ADOC_FILE ]]; then
            asciidoctor-pdf $MAN_ADOC_FILE
        else
            ConsoleError " ->" "pdf: problem building ADOC"
        fi
    else
        ConsoleError " ->" "pdf: dependency 'asciidoctor' not loaded, could not build"
    fi
    ConsoleDebug "done: build pdf"
}

TestPdf() {
    if [[ ! -f $MAN_PDF_FILE ]]; then
        BuildPdf
    fi
    if [[ -f $MAN_PDF_FILE ]]; then
        if [[ ! -z "${RTMAP_TASK_LOADED["start-pdf"]}" ]]; then
            set +e
            ${DMAP_TASK_EXEC["start-pdf"]} --file $MAN_PDF_FILE
            set -e
        else
            ConsoleError " ->" "pdf: cannot test, task 'start-pdf' not loaded"
        fi
    else
        ConsoleError " ->" "problem building PDF"
    fi
}



############################################################################################
##
## Now the actual business logic of the task
##
############################################################################################
if [[ $DO_CLEAN == true ]]; then
    ConsoleInfo "  -->" "clean all targets"

    ConsoleDebug "scanning $MAN_PAGE_DIR"
    files=$(find -P $MAN_PAGE_DIR -type f)
    if [[ -n "$files" ]]; then
        for file in $files; do
            rm $file
            ConsoleTrace "  removed file $file"
        done
    fi

    ConsoleDebug "scanning $MAN_DOC_DIR"
    files=$(find -P $MAN_DOC_DIR -type f)
    if [[ -n "$files" ]]; then
        for file in $files; do
            rm $file
            ConsoleTrace "  removed file $file"
        done
    fi

    ConsoleInfo "  -->" "done clean"
fi

if [[ $DO_BUILD == true ]]; then
    case "$TARGET" in
        *src*)  BuildSrc ;;
    esac

    ConsoleInfo "  -->" "build for target(s): $TARGET"
    for TODO in $TARGET; do
        case $TODO in
            adoc)   BuildText "adoc" ;;
            html)   BuildHtml ;;
            manp)   BuildManp ;;
            pdf)    BuildPdf ;;
            text)   BuildText "ansi text text-anon" ;;
            src)    ;;
            *)      ConsoleError " ->" "build, unknown target '$TODO'"
        esac
    done
    ConsoleInfo "  -->" "done build"
fi

if [[ $DO_TEST == true ]]; then
    ConsoleInfo "  -->" "test for target(s): $TARGET"
    for TODO in $TARGET; do
        case $TODO in
            adoc)   TestText "adoc" ;;
            html)   TestHtml ;;
            manp)   TestManp ;;
            pdf)    TestPdf ;;
            text)   TestText "ansi text text-anon" ;;
            src)    ;;
            *)      ConsoleError " ->" "build, unknown target '$TODO'"
        esac
    done
    ConsoleInfo "  -->" "done test"
fi

ConsoleInfo "  -->" "bdman: done"
exit $TASK_ERRORS
