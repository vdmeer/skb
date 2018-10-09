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
## Loader Initialisation: declare arrays and maps
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


declare -A CONFIG_MAP               # map/export for main configuration, keys are less FLAVOR
declare -A CONFIG_SRC               # map/export for configuration source, i.e. where a setting comes from: [E]nv, [F]ile (.skb), [D]efault, CLI [O]ption

declare -a DIRECTORIES              # array/internal as read-only directories (used for testing parameters)
declare -a DIRECTORIES_CD           # array/internal as create/delete directories (used for testing parameters)

declare -a FILES                    # array/internal files (used for testing parameters)
