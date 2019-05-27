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
## make script for the SKB
## - runs the SKB_DASHBOARD with task make-target-sets
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v1.0.0
##

set -o errexit -o pipefail -o noclobber -o nounset
shopt -s globstar



##
## Basic settings
##
export SKB_HOME=$PWD



##
## SKB_DASHBAORD settings (SD)
##
export SD_TARGET=/tmp/sd
export SD_LIBRARY_YAML=${SKB_HOME}/data/library
export SD_LIBRARY_DOCS=${SKB_HOME}/documents/library
export SD_LIBRARY_URL=https://github.com/vdmeer/skb/tree/master/data/library
export SD_ACRONYM_YAML=${SKB_HOME}/data/acronyms
export SD_ACRONYM_DOCS=${SKB_HOME}/documents/acronyms
export SD_MVN_SITES="$PWD/sites/vandermeer $PWD/sites/skb"
export SD_MAKE_TARGET_SETS=$PWD



##
## Check if we know where to find SKB_FRAMEWORK (home dir) and SKB_DASHBOARD (executable)
## - if any settings are missing, exit
##
GO_AHEAD=true
if [[ -z "${SKB_FRAMEWORK_HOME:-}" ]]; then
    printf "Please set SKB_FRAMEWORK_HOME to home directory\n"
    GO_AHEAD=false
fi
if [[ -z "${SKB_DASHBOARD:-}" ]]; then
    printf "Please set SKB_DASHBOARD to executable\n"
    GO_AHEAD=false
fi
if [[ ${GO_AHEAD} == false ]]; then
    exit 1
fi



##
## Check if we have some command line
## - if not, we need help, and then exit
## - if there's any indication for help, print help
##
if [[ -z "${1:-}" || "${1}" == "-h" || "${1}" == "--help" || "${1}" == "help" ]]; then
    if [[ -z "${1:-}" ]]; then
        printf "No target given\n"
    fi
    source skb-ts-scripts.skb
    TsRunTask help
    #$SKB_DASHBOARD -B -e make-target-sets --lq --sq --tq -- --id skb --targets help
    #make-target-sets --id skb --targets help
    exit 1
fi



##
## Everything looks ok, run SD and call 'make-target-sets' for our target set 'skb'
##
$SKB_DASHBOARD -B -e make-target-sets --snp --task-level debug -- --id skb --targets $1



##
## Finished, should all be build now
## - sites/skb/target/site                      - for the plain SKB site
## - sites/skb/target/site-skb                  - for the staged SKB site
## - sites/vandermeer/target/site               - for the plain SKB site
## - sites/vandermeer/target/site-vandermeer    - for the staged SKB site
## - /tmp/sd                                    - created and compiled acronym/library artifacts
##
