#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# 检查参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    echo "Example: $0 admin password123"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

# 创建工作目录
INSTALL_DIR="/opt/httpproxy"
mkdir -p $INSTALL_DIR

# 下载程序
echo "Downloading proxy program..."
wget https://github.com/menghuanbeicheng/aws-passwod/releases/download/1/httpProxy -O $INSTALL_DIR/httpProxy

# 设置执行权限
chmod +x $INSTALL_DIR/httpProxy

# 创建系统服务配置文件
cat > /etc/systemd/system/httpproxy.service << EOF
[Unit]
Description=HTTP Proxy Service
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/httpProxy -username $USERNAME -password $PASSWORD
WorkingDirectory=$INSTALL_DIR
Restart=always
RestartSec=5
StandardOutput=append:/var/log/httpproxy.log
StandardError=append:/var/log/httpproxy.log

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd配置
systemctl daemon-reload

# 启动服务
systemctl enable httpproxy
systemctl start httpproxy

# 检查服务状态
echo "Checking service status..."
systemctl status httpproxy

echo "
Installation completed!

Service commands:
- Check status: systemctl status httpproxy
- Start service: systemctl start httpproxy
- Stop service: systemctl stop httpproxy
- View logs: tail -f /var/log/httpproxy.log

Your proxy is configured with:
Username: $USERNAME
Password: $PASSWORD
"

# 等待服务完全启动
sleep 2

# 检查服务是否正在运行
if systemctl is-active --quiet httpproxy; then
    echo "Service is running successfully!"
else
    echo "Warning: Service failed to start. Please check logs with: journalctl -u httpproxy"
fi
