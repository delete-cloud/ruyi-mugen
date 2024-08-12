#!/usr/bin/bash
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author  : weilinfox
# @email   : caiweilin@iscas.ac.cn
# @Date    : 2024-03-26 13:18:31
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    : Generate test report
#####################################

OET_PATH=$(
    cd "$(dirname "$0")" || exit 1
    pwd
)
RUN_PATH=$(pwd)

source ${OET_PATH}/testcases/cli-test/ruyi/common/common_lib.sh

report_name_js='{
"revyos-riscv64":	"RUYI_包管理_Container_RevyOS_riscv64_测试结果",
"debian12-x86_64":	"RUYI_包管理_QEMU_Debian12_x86_64_测试结果",
"debian12-aarch64":	"RUYI_包管理_QEMU_Debian12_aarch64_测试结果",
"debiansid-riscv64":	"RUYI_包管理_Container_Debiansid_riscv64_测试结果",
"ubuntu2204-x86_64":	"RUYI_包管理_QEMU_Ubuntu22.04_x86_64_测试结果",
"ubuntu2204-riscv64":	"RUYI_包管理_QEMU_Ubuntu22.04_riscv64_测试结果",
"ubuntu2404-x86_64":	"RUYI_包管理_QEMU_Ubuntu24.04_x86_64_测试结果",
"ubuntu2404-riscv64":	"RUYI_包管理_QEMU_Ubuntu24.04_riscv64_测试结果",
"fedora38-x86_64":	"RUYI_包管理_QEMU_Fedora38_x86_64_测试结果",
"fedora38-riscv64":	"RUYI_包管理_QEMU_Fedora38_riscv64_测试结果",
"oE2309-x86_64":	"RUYI_包管理_QEMU_openEuler23.09_x86_64_测试结果",
"oE2309-riscv64":	"RUYI_包管理_QEMU_openEuler23.09_riscv64_测试结果",
"oE2403-x86_64":	"RUYI_包管理_QEMU_openEuler24.03_x86_64_测试结果",
"oE2403-riscv64":	"RUYI_包管理_QEMU_openEuler24.03_riscv64_测试结果",
"archlinux-x86_64":	"RUYI_包管理_Container_Archlinux_x86_64_测试结果",
"archlinux-riscv64":	"RUYI_包管理_Container_Archlinux_riscv64_测试结果",
"gentoo-x86_64":	"RUYI_包管理_QEMU_Gentoo_x86_64_测试结果",
"gentoo-riscv64":	"RUYI_包管理_QEMU_Gentoo_riscv64_测试结果",
"openkylin-x86_64":	"RUYI_包管理_QEMU_openKylin_x86_64_测试结果",
"openkylin-riscv64":	"RUYI_包管理_QEMU_openKylin_riscv64_测试结果",
"oE2309-riscv64-lp4a":	"RUYI_包管理_LicheePi4A_openEuler23.09_riscv64_测试结果",
"oE2403-riscv64-lp4a":	"RUYI_包管理_LicheePi4A_openEuler24.03_riscv64_测试结果",
"revyos-riscv64-lp4a":	"RUYI_包管理_LicheePi4A_RevyOS_riscv64_测试结果",
"oE2309-riscv64-pbx":	"RUYI_包管理_Pioneer_Box_openEuler23.09_riscv64_测试结果",
"fedora38-riscv64-pbx":	"RUYI_包管理_Pioneer_Box_Fedora38_riscv64_测试结果"
}'
log_name_js='{
"revyos-riscv64":	"revyos_riscv64_container",
"debian12-x86_64":	"debian12-x86_64-qemu",
"debian12-aarch64":	"debian12-aarch64-qemu",
"debiansid-riscv64":	"debiansid_riscv64_container",
"ubuntu2204-x86_64":	"ubuntu2204-x86_64-qemu",
"ubuntu2204-riscv64":	"ubuntu2204-riscv64-qemu",
"ubuntu2404-x86_64":	"ubuntu2404-x86_64-qemu",
"ubuntu2404-riscv64":	"ubuntu2404-riscv64-qemu",
"fedora38-x86_64":	"fedora38-x86_64-qemu",
"fedora38-riscv64":	"fedora38-riscv64-qemu",
"oE2309-x86_64":	"oE2309-x86_64-qemu",
"oE2309-riscv64":	"oE2309-riscv64-qemu",
"oE2403-x86_64":	"oE2403-x86_64-qemu",
"oE2403-riscv64":	"oE2403-riscv64-qemu",
"archlinux-x86_64":	"archlinux_x86_64_container",
"archlinux-riscv64":	"archlinux_riscv64_container",
"gentoo-x86_64":	"gentoo_x86_64_qemu",
"gentoo-riscv64":	"gentoo_riscv64_qemu",
"openkylin-x86_64":	"openkylin_x86_64_qemu",
"openkylin-riscv64":	"openkylin_riscv64_qemu",
"oE2309-riscv64-lp4a":	"oE2309-riscv64-lp4a",
"oE2403-riscv64-lp4a":	"oE2403-riscv64-lp4a",
"revyos-riscv64-lp4a":	"revyos-riscv64-lp4a",
"oE2309-riscv64-pbx":	"oE2309-riscv64-pbx",
"fedora38-riscv64-pbx":	"fedora38-riscv64-pbx"
}'
ruyitest_repo="https://gitee.com/yunxiangluo/ruyisdk-test/tree/master/20240312"
ruyitest_repo_raw="https://gitee.com/yunxiangluo/ruyisdk-test/raw/master/20240312"

