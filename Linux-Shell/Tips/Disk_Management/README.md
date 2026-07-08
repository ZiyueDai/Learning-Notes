# 1. `lsblk`
```powershell
lsblk
```
```powershell
root@admin:~# lsblk
NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0  55.6M  1 loop /snap/core18/2538
loop1                       7:1    0  55.6M  1 loop /snap/core18/2620
loop2                       7:2    0    62M  1 loop /snap/core20/1593
loop3                       7:3    0  63.2M  1 loop /snap/core20/1695
loop4                       7:4    0   103M  1 loop /snap/lxd/23367
loop5                       7:5    0 136.4M  1 loop /snap/lxd/23889
loop6                       7:6    0  49.6M  1 loop /snap/snapd/17576
loop7                       7:7    0    48M  1 loop /snap/snapd/17336
sda                         8:0    0   100G  0 disk 
├─sda1                      8:1    0     1M  0 part 
├─sda2                      8:2    0     1G  0 part /boot
└─sda3                      8:3    0    99G  0 part 
  └─ubuntu--vg-ubuntu--lv 253:0    0  49.5G  0 lvm  /
sr0                        11:0    1  1024M  0 rom 
```

# 2. `cat /proc/partitions`
```powershell
cat /proc/partitions
```

```powershell
root@admin:~# cat /proc/partitions
major minor  #blocks  name

   7        0      56896 loop0
   7        1      56916 loop1
   7        2      63448 loop2
   7        3      64760 loop3
   7        4     105476 loop4
   7        5     139652 loop5
   7        6      50832 loop6
   7        7      49140 loop7
   8        0  104857600 sda
   8        1       1024 sda1
   8        2    1048576 sda2
   8        3  103805952 sda3
  11        0    1048575 sr0
 253        0   51904512 dm-0
```