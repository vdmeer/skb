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

export SD_MAKE_TARGET_SETS=$PWD


if [[ -z "${SKB_FRAMEWORK_HOME:-}" ]]; then
    printf "\n\nPlease set SKB_FRAMEWORK_HOME\n\n"
    GO_AHEAD=false
fi
if [[ -z "${SKB_DASHBOARD:-}" ]]; then
    printf "\n\nPlease set SKB_DASHBOARD\n\n"
    GO_AHEAD=false
fi

$SKB_DASHBOARD -B -e make-target-sets --snp --task-level debug -- --all -t $1
