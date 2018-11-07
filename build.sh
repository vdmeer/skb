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
## - builds library and sites for distribution
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##

set -o errexit -o pipefail -o noclobber -o nounset
shopt -s globstar


SKB_HOME=$PWD
export SD_TARGET=/tmp/sd

export SD_LIBRARY_YAML=${SKB_HOME}/data/library
export SD_LIBRARY_DOCS=${SKB_HOME}/documents/library
export SD_LIBRARY_URL=https://github.com/vdmeer/skb/tree/master/data/library

export SD_MVN_SITES="$PWD/sites/vandermeer $PWD/sites/skb"


##
## also required:
## - SKB_FRAMEWORK_HOME
## - SKB_DASHBOARD
##


TS=$(date +%s.%N)
TIME_START=$(date +"%T")
export SF_MVN_SITES=$PWD



if [[ -d docs/library ]]; then
    set +e
    rm docs/library/*
    set -e
fi
if [[ -d docs ]]; then
    set +e
    rm docs/*.html docs/*.txt
    rm -fr docs/css
    rm -fr docs/fonts
    rm -fr docs/images
    rm -fr docs/img
    rm -fr docs/js
    set -e
fi
$SKB_DASHBOARD -B -e clean --sq --lq --task-level debug -- --force

$SKB_DASHBOARD -B -e lib-yaml2src    --sq --lq --task-level debug    -- --all
$SKB_DASHBOARD -B -e lib-adoc2target --sq --lq --task-level debug --    --all
cp /tmp/sd/library-docs/* docs/library


cp sites/skb/src/site/xdoc/library.xml           sites/vandermeer/src/site/xdoc
cp sites/skb/src/site/xdoc/research-notes.xml    sites/vandermeer/src/site/xdoc
$SKB_DASHBOARD -B -e skb-build-sites --sq --lq --task-level debug -- --clean --build --all --ad --site --stage
cp -dfrpi sites/skb/target/site-skb/* docs
(cd docs; chmod 644 `find -type f`)



TE=$(date +%s.%N)
TIME=$(date +"%T")
RUNTIME=$(echo "($TE-$TS)/60" | bc -l)
printf "started:  $TIME_START\n"
printf "finished: $TIME, in $RUNTIME minutes\n\n"

