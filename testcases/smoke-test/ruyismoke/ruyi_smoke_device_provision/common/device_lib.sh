#!/usr/bin/bash

# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author       :   KotorinMinami
# @Contributor  :   weilinfox
# @Contact      :   huangshuo4@gmail.com
# @Date         :   2024/1/29
# @License      :   Mulan PSL v2
# @Desc         :   ruyisdk mugen device libs
# #############################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh
source "../common/common_lib.sh"

result_item=()

function test_ouput() {
    local output
    output=$(grep "$2" $1 | awk '{print $2}' | tail -1)
    if [[ "$output" == '(y/N)' ]]; then
        result_item=('y' 'n');
    elif [[ "$output" =~ (1-.) ]]; then
        result_item=${output:0-3:2}
        result_item=${result_item//-/}
        result_item=($(seq $result_item));
    else
        result_item=('e');
    fi
}

function recursion_run() {
    local now_exec=$1
    local end_exec=$2

    if [[ ${#now_exec} -gt 100 ]]; then
        LOG_ERROR "Quit test due to $now_exec longer then 100"
        return 1
    fi

    if [[ "$end_exec" == "y" ]]; then
        echo -e "\nHappy hacking! y y" >> /tmp/ruyi_device/output
    elif [ ! -z "$end_exec" ] && [ "$end_exec" != "0" ]; then
        local ret
        echo -e $now_exec | ruyi device provision 2>&1 > /tmp/ruyi_device/output
        ret=$?
        echo -e "\nHappy hacking! $(expr $end_exec - 1) $ret" >> /tmp/ruyi_device/output
    else
        echo -e $now_exec | ruyi device provision 2>&1 > /tmp/ruyi_device/output
    fi

    grep 'Happy hacking!' /tmp/ruyi_device/output
    if [[ $? -eq 0 ]]; then
        local now_exec_f
        now_exec_f=$(echo -E "$now_exec" | sed 's/\\n//g')
        now_exec_f=$(echo -E "$now_exec_f" | sed 's$/$_$g')
        mv /tmp/ruyi_device/output /tmp/ruyi_device/output_${now_exec_f}
        rm -rf "$(get_ruyi_dir)"/distfiles/*
        rm -rf "$(get_ruyi_data_dir)"/blobs/*
        return 0;
    fi

    local ret
    ret=0
    grep "Proceed with flashing" /tmp/ruyi_device/output
    if [[ $? -eq 0 ]]; then
        rm -rf /tmp/ruyi_device/test
        touch /tmp/ruyi_device/test
        recursion_run "$now_exec\nn" 2
        ret=$(expr $ret + $?)
        # stop and quit
        #recursion_run "$now_exec\ny" 2
        #ret=$(expr $ret + $?)
        return $ret;
    fi
    grep "Please give the path for the target's whole disk" /tmp/ruyi_device/output
    if [[ $? -eq 0 ]]; then
        #rm -rf /tmp/ruyi_device/test
        #touch /tmp/ruyi_device/test
        #recursion_run "$now_exec\n/tmp/ruyi_device/test" 1
        recursion_run "$now_exec" "y"
        return $?;
    fi
    grep "NOTE: You have to consult the official documentation" /tmp/ruyi_device/output
    if [[ $? -eq 0 ]]; then
        recursion_run "$now_exec" "1"
        return $?
    fi
    grep 'Proceed' /tmp/ruyi_device/output
    if [[ $? -eq 0 ]]; then
        test_ouput /tmp/ruyi_device/output 'Proceed'
        local next_step=(${result_item[@]})
        for step in ${next_step[@]}; do
            [ $step = 'n' ] && recursion_run "$now_exec\n$step" "2"
            [ $step = 'y' ] && recursion_run "$now_exec\n$step"
            # [[ $stop =~ [0-9]+ ]] && recursion_run "$now_exec\n$step"
        done
        return $ret;
    fi
    grep 'Choice' /tmp/ruyi_device/output
    if [[ $? -eq 0 ]]; then
        test_ouput /tmp/ruyi_device/output 'Choice'
        local next_step=(${result_item[@]})
        for step in ${next_step[@]}; do
            end_exec=
            [ $step = 'n' ] && end_exec=2
            recursion_run "$now_exec\n$step" $end_exec
            ret=$(expr $ret + $?)
        done
        return $ret;
    fi
    grep 'Continue' /tmp/ruyi_device/output
    if [[ $? -eq 0 ]]; then
        test_ouput /tmp/ruyi_device/output 'Continue'
        local next_step=(${result_item[@]})
        for step in ${next_step[@]}; do
            end_exec=
            [ $step = 'n' ] && end_exec=2
            recursion_run "$step" $end_exec
            ret=$(expr $ret + $?)
        done
        return $ret;
    fi
    mv /tmp/ruyi_device/output /tmp/ruyi_device/output_${now_exec}

    return 1;
}

function test_res() {
    local file=$1
    local res=0
    local ret=0

    ret=$(grep 'Happy hacking!' $file)
    res=$(expr $res + $?)

    local ret_e=$(echo $ret | awk '{print $3}')
    local ret_g=$(echo $ret | awk '{print $4}')

    ( [ $ret_e = 0 ] && [ $ret_g = 0 ] ) || ( [ $ret_e != 0 ] && [ $ret_g != 0 ] ) || ( [ $ret_e = y ] && [ $ret_g = y ] )
    res=$(expr $res + $?)

    return $res
}
