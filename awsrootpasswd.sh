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

# 修改主sshd_config文件
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 如果PermitRootLogin行不存在，则添加它
if ! grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

# 检查是否存在Include指令
if grep -q "Include /etc/ssh/sshd_config.d/\*.conf" /etc/ssh/sshd_config; then
    echo "检测到Include指令，正在处理额外的配置文件..."
    
    # 确保目录存在
    mkdir -p /etc/ssh/sshd_config.d

    # 创建一个新的配置文件来覆盖其他设置
    echo "# 由脚本创建以允许root登录和密码认证" > /etc/ssh/sshd_config.d/00-allow-root-login.conf
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config.d/00-allow-root-login.conf
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config.d/00-allow-root-login.conf
    
    echo "已创建 /etc/ssh/sshd_config.d/00-allow-root-login.conf 文件"
fi

# 重启SSH服务
if systemctl is-active --quiet ssh; then
    systemctl restart ssh
elif systemctl is-active --quiet sshd; then
    systemctl restart sshd
else
    echo "无法找到SSH服务。请手动重启SSH服务。"
    exit 1
fi

if [ $? -ne 0 ]; then
    echo "重启SSH服务失败"
    exit 1
fi

echo "root登录已启用，密码已设置。请记住，启用root登录可能会带来安全风险。"
echo "建议您在必要的操作完成后禁用root登录。"
