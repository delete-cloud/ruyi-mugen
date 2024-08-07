#!/usr/bin/bash

# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##################################################################################
# @Author    :   weilinfox
# @Contact   :   caiweilin@iscas.ac.cn
# @Date      :   2023/11/30
# @License   :   Mulan PSL v2
# @Desc      :   ruyisdk cormark test from https://github.com/ruyisdk/ruyi/issues/10
# ##################################################################################

source "./load_translations.sh"  # load translation function
source "./common/common_lib.sh"

EXECUTE_T=60m

function pre_test() {
    LOG_INFO "$(gettext "Start environmental preparation.")"
    install_ruyi || LOG_ERROR "$(gettext "Install ruyi error")"
    DNF_INSTALL "cmake ninja-build"
    APT_INSTALL "cmake ninja-build"
    PACMAN_INSTALL "cmake ninja"
    EMERGE_INSTALL "dev-build/cmake dev-build/ninja"
    LOG_INFO "$(gettext "End of environmental preparation!")"
}

function run_test() {
    LOG_INFO "$(gettext "Start to run test.")"

    mkdir build && cd build
    tar zxf "../common/source/zlib-ng-2.1.5.tar.gz"

    ruyi update
    ruyi install gnu-plct gnu-plct-xthead

    ruyi venv -t gnu-plct-xthead sipeed-lpi4a ./coremark_venv
    ruyi extract coremark
    . coremark_venv/bin/ruyi-activate
    # why we need this
    sed -i 's/\bgcc\b/riscv64-plctxthead-linux-gnu-gcc/g' linux64/core_portme.mak 
    make PORT_DIR=linux64 link
    file coremark.exe | grep -i "RISC-V"
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi coremark build failed")"
    ruyi-deactivate

    tar zxf "../common/source/zlib-ng-2.1.5.tar.gz"
    cd "./zlib-ng-2.1.5"
    ruyi venv -t gnu-plct milkv-duo ./zlib_venv
    . zlib_venv/bin/ruyi-activate
    cmake . -G Ninja -DCMAKE_C_COMPILER=riscv64-plct-linux-gnu-gcc -DCMAKE_INSTALL_PREFIX="$(pwd)/zlib_my_install" -DCMAKE_C_FLAGS="-O2 -pipe -g" -DZLIB_COMPAT=ON -DWITH_GTEST=OFF
    ninja
    ninja install
    ls "$(pwd)/zlib_my_install/include"
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi zlib-ng build failed")"
    ruyi-deactivate
    cd ..

    cd .. && rm -rf build

    LOG_INFO "$(gettext "End of the test.")"
}

function post_test() {
    LOG_INFO "$(gettext "Start environment cleanup.")"
    remove_ruyi
    PKG_REMOVE
    LOG_INFO "$(gettext "Finish environment cleanup!")"
}

main "$@"
