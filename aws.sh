#!/bin/bash

# 检查是否以root权限运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本必须以root权限运行" 1>&2
   exit 1
fi

# 检查参数数量
if [ "$#" -ne 1 ]; then
    echo "用法: $0 <root新密码>"
    exit 1
fi

NEW_ROOT_PASSWORD=$1

# 设置root密码
echo "root:$NEW_ROOT_PASSWORD" | chpasswd
if [ $? -ne 0 ]; then
    echo "设置root密码失败"
    exit 1
fi

# 修改sshd_config以允许root登录
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 如果PermitRootLogin行不存在，则添加它
if ! grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

# 重启SSH服务
systemctl restart sshd
if [ $? -ne 0 ]; then
    echo "重启SSH服务失败"
    exit 1
fi

echo "root登录已启用，密码已设置。请记住，启用root登录可能会带来安全风险。"
echo "建议您在必要的操作完成后禁用root登录。"
