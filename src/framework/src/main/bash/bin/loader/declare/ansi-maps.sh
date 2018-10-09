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
## Declare: maps with ANSI codes for colors and effects for screen printing
##
## @author     Sven van der Meer <vdmeer.sven@mykolab.com>
## @version    v0.0.0
##


##
## DO NOT CHANGE CODE BELOW, unless you know what you are doing
##


##
## - bash print settings, e.g colors and effects
## - https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_codes
## - see http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
## - see https://stackoverflow.com/questions/4332478/read-the-current-text-color-in-a-xterm/4332530#4332530
## - see https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux#5947802
## - see https://stackoverflow.com/questions/4414297/unix-bash-script-to-embolden-underline-italicize-specific-text
##

declare -A COLORS
COLORS["BLACK"]='\033[0;30m'
COLORS["RED"]='\033[0;31m'
COLORS["GREEN"]='\033[0;32m'
COLORS["BROWN"]='\033[0;33m'
COLORS["BLUE"]='\033[0;34m'
COLORS["PURPLE"]='\033[0;35m'
COLORS["CYAN"]='\033[0;36m'
COLORS["LIGHT_GRAY"]='\033[0;37m'

COLORS["DARK_GRAY"]='\033[1;30m'
COLORS["LIGHT_RED"]='\033[1;31m'
COLORS["LIGHT_GREEN"]='\033[1;32m'
COLORS["YELLOW"]='\033[1;33m'
COLORS["LIGHT_BLUE"]='\033[1;34m'
COLORS["LIGHT_PURPLE"]='\033[1;35m'
COLORS["LIGHT_CYAN"]='\033[1;36m'
COLORS["WHITE"]='\033[1;37m'

COLORS["NORMAL"]='\033[22m'


declare -A EFFECTS

EFFECTS["INT_BOLD"]='\033[1m'
EFFECTS["INT_FAINT"]='\033[2m'
EFFECTS["INT_NORMAL"]='\033[22m'

EFFECTS["ITALIC_ON"]='\033[3m'
EFFECTS["FRAKTUR_ON"]='\033[20m'
EFFECTS["ITALIC_OFF"]='\033[23m'

EFFECTS["UNDERLINE_ON"]='\033[4m'
EFFECTS["UNDERLINE_OFF"]='\033[24m'

EFFECTS["REVERSE_ON"]='\033[7m'
EFFECTS["REVERSE_OFF"]='\033[27m'

EFFECTS["BLINK_SLOW"]='\033[5m'
EFFECTS["BLINK_FAST"]='\033[6m'
EFFECTS["BLINK_OFF"]='\033[25m'

EFFECTS["NORMAL"]='\033[22m\033[27m'
