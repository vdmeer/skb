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
## Declare: character map
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


declare -A CHAR_MAP         # map/export characters
    CHAR_MAP["AVAILABLE"]="✔"       # char something available
    CHAR_MAP["NOT_AVAILABLE"]="✘"   # char something not available
    CHAR_MAP["DIAMOND"]="◆"         # char diamond
    CHAR_MAP["LEGEND"]="■"           # char legend
    CHAR_MAP["TOP_LINE"]="═"         # table top line
    CHAR_MAP["MID_LINE"]="─"         # table mid line
    CHAR_MAP["BOTTOM_LINE"]="═"      # table bottom line

