# vkit

Tools and Scripts for Linux VPS

<!--
# cdn: https://cdn.jsdelivr.net/gh/:user/:repo/, https://cdn.jsdelivr.net/gh/cloudend/scripts@main/tools.sh
# cdn: https://hub.fastgit.org/:user/:repo/, https://hub.fastgit.org/zhboner/realm/releases/download/v1.4/realm
# cdn: https://ghproxy.com/https://github.com/:user/:repo/, https://ghproxy.com/https://github.com/zhboner/realm/releases/download/v1.4/realm
-->

- vkit(include all scripts)

```sh
bash <(curl -Lso- https://sh.vps.dance/vkit.sh)
```

- add swap space

```sh
bash <(curl -Lso- https://sh.vps.dance/swap.sh)
```

- add SSH public key

```sh
bash <(curl -Lso- https://sh.vps.dance/ssh.sh) key
```

- change SSH port

```sh
bash <(curl -Lso- https://sh.vps.dance/ssh.sh) port
```

- prefer IPv4/IPv6; enable/disable IPv6;

```sh
bash <(curl -Lso- https://sh.vps.dance/ip46.sh)
```

- install ddns-go

```sh
bash <(curl -Lso- https://sh.vps.dance/tools.sh) ddns-go -p
```

- install gost

```sh
bash <(curl -Lso- https://sh.vps.dance/tools.sh) gost -p
```

- install realm

```sh
bash <(curl -Lso- https://sh.vps.dance/tools.sh) realm -p
```

- autoBestTrace

```sh
bash <(curl -Lso- https://sh.vps.dance/autoBestTrace.sh)
```

- paste text and share

```sh
bash <(curl -Lso- https://sh.vps.dance/paste.sh)
```

<!--
update cache:
- https://purge.jsdelivr.net/gh/VPSDance/scripts@main/vkit.sh
- https://purge.jsdelivr.net/gh/VPSDance/scripts@main/tools.sh
-->
