#!/usr/bin/bash

# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   kina
# @Contact   :   kiakiana0630@gmail.com
# @Date      :   2024/08/07
# @License   :   Mulan PSL v2
# @Desc      :   ruyisdk mugen load translations
# #############################################

function load_translations() {
    local lang=${LANG}
    local script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    local locale_dir="${script_dir}/locales"

    if [[ -f "${locale_dir}/${lang}/messages.mo" ]]; then
        export TEXTDOMAINDIR="${locale_dir}/${lang}"
        export TEXTDOMAIN=messages
    else
        export TEXTDOMAINDIR="${locale_dir}/en_US.UTF-8"
        export TEXTDOMAIN=messages
    fiÍ
}

load_translations
