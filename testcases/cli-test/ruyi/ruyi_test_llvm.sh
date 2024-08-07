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
# @Date      :   2023/12/04
# @License   :   Mulan PSL v2
# @Desc      :   ruyisdk simple llvm test
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

    mkdir llvm_test
    cd llvm_test

    qemu_pkg=qemu-user-riscv-upstream
    qemu_cmd="-e qemu-user-riscv-upstream"
    qemu_bin=ruyi-qemu
    [ "$(uname -m)" == "riscv64" ] && qemu_pkg= && qemu_cmd= && qemu_bin=

    ruyi update

    pe=$(ruyi list | awk '/\* / {if (f==1) f=2} /./ {if (f==1) {print $0}} /\* toolchain\/llvm-upstream/ {if (f==0) f=1}' | grep -e "^  -" | grep -v "no binary for current host")
    if [ -z "$pe" ]; then
        LOG_INFO "$(gettext "No llvm-upstream available for current host $(uname -m), skip")"
        exit 0
    fi

    if [ ! -z "$qemu_pkg" ]; then
    pe=$(ruyi list | awk '/\* / {if (f==1) f=2} /./ {if (f==1) {print $0}} /\* emulator\/qemu-user-riscv-upstream/ {if (f==0) f=1}' | grep -e "^  -" | grep -v "no binary for current host")
    if [ -z "$pe" ]; then
        LOG_INFO "$(gettext "No qemu-user-riscv-upstream available for current host $(uname -m), skip")"
        exit 0
    fi
    fi

    ruyi install llvm-upstream gnu-upstream $qemu_pkg
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi toolchain install failed")"
    ruyi venv -t llvm-upstream --sysroot-from gnu-upstream $qemu_cmd generic llvm-venv-gnu-upstream
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi venv creation for llvm-upstream with gnu-upstream failed")"

    . llvm-venv-gnu-upstream/bin/ruyi-activate

    cat > hello_ruyi.c << EOF
#include <stdio.h>

int main()
{
    printf("hello, ruyi");

    return 0;
}
EOF

    clang -O3 hello_ruyi.c -o hello_ruyi.o
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi llvm compilation failed")"
    $qemu_bin ./hello_ruyi.o | grep "hello, ruyi"
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi binary failed")"

    ruyi-deactivate

    ruyi install llvm-upstream gnu-plct $qemu_pkg
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi toolchain install failed")"
    ruyi venv -t llvm-upstream --sysroot-from gnu-plct $qemu_cmd generic llvm-venv-gnu-plct
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi venv creation for llvm-upstream with gnu-plct failed")"

    . llvm-venv-gnu-plct/bin/ruyi-activate

    clang -O3 hello_ruyi.c -o hello_ruyi.o
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi llvm compilation failed")"
    $qemu_bin ./hello_ruyi.o | grep "hello, ruyi"
    CHECK_RESULT $? 0 0 "$(gettext "Check ruyi binary failed")"

    ruyi-deactivate

    cd ..
    rm -rf llvm_test

    LOG_INFO "$(gettext "End of the test.")"
}

function post_test() {
    LOG_INFO "$(gettext "Start environment cleanup.")"
    remove_ruyi
    LOG_INFO "$(gettext "Finish environment cleanup!")"
}

main "$@"
