#!/bin/bash

# 函数：询问是否执行操作
ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "请回答 yes 或 no.";;
        esac
    done
}

# 函数：禁用SELinux
disable_selinux() {
    if [ -f /etc/sysconfig/selinux ]; then
        sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/sysconfig/selinux
    fi
    if [ -f /etc/selinux/config ]; then
        sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
    fi
    sudo setenforce 0
    echo "SELinux 已被禁用。"
}

# 函数：启用root登录和密码认证
enable_root_login() {
    sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    
    if [ -d "/etc/ssh/sshd_config.d" ]; then
        sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config.d/*.conf
        sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config.d/*.conf
    fi
    
    echo "Root登录和密码认证已启用。"
}

# 主脚本开始
echo "欢迎使用交互式系统配置脚本"

if ask_yes_no "是否要禁用SELinux？"; then
    disable_selinux
fi

if ask_yes_no "是否要启用root登录和密码认证？"; then
    enable_root_login
    
    if ask_yes_no "是否要更改root密码？"; then
        while true; do
            read -s -p "请输入新的root密码: " root_password
            echo
            read -s -p "请再次输入新的root密码: " root_password_confirm
            echo
            if [ "$root_password" = "$root_password_confirm" ]; then
                echo "root:$root_password" | sudo chpasswd root
                echo "Root密码已更改。"
                break
            else
                echo "密码不匹配，请重试。"
            fi
        done
    fi
fi

if ask_yes_no "是否要重启SSH服务？"; then
    if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl restart sshd
        sudo systemctl restart ssh
    else
        sudo service sshd restart
        sudo service ssh restart
    fi
    echo "SSH服务已重启。"
fi

echo "脚本执行完毕。"
