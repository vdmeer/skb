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
## Describe: application description, e.g pre-text for the manual 
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## DescribeApplicationAuthors
## - description application authors
##
DescribeApplicationAuthors() {
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
}



##
## DescribeApplicationBugs
## - description application bugs
##
DescribeApplicationBugs() {
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
}



##
## DescribeApplicationCopying
## - description application copying
##
DescribeApplicationCopying() {
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
}



##
## DescribeApplicationDescription
## - description application
##
DescribeApplicationDescription() {
    case $TARGET in
        adoc)
            printf "\n\n== DESCRIPTION\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/description.adoc
            printf "\n\n"
            ;;
        ansi | text*)
            printf "  "
            PrintEffect bold "DESCRIPTION" $TARGET
            printf "\n"
            cat ${CONFIG_MAP["MANUAL_SRC"]}/application/description.txt
            ;;
    esac
}



##
## DescribeApplicationResources
## - description application resources
##
DescribeApplicationResources() {
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
}



##
## DescribeApplicationSecurity
## - description application security
##
DescribeApplicationSecurity() {
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
}