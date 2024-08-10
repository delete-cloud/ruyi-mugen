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
# @Date      :   2024/08/10
# @License   :   Mulan PSL v2
# @Desc      :   ruyisdk wps i18n test
# #############################################

source "./common/common_lib.sh"

WPS_DEB_URL="https://mirrors.163.com/ubuntukylin/pool/partner/wps-office_11.1.0.11720_amd64.deb"
CACHE_DIR="${HOME}/.cache/ruyi/distfiles"
WPS_DEB_PATH="${CACHE_DIR}/$(basename "$WPS_DEB_URL")"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    install_ruyi || LOG_ERROR "Install ruyi error"

    # Create necessary directories if they don't exist
    mkdir -p "$CACHE_DIR"

    # Download WPS Office .deb file
    if [ ! -f "$WPS_DEB_PATH" ]; then
        LOG_INFO "Downloading WPS Office .deb file..."
        wget -O "$WPS_DEB_PATH" "$WPS_DEB_URL" || {
            LOG_ERROR "Failed to download WPS Office .deb file."
            exit 1
        }
    else
        LOG_INFO "WPS Office .deb file already exists, skipping download."
    fi

    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."

    # Test with different locales
    for locale in zh_CN.UTF-8 en_US.UTF-8 en_SG.UTF-8; do
        LOG_INFO "Testing with locale: $locale"
        
        export LC_ALL=$locale
        export LANG=$locale
        export LANGUAGE=$locale

        LOG_INFO "Current locale settings: LC_ALL=$LC_ALL, LANG=$LANG, LANGUAGE=$LANGUAGE"
        
        ruyi update 2>&1 | tee -a "ruyi_update_${locale}.log"
        CHECK_RESULT $? 0 0 "Check ruyi update failed for locale $locale"

        # Install WPS Office using ruyi and redirect output
        ruyi install --host x86_64 wps-office 2>&1 | tee -a "ruyi_install_wps_${locale}.log"
        CHECK_RESULT $? 0 0 "Check ruyi install wps-office failed for locale $locale"
        
        LOG_INFO "Finished testing with locale: $locale"
    done

    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    remove_ruyi
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