tmpl_dir=${OET_PATH}/report_gen_tmpl
temp_dir=/tmp/ruyi_report
report_dir=${OET_PATH}/ruyi_report
report_name=`echo $report_name_js | jq -r .\"$1\"`
log_name=`echo $log_name_js | jq -r .\"$1\"`

[ -z "$report_name" ] && {
	echo Unsupported distro
	exit -1
}

[ ! -f $tmpl_dir/26test_log.md ] && {
	echo 26test_log.md not appears
	exit -1
}

ruyi_testsuites=1
ruyi_testcases=`grep "use cases were executed, with" $tmpl_dir/26test_log.md | sed "s/^.* A total of \([0-9]*\) use cases were executed, .*$/\\1/"`
ruyi_success=`grep "use cases were executed, with" $tmpl_dir/26test_log.md | sed "s/^.* with \([0-9]*\) successes and .*$/\\1/"`
ruyi_failed=`grep "use cases were executed, with" $tmpl_dir/26test_log.md | sed "s/^.* successes and \([0-9]*\) failures\.$/\\1/"`
ruyi_timeout=`grep "The case exit by code 143" $tmpl_dir/26test_log.md | wc -l`
ruyi_conclusion="此处添加测试结论"

[ "$ruyi_failed"x = "0x" ] && ruyi_conclusion="没有发现问题"

[[ -d $temp_dir ]] && rm -rf $temp_dir
[[ -d $report_dir ]] && rm -rf $report_dir
mkdir $temp_dir $report_dir

export_ruyi_link

cp ${tmpl_dir}/*.md ${tmpl_dir}/$1/*.md $temp_dir/


for f in `ls ${temp_dir} | sort`; do
	echo Find template ${temp_dir}/$f
	cat ${temp_dir}/$f >> $report_dir/my
done

rm -rf $temp_dir

sed -i "s/{{ruyi_arch}}/$arch/g" $report_dir/my
sed -i "s/{{ruyi_version}}/$version/g" $report_dir/my
sed -i "s|{{ruyi_link}}|$ruyi_link|g" $report_dir/my
sed -i "s|{{ruyitest_repo}}|$ruyitest_repo|g" $report_dir/my
sed -i "s|{{ruyitest_repo_raw}}|$ruyitest_repo_raw|g" $report_dir/my
sed -i "s/{{ruyi_testsuites}}/$ruyi_testsuites/g" $report_dir/my
sed -i "s/{{ruyi_testcases}}/$ruyi_testcases/g" $report_dir/my
sed -i "s/{{ruyi_conclusion}}/$ruyi_conclusion/g" $report_dir/my
sed -i "s/{{ruyi_success}}/$ruyi_success/g" $report_dir/my
sed -i "s/{{ruyi_failed}}/$ruyi_failed/g" $report_dir/my
sed -i "s/{{ruyi_timeout}}/$ruyi_timeout/g" $report_dir/my
sed -i "s/{{log_name}}/$log_name/g" $report_dir/my

mv -v $report_dir/my $report_dir/$report_name.md

# format test logs name
for f in $(find "${OET_PATH}"/logs -type f); do
	mv "$f" "$(echo "$f" | sed "s/:/_/g")"
done

[ -d "${OET_PATH}/${log_name}" ] && rm -rf "${OET_PATH}/${log_name}"
mkdir "${OET_PATH}/${log_name}"
cp -r "${OET_PATH}"/logs/* "${OET_PATH}/${log_name}/"

# get failed logs
mkdir "${OET_PATH}/logs_failed"
cd "${OET_PATH}"
for f in $(find ./logs -type f); do
	if grep " - ERROR - failed to execute the case." "$f"; then
		NEW_FILE="$(echo "$f" | sed "s/logs/logs_failed/")"
		mkdir -p "$(dirname $NEW_FILE)"
		mv -v "$f" "$NEW_FILE"
	fi
done
rmdir --ignore-fail-on-non-empty ./logs_failed

# pack all logs
[ -d ./logs_failed ] && mv logs_failed "${log_name}"_failed && tar zcvf ruyi-test-logs_failed.tar.gz ./"${log_name}"_failed || touch ruyi-test-logs_failed.tar.gz
tar zcvf ruyi-test-logs.tar.gz ./"${log_name}"
cd $RUN_PATH

