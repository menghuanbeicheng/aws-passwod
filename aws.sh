#!/bin/bash

# 检查是否以root权限运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本必须以root权限运行" 1>&2
   exit 1
fi

# 检查参数数量
if [ "$#" -ne 2 ]; then
    echo "用法: $0 <用户名> <新密码>"
    exit 1
fi

USERNAME=$1
NEW_PASSWORD=$2

# 更改密码
echo "$USERNAME:$NEW_PASSWORD" | chpasswd

# 检查密码更改是否成功
if [ $? -eq 0 ]; then
    echo "密码已成功更改"
else
    echo "更改密码时出错"
    exit 1
fi

# 强制用户在下次登录时更改密码
passwd -e $USERNAME

echo "用户 $USERNAME 的密码已更改，并将在下次登录时被要求再次更改密码"
