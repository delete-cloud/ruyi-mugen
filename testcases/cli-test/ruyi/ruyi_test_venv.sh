#!/usr/bin/bash

# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   weilinfox
# @Contact   :   caiweilin@iscas.ac.cn
# @Date      :   2023/11/28
# @License   :   Mulan PSL v2
# @Desc      :   ruyisdk venv test
# #############################################

source "./load_translations.sh"  # load translation function
source "./common/common_lib.sh"

function pre_test() {
    LOG_INFO "$(gettext "Start environmental preparation.")"
    install_ruyi || LOG_ERROR "$(gettext "Install ruyi error")"
    LOG_INFO "$(gettext "End of environmental preparation!")"
}

function run_test() {
    LOG_INFO "$(gettext "Start to run test.")"

    ruyi update
    ruyi install gnu-plct
    ruyi venv --toolchain gnu-plct milkv-duo test-venv 2>&1 | grep "$(gettext "The virtual environment is now created.")"
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi venv install failed")"
    [ -f ./test-venv/bin/ruyi-activate ]
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi venv activate file failed")"
    oldps1="$PS1"
    source ./test-venv/bin/ruyi-activate
    echo "$PS1" | grep test-venv
    CHECK_RESULT $? 0 0 "$(gettext "Check activate ruyi venv PS1 failed")"
    ruyi-deactivate
    [ "$oldps1" == "$PS1" ]
    CHECK_RESULT $? 0 0 "$(gettext "Check deactivate ruyi venv PS1 failed")"
    rm -rf test-venv

    LOG_INFO "$(gettext "End of the test.")"
}

function post_test() {
    LOG_INFO "$(gettext "Start environment cleanup.")"
    remove_ruyi
    LOG_INFO "$(gettext "Finish environment cleanup!")"
}

main "$@"
