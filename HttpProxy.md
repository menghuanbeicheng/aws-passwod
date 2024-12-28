# 查看服务状态
sudo systemctl status httpproxy

# 查看日志
sudo tail -f /var/log/httpproxy.log

# 重启服务
sudo systemctl restart httpproxy

# 停止服务
sudo systemctl stop httpproxy

# 禁用服务开机自启
sudo systemctl disable httpproxy
