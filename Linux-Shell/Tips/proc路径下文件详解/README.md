| 档名 | 文件内容 |
|---|---|
|/proc/cmdline       | 加载 kernel 时所下达的相关参数！查阅此文件，可了解系统是如何启动的        |
|/proc/cpuinfo       | 本机的 CPU 的相关资讯，包含时脉、类型与运算功能等                      |
|/proc/devices       | 这个文件记录了系统各个主要装置的主要装置代号，与 mknod 有关             |
|/proc/filesystems   | 目前系统已经加载的文件系统                                      | 
|/proc/interrupts    | 目前系统上面的 IRQ 分配状态。|
|/proc/ioports       | 目前系统上面各个装置所配置的 I/O 位址。|
|/proc/kcore         | 内存的大小|
|/proc/loadavg       |  top 以及 uptime 的三个平均数值就是记录在此 |
|/proc/meminfo       | 使用 free 列出的内存资讯在这里也能够查阅到 |
|/proc/modules       | 目前 Linux 已经加载的模块列表，也可以想成是驱动程序|
|/proc/mounts        | 系统已经挂载的数据，就是用 mount 这个命令得出来的数据 |
|/proc/swaps         | 系统挂加载的内存使用掉的 partition 就记录在此 |
|/proc/partitions    | 使用 fdisk -l 会出现目前所有的 partition，在这个文件当中也有纪录 |
|/proc/pci           | 在 PCI 汇流排上面，每个装置的详细情况！可用 lspci 来查阅！ |
|/proc/uptime        | 就是用 uptime 的时候，会出现的输出 |
|/proc/version       | 核心的版本，就是用 uname -a 显示的内容 |
|/proc/bus/*         | 一些汇流排的装置，还有 U盘 的装置也记录在此 |
|/proc/self/mountinfo | 比/proc/mounts的信息更加详细一些 |