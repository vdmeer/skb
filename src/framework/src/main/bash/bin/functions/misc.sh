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
## Functions: misc
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## function: PathToCygwin
## - converts a path to Cygwin
## $1: path to convert
## return: converted path, original if not on a cygwin OS
## use: VARIABLE=$(PathToCygwin "path")
##
PathToCygwin() {
    if [[ ${CONFIG_MAP["SYSTEM"]} == "CYGWIN" ]]; then
        echo "`cygpath -m $1`"
    else
        echo $1
    fi
}



##
## function Trim
## - trims a string, removes leading and trailing white spaces
## https://web.archive.org/web/20121022051228/http://codesnippets.joyent.com/posts/show/1816
##
# Trim() {
#     local var=$1
#     var="${var#"${var%%[![:space:]]*}"}"
#     var="${var%"${var##*[![:space:]]}"}"
#     echo $var
# }

