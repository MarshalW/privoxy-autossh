# 基于privoxy和autossh的灵活代理服务

基于docker/docker-compose，只需简单的配置，就可以迅速搭建起灵活定制的代理服务。

## 主要应用场景

方便服务器环境下正常访问github/google/docker等境外数据源。

灵活定制白名单，只有在白名单内才会使用socks5境外代理。

需要在境外有一个节点（用于socks5代理），仅需在节点上开设ssh forward权限（不必执行命令）的普通ssh账号即可。

## 使用到的技术

- docker/docker-compose
- privoxy
- autossh/ssh

## 配置

确保本地docker/docker-compose环境已经安装，能够正常使用。

### 下载源代码

```properties
git clone 
```

### 设置config文件

将境外节点账号设置到`config/config`文件

```properties
cp config/config.template config/config
```

替代文件中`${..}`部分的信息：

```
Host sjhk
    HostName 1.1.1.101
    Port 3000
    User tom
    IdentityFile ~/.ssh/id_rsa
```

### 境外节点ssh用户账号设置key

生成key文件：

```properties
./scripts/generate-key.sh
```

将./config/id_rsa.pub文件设置到ssh服务器对应账号的`./ssh/authorized_keys`

```
ssh-copy-id -i ./config/id_rsa.pub ${SSH_SERVER_IP}
```

## 启动服务

执行命令：

```
docker-compose up --build -d
```

默认启动的http代理端口是`8118`


## 检查代理是否生效

先通过`docker ps`查看服务是否启动：

```properties
$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS                    PORTS                    NAMES
3da377623e2c   vagrant_autossh-server   "tini -- /run.sh"        35 minutes ago   Up 35 minutes                                      autossh-server
7029ac4f701b   vagrant_proxy-server     "privoxy --no-daemon…"   35 minutes ago   Up 35 minutes (healthy)   0.0.0.0:8118->8118/tcp   proxy-server
```

然后，在其他节点上尝试使用此代理服务器(http://192.168.0.111:8118)：

```properties
❯ curl cip.cc -x http://192.168.0.111:8118 -v
*   Trying 192.168.0.111...
* TCP_NODELAY set
* Connected to 192.168.0.111 (192.168.0.111) port 8118 (#0)
> GET http://cip.cc/ HTTP/1.1
> Host: cip.cc
> User-Agent: curl/7.64.1
> Accept: */*
> Proxy-Connection: Keep-Alive
>
< HTTP/1.1 200 OK
< Server: openresty
< Date: Wed, 20 Jan 2021 08:58:35 GMT
< Content-Type: text/html; charset=UTF-8
< Transfer-Encoding: chunked
< Connection: keep-alive
< Vary: Accept-Encoding
< X-cip-c: H
< Proxy-Connection: keep-alive
<
IP	: 104.151.40.7
地址	: 韩国  首尔

数据二	: 韩国 | AWS

数据三	:

URL	: http://www.cip.cc/104.151.40.7
* Connection #0 to host 192.168.0.111 left intact
* Closing connection 0
```

说明代理生效并且已经成功从socks5代理访问。

## 定制代理白名单

./config/whitelist.action

```
...
#whitelist
{whitelist}
.google.com
.cip.cc
```

在文件末尾自定义域名后缀即可。

## 在vagrant下使用

创建Vagrantfile

```
cp Vagrantfile.template Vagrantfile
```

Vagrantfile中假定

- 你处在一个有DHCP的网络
- 通过本地宿主机指定网卡`eth0` bridge

如有不同，可稍作改动适配。

启动：

```
vagrant up
```

启动服务：

```
cd /Vagrant
docker-compose up --build -d
```