# -*- coding: utf-8 -*-
"""
 Copyright (c) [2023] ISCAS PLCT.ALL rights reserved.
 This program is licensed under Mulan PSL v2.
 You can use it according to the terms and conditions of the Mulan PSL v2.
          http://license.coscl.org.cn/MulanPSL2
 THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 See the Mulan PSL v2 for more details.

 @Author  : weilinfox
 @email   : caiweilin@iscas.ac.cn
 @Date    : 2024-04-11 21:23:50
 @License : Mulan PSL v2
 @Version : 1.0
 @Desc    : gentoo 软件包的安装卸载
"""

import os
import sys
import subprocess
import tempfile
import argparse

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log
import ssh_cmd


def local_cmd(cmd, conn=None):
    """本地命令执行

    Args:
        cmd ([str]): 需要执行的命令
        conn ([class], optional): 建立和远端的连接. Defaults to None.

    Returns:
        [list]: 命令执行后的返回码，命令执行结果
    """
    exitcode, output = subprocess.getstatusoutput(cmd)
    return exitcode, output


def emerge_install(pkgs, node=1, tmpfile=""):
    """安装软件包

    Args:
        pkgs ([str]): 软包包名，"bc" or "bc vim"
        node (int, optional): 节点号. Defaults to 1.
        tmpfile (str, optional): 软件包及其依赖包的缓存文件. Defaults to "".

    Returns:
        [list]: 错误码，安装的包的列表
    """
    if pkgs == "":
        mugen_log.logging("error", "the following arguments are required:pkgs")
        sys.exit(1)

    localtion = os.environ.get("NODE" + str(node) + "_LOCALTION")
    if localtion == "local":
        conn = None
        func = local_cmd
    else:
        conn = ssh_cmd.pssh_conn(
            os.environ.get("NODE" + str(node) + "_IPV4"),
            os.environ.get("NODE" + str(node) + "_PASSWORD"),
            os.environ.get("NODE" + str(node) + "_SSH_PORT"),
            os.environ.get("NODE" + str(node) + "_USER"),
        )
        func = ssh_cmd.pssh_cmd

    result = func(conn=conn, cmd="whereis -b emerge | cut -d':' -f2")[1]
    if result.strip() == "":
        mugen_log.logging("info", "unsupported package manager: emerge")
        return 0, None

    depCode, depList = func(
        conn=conn,
        cmd="sudo emerge --color=n --getbinpkg --noreplace --autounmask=y --pretend "
        + pkgs
        + ' 2>&1 | grep -E "\[ebuild|\[binary[ ]*N[ ]*\]" | sed "s/\[ebuild\|\[binary[ ]*N[ ]*\] \([^ \.]*\)[:-][0-9]*[ \.:].*/\\1/" | { while read lll; do echo -n "$lll "; done }'
    )
    if len(depList.strip()) == 0:
        mugen_log.logging("info", "pkgs:(%s) is already installed" % pkgs)
        return 0, None

    exitcode, result = func(conn=conn, cmd="sudo emerge --getbinpkg " + depList)

    if tmpfile == "":
        tmpfile = tempfile.mkstemp(dir="/tmp")[1]

    with open(tmpfile, "a+") as f:
        f.write(depList)

    result = f.name

    return exitcode, result


def emerge_remove(pkgs="", node=1, tmpfile=""):
    """卸载软件包

    Args:
        pkgs (str, optional): 需要卸载的软件包. Defaults to "".
        node (int, optional): 节点号. Defaults to 1.
        tmpfile (str, optional): 安装时所有涉及的包. Defaults to "".

    Returns:
        list: 错误码，卸载列表或错误信息
    """
    if pkgs == "" and tmpfile == "":
        mugen_log.logging(
            "error", "Packages or package files these need to be removed must be added"
        )
        sys.exit(1)

    localtion = os.environ.get("NODE" + str(node) + "_LOCALTION")
    if localtion == "local":
        conn = None
        func = local_cmd
    else:
        conn = ssh_cmd.pssh_conn(
            os.environ.get("NODE" + str(node) + "_IPV4"),
            os.environ.get("NODE" + str(node) + "_PASSWORD"),
            os.environ.get("NODE" + str(node) + "_SSH_PORT"),
            os.environ.get("NODE" + str(node) + "_USER"),
        )
        func = ssh_cmd.pssh_cmd

    result = func(conn=conn, cmd="whereis -b emerge | cut -d':' -f2")[1]
    if result.strip() == "":
        mugen_log.logging("info", "unsupported package manager: emerge")
        return 0, None

    depList = ""
    if tmpfile != "":
        with open(tmpfile, "r") as f:
            depList = f.read()

    exitcode = func(conn=conn, cmd="sudo emerge --depclean " + pkgs + " " + depList)[0]
    if localtion != "local":
        ssh_cmd.pssh_close(conn)
    return exitcode


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        usage="emerge_manage.py install|remove [-h] [--node NODE] [--pkgs PKG] [--tempfile TEPMFILE]",
        description="manual to this script",
    )
    parser.add_argument(
        "operation", type=str, choices=["install", "remove"], default=None
    )
    parser.add_argument("--node", type=int, default=1)
    parser.add_argument("--pkgs", type=str, default="")
    parser.add_argument("--tempfile", type=str, default="")
    args = parser.parse_args()

    if sys.argv[1] == "install":
        exitcode, output = emerge_install(args.pkgs, args.node, args.tempfile)
        if output is not None:
            print(output)
        sys.exit(exitcode)
    elif sys.argv[1] == "remove":
        exitcode = emerge_remove(args.pkgs, args.node, args.tempfile)
        sys.exit(exitcode)
    else:
        mugen_log.logging(
            "error",
            "usage: emerge_manage.py install|remove [-h] [--node NODE] [--pkg PKG] [--tempfile TEPMFILE]",
        )
        sys.exit(1)
