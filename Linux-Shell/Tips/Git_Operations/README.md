# 1. 通过VMware VM（Rocky Linux 9）将Windows本地的Git仓库同步到Github/Gitee

## 第 1 步: 打开VMware VM的设置，转到选项菜单，设置共享文件夹。
![输入图片说明](image/%E5%85%B1%E4%BA%AB%E6%96%87%E4%BB%B6%E5%A4%B9.jpg)

## 第 2 步：确认并安装必要的工具

```bash
# 安装 VMware Tools 核心组件
sudo dnf install open-vm-tools -y

# 安装 fuse 模块（共享文件夹依赖）
sudo dnf install fuse -y
```

## 第 3 步：加载必要的内核模块

```bash
# 加载 vmhgfs 模块
sudo modprobe vmhgfs
```

## 第 4 步：创建挂载点并挂载共享文件夹

```bash
# 确保挂载点目录存在
sudo mkdir -p /mnt/hgfs

# 挂载共享文件夹（两种方式，按顺序试）
# 方式一：使用 vmhgfs-fuse（推荐）
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other -o uid=0 -o gid=0 -o umask=022

# 如果方式一报错，试试方式二
sudo mount -t fuse.vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
```

## 第 5 步：验证挂载结果

```bash
# 查看挂载是否成功
df -h | grep hgfs

# 查看共享文件夹内容
ls -la /mnt/hgfs/
```

如果 `ls -la /mnt/hgfs/` 命令显示了你在 VMware 中设置的共享文件夹名称，就说明成功了！

---

## 🧪 如果还是空的：检查 VMware 设置

确认一下 VMware 端的配置：

### ① 检查共享文件夹是否启用

```bash
# 这个命令可以查看 VMware 检测到的共享文件夹列表
vmware-hgfsclient
```
**如果这个命令没有任何输出**，说明 VMware 根本没检测到共享文件夹，问题在 Windows 端设置。

### ② 在 Windows 端重新设置共享文件夹

1. **关闭虚拟机**（必须关机，不能是挂起或运行状态）
2. 虚拟机设置 → **选项** → **共享文件夹**
3. 选择 **"总是启用"**（重要！）
4. 点击 **"添加"**：
   - **主机路径**：选择你 Windows 上的代码文件夹（比如 `D:\my-project`）
   - **名称**：用**纯英文**，不要有空格，比如 `my-project`
   - **属性**：勾选 **"启用此共享"**
5. 确定后，启动虚拟机

### ③ 开机后重新挂载

```bash
# 重新挂载
sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other

# 查看
ls -la /mnt/hgfs/
```

---

## 🔧 如果 `vmhgfs-fuse` 命令不存在

有些系统可能没有这个命令，可以这样安装：

```bash
# 查找 vmhgfs-fuse 在哪里
which vmhgfs-fuse

# 如果找不到，尝试安装
sudo dnf whatprovides vmhgfs-fuse
sudo dnf install vmhgfs-fuse
```

或者直接使用 mount 命令：

```bash
sudo mount -t vmhgfs .host:/ /mnt/hgfs
```
