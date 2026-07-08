# 节点之间实现免密登录 （SSH公钥认证）

## 1. 在主节点上生成公钥

```shell

ssh-keygen -t rsa

```



Example Output:

```

Generating public/private rsa key pair.

Enter file in which to save the key (/root/.ssh/id\_rsa):  <Enter>

Enter passphrase (empty for no passphrase):  <Enter>

Enter same passphrase again:  <Enter>

Your identification has been saved in /root/.ssh/id\_rsa

Your public key has been saved in /root/.ssh/id\_rsa.pub

The key fingerprint is:

SHA256:b7BWRjKmxl9cRcy+FuR7aYBr9ymUCY8H9Y9Fe3sBnCY root@localhost.localdomain

The key's randomart image is:

+---\[RSA 3072]----+

|            .++  |

|           E B+ .|

|        + . \*+o..|

|     . o = = .++o|

|      + S = \* +\*\*|

|     . . B + B=++|

|        + + +.o.o|

|       . .   . o |

|              .  |

+----\[SHA256]-----+

```

## 2. 将公钥复制到各节点

```shell

ssh-copy-id root@<节点IP>

```

\---



