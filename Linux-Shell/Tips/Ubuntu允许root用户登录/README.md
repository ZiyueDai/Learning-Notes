由于ubuntu默认不允许root用户远程登录，则需要以下设置：

1. 以普通用户登录到目标服务器
```shell
ssh <User Name>@<IP Address>
```
2. 切换到root用户并设置密码
```powershell
sudo -i

passwd
```
3. 编辑配置文件`/etc/ssh/sshd_confg`允许root用户远程登录
 ```powershell
vim /etc/ssh/sshd_config
...
PermitRootLogin yes
...
```
4. 重启`sshd`​服务
```powershell
systemctl status sshd.service / ssh.service

systemctl restart sshd.service / ssh.service

systemctl status sshd.service / ssh.service
```