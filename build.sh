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
## Build script for the SKB
## - builds acronyms, library, and sites
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##

set -o errexit -o pipefail -o noclobber -o nounset
shopt -s globstar

GO_AHEAD=true



SKB_HOME=$PWD
export SD_TARGET=/tmp/sd

export SD_LIBRARY_YAML=${SKB_HOME}/data/library
export SD_LIBRARY_DOCS=${SKB_HOME}/documents/library
export SD_LIBRARY_URL=https://github.com/vdmeer/skb/tree/master/data/library

export SD_ACRONYM_DOCS=${SKB_HOME}/documents/acronyms

export SD_MVN_SITES="$PWD/sites/vandermeer $PWD/sites/skb"



if [[ -z "${SKB_FRAMEWORK_HOME:-}" ]]; then
    printf "\n\nPlease set SKB_FRAMEWORK_HOME\n\n"
    GO_AHEAD=false
fi
if [[ -z "${SKB_DASHBOARD:-}" ]]; then
    printf "\n\nPlease set SKB_DASHBOARD\n\n"
    GO_AHEAD=false
fi



help(){ 
    printf "\nusage: build [targets]\n"
    printf "\n  targets:"
    printf "\n    all            - build all target in the right order"
    printf "\n    clean          - remove all built artifacts (gradle, maven)"
    printf "\n"
    printf "\n    acronyms       - builds the acronyms: generate ADOC files"
    printf "\n    acronyms-docs  - builds the acronyms: compile ADOC Files"
    printf "\n    library        - builds the library: generate ADOC files"
    printf "\n    library-docs   - builds the library: compile ADOC Files"
    printf "\n    sites          - build the Maven sites (maven)"
    printf "\n"
    printf "\n Requirements:"
    printf "\n - SKB Dashboard   - to build artifacts, requires SKB Framework"
    printf "\n - Apache Ant      - to set file versions"
    printf "\n - Apache Maven    - to build the site"
    printf "\n - asciidoctor     - to build HTML from ADOC"
    printf "\n - asciidoctor-pdf - to build PDF from ADOC"
    printf "\n\n Most requirements are not tested, build will simply fail"
    printf "\n\n"
}



if [[ -z "${1:-}" ]]; then
    printf "\n\nNo target given, try '-h' or '--help' for information\n\n"
    GO_AHEAD=false
fi



if [[ ${GO_AHEAD} == false ]]; then
    exit 1
fi



while [[ $# -gt 0 ]]; do
    case "$1" in
        all)
            T_CLEAN=true
            T_ACRONYMS=true
            T_ACRONYMS_DOCS=true
            T_LIBRARY=true
            T_LIBRARY_DOCS=true
            T_SITES=true
            shift
            ;;
        clean)
            T_CLEAN=true
            shift
            ;;
        acronyms)
            T_ACRONYMS=true
            shift
            ;;
        acronyms-docs)
            T_ACRONYMS_DOCS=true
            shift
            ;;
        library)
            T_LIBRARY=true
            shift
            ;;
        library-docs)
            T_LIBRARY_DOCS=true
            shift
            ;;
        sites)
            T_SITES=true
            shift
            ;;
        -h | --help)
            help
            exit 0
            ;;
        *)
            printf "\nunknown target '$1'\n\n"
            help
            exit 2
            ;;
    esac
done



DO_TARGETS=
if [[ ${T_CLEAN:-} == true ]]; then
    DO_TARGETS="${DO_TARGETS} clean"
fi
if [[ ${T_ACRONYMS:-} == true ]]; then
    DO_TARGETS="${DO_TARGETS} acronyms"
fi
if [[ ${T_ACRONYMS_DOCS:-} == true ]]; then
    DO_TARGETS="${DO_TARGETS} acronyms-docs"
fi
if [[ ${T_LIBRARY:-} == true ]]; then
    DO_TARGETS="${DO_TARGETS} library"
fi
if [[ ${T_LIBRARY_DOCS:-} == true ]]; then
    DO_TARGETS="${DO_TARGETS} library-docs"
fi
if [[ ${T_SITES:-} == true ]]; then
    DO_TARGETS="${DO_TARGETS} sites"
fi



##
## function: printProgress
## - prints a message with [BuildSH] tag in color
## - adds extra line for message "done"
## - $1: the info message
##
printProgress(){
    printf "  ["
    printf "\033[1;32mBuildSH\033[1;37m\033[22m"
    printf "] - $1"
    if [[ "$1" == "done" ]]; then
        printf "\n--------------------------------------------------\n\n" 1>&2
    fi
}



TS=$(date +%s.%N)
TIME_START=$(date +"%T")
export SF_MVN_SITES=$PWD

printf "\n\n==================================================\n\n"
printProgress "Building targets:${DO_TARGETS}\n\n==================================================\n"
for TARGET in $DO_TARGETS; do
    printf "\n\n"
    printProgress "start $TARGET\n--------------------------------------------------\n"
    case $TARGET in
        clean)
            mvn clean
            $SKB_DASHBOARD -B -e clean --sq --lq --task-level debug -- --force
            ;;
        acronyms)
            #touch documents/acronyms/*.adoc ## otherwise Asciidoctor might not rebuild
            $SKB_DASHBOARD -B -e acronyms-build  --sq --lq --task-level debug -- --all
            printf "\n\n"
            ;;
        acronyms-docs)
            $SKB_DASHBOARD -B -e acronyms-adoc   --sq --lq --task-level debug -- --all
            printf "\n\n"
            ;;
        library)
            #touch documents/library/*.adoc ## otherwise Asciidoctor might not rebuild
            $SKB_DASHBOARD -B -e library-ext     --sq --lq --task-level debug -- --all
            printf "\n\n"
            ;;
        library-docs)
            $SKB_DASHBOARD -B -e library-adoc    --sq --lq --task-level debug -- --all
            printf "\n\n"
            ;;
        sites)
            $SKB_DASHBOARD -B -e skb-build-sites --sq --lq --task-level debug -- --build --all --ad --site --stage
            printf "\n\n"
            ;;
        *)
            printf "\nunknown target '$TARGET'\nThis is a programming error in the script\n\n"
            exit 2
            ;;
    esac
    printProgress "finished $TARGET\n"
    printProgress "done"
done
printProgress "Finished targets:${DO_TARGETS}\n\n==================================================\n\n"
TE=$(date +%s.%N)

TIME=$(date +"%T")
RUNTIME=$(echo "($TE-$TS)/60" | bc -l)
printProgress "\033[1;32m>>\033[1;37m\033[22m started:  $TIME_START\n"
printProgress "\033[1;32m>>\033[1;37m\033[22m finished: $TIME, in $RUNTIME minutes\n"
printf "\n\n==================================================\n\n"
