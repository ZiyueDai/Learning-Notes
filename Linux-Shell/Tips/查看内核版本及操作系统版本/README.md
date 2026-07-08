# 1. 查看系统架构 `arch`
```
root@ubuntu2004:~# arch
x86_64

[root@centos8 ~]# arch
x86_64

[root@rhel5 ~]# arch
i686
```

# 2. 查看内核版本 `uname -r`
```
[root@centos8 ~]#uname -r
4.18.0-147.el8.x86_64

[root@centos7 ~]#uname -r
3.10.0-1062.el7.x86_64

[root@centos6 ~]# uname -r
2.6.32-754.el6.x86_64

[root@ubuntu1804 ~]#uname -r
4.15.0-29-generic
```

# 3. 查看发行版本
1. `cat /etc/redhat-release`
> 适用于Redhat、CentOS、Rocky等OS。
```powershell
[root@centos8 ~]#cat /etc/redhat-release
CentOS Linux release 8.1.1911 (Core)
```
2. `cat /etc/os-release`
```powershell
# CentOS
[root@centos8 ~]#cat /etc/os-release
NAME="CentOS Linux"
VERSION="8 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="8"
PLATFORM_ID="platform:el8"
PRETTY_NAME="CentOS Linux 8 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:8"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"
CENTOS_MANTISBT_PROJECT="CentOS-8"
CENTOS_MANTISBT_PROJECT_VERSION="8"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="8"

# Ubuntu
[root@ubuntu1804 ~]#cat /etc/os-release
NAME="Ubuntu"
VERSION="18.04.1 LTS (Bionic Beaver)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 18.04.1 LTS"
VERSION_ID="18.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-
policy"
VERSION_CODENAME=bionic
UBUNTU_CODENAME=bionic
```
3. `lsb_release -a`
```powershell
# CentOS
[root@centos8 ~]#lsb_release -a
LSB Version: :core-4.1-amd64:core-4.1-noarch
Distributor ID: CentOS
Description: CentOS Linux release 8.1.1911 (Core)
Release: 8.1.1911
Codename: Core

# Ubuntu
[root@ubuntu1804 ~]#lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description: Ubuntu 18.04.1 LTS
Release: 18.04
Codename: bionic
```
4. `cat /etc/issue`
>适用于Ubuntu OS。
```powershell
[root@ubuntu1804 ~]#cat /etc/issue
Ubuntu 18.04.1 LTS \n \l
```

# 4. `lsb_release`的一些用法
```powershell
# Ubuntu
root@ubuntu2004:~# lsb_release -is
Ubuntu
root@ubuntu2004:~# lsb_release -cs
focal
root@ubuntu2004:~# lsb_release -rs
20.04

# CentOS
[root@centos7 ~]#lsb_release -is
CentOS
[root@centos7 ~]#lsb_release -cs
Core
[root@centos7 ~]#lsb_release -rs
7.9.2009
```
