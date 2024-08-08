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
# @Date      :   2023/11/30
# @License   :   Mulan PSL v2
# @Desc      :   ruyisdk admin test
# #############################################

source "../../i18n/load_translations.sh"  # load translation function
source "./common/common_lib.sh"

function pre_test() {
    LOG_INFO "$(gettext "Start environmental preparation.")"
    install_ruyi || LOG_ERROR "$(gettext "Install ruyi error")"
    LOG_INFO "$(gettext "End of environmental preparation!")"
}

function run_test() {
    LOG_INFO "$(gettext "Start to run test.")"

    test_file=ruyi_test_admin.sh
    ruyi admin manifest $test_file
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi admin manifest failed")"
    ruyi admin manifest --format json $test_file
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi admin manifest json format failed")"
    ruyi admin manifest --format toml $test_file
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi admin manifest toml format failed")"

    LOG_INFO "$(gettext "End of the test.")"
}

function post_test() {
    LOG_INFO "$(gettext "Start environment cleanup.")"
    remove_ruyi
    LOG_INFO "$(gettext "Finish environment cleanup!")"
}

main "$@"
