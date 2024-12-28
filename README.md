一键启动root密码登录

```shell
wget -N --no-check-certificate https://raw.githubusercontent.com/menghuanbeicheng/aws-passwod/refs/heads/main/resetpasswd.sh && bash resetpasswd.sh
```
服务器初始化脚本设置root密码登录
查看createpasswd的内容将rootpasswd修改为自己密码

HttpProxy
```shell
wget -N --no-check-certificate https://raw.githubusercontent.com/menghuanbeicheng/aws-passwod/refs/heads/main/httpPrxoy.sh && bash httpPrxoy.sh username password
```
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
