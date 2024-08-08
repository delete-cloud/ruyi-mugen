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
# @Desc      :   ruyisdk news test
# #############################################

source "../../i18n//load_translations.sh"  # load translation function
source "./common/common_lib.sh"

function pre_test() {
    LOG_INFO "$(gettext "Start environmental preparation.")"
    install_ruyi || LOG_ERROR "$(gettext "Install ruyi error")"
    LOG_INFO "$(gettext "End of environmental preparation!")"
}

function run_test() {
    LOG_INFO "$(gettext "Start to run test.")"

    ruyi update
    ruyi news read | grep "#"
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi news read failed")"
    ruyi news read | grep "$(gettext "No news to display.")"
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi news read empty failed")"
    ruyi news read 1 | grep "#"
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi news read 1 failed")"
    ruyi news list | grep "$(gettext "News items")"
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi news list failed")"

    LOG_INFO "$(gettext "End of the test.")"
}

function post_test() {
    LOG_INFO "$(gettext "Start environment cleanup.")"
    remove_ruyi
    LOG_INFO "$(gettext "Finish environment cleanup!")"
}

main "$@"
