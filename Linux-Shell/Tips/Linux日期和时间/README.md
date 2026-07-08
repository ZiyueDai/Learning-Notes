# 1. Linux的两种时钟

Linux的两种时钟

* 系统时钟：由Linux内核通过CPU的工作频率进行的
* 硬件时钟：主板

# 2. `date`
```powershell
date [OPTION]... [+FORMAT]
```

```powershell
# %F   full date; like %+4Y-%m-%d
root@admin:~# date +%F
2022-11-19

# %T   time; same as %H:%M:%S
root@admin:~# date +%T
18:47:01

# %s   seconds since 1970-01-01 00:00:00 UTC
root@admin:~# date +%s
1668883828
root@admin:~# date -d @`date +%s`     #`date +%s`表示该指令运行后的值
Sat Nov 19 06:50:52 PM UTC 2022
root@admin:~# date -d @1668883828
Sat Nov 19 06:50:52 PM UTC 2022

root@admin:~# date +%F_%H-%M-%S
2022-11-20_03-17-28
```

# 3. `hwclock`
```powershell
hwclock
```

参数：
- `-s, --hctosys` 以硬件时钟为准，校正系统时钟
- `-w, --systohc` 以系统时钟为准，校正硬件时钟

# 4. `timedatectl`
`timedatectl`用于查看或修改时区。

1.查看当前时区
```powershell
root@admin:~# timedatectl status
               Local time: Sun 2022-11-20 02:57:26 CST
           Universal time: Sat 2022-11-19 18:57:26 UTC
                 RTC time: Sat 2022-11-19 18:57:26
                Time zone: Asia/Shanghai (CST, +0800)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```
2.修改时区
```powershell
root@admin:~# timedatectl set-timezone Asia/Shanghai
```
3.查看所有时区
```powershell
root@admin:~# timedatectl list-timezones
Africa/Abidjan
Africa/Accra
Africa/Addis_Ababa
```

# 5. `cat-etc-localtime`
查看时区： 
```powershell
cat /etc/localtime
```

# 6. `cal`
```powershell
[root@host1 ~]# cal
    November 2022   
Su Mo Tu We Th Fr Sa
       1  2  3  4  5
 6  7  8  9 10 11 12
13 14 15 16 17 18 19
20 21 22 23 24 25 26
27 28 29 30
```
```powershell
[root@host1 ~]# cal 1 1997
    January 1997  
Su Mo Tu We Th Fr Sa
          1  2  3  4
 5  6  7  8  9 10 11
12 13 14 15 16 17 18
19 20 21 22 23 24 25
26 27 28 29 30 31
```