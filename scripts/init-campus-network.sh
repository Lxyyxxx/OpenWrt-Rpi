#!/bin/bash
#=================================================
# File name: init-campus-network.sh
# Description: This script will be executed during the first boot
# Author: Lxyyxxx
# Reference: https://github.com/EOYOHOO/Campus-network
#=================================================

iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53

iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53

# 通过 rkp-ipid 设置 IPID

# 若没有加入rkp-ipid模块，此部分不需要加入

iptables -t mangle -N IPID_MOD

iptables -t mangle -A FORWARD -j IPID_MOD

iptables -t mangle -A OUTPUT -j IPID_MOD

iptables -t mangle -A IPID_MOD -d 0.0.0.0/8 -j RETURN

iptables -t mangle -A IPID_MOD -d 127.0.0.0/8 -j RETURN

#由于本校局域网是A类网，所以我将这一条注释掉了，具体要不要注释结合你所在的校园网

# iptables -t mangle -A IPID_MOD -d 10.0.0.0/8 -j RETURN

iptables -t mangle -A IPID_MOD -d 172.16.0.0/12 -j RETURN

iptables -t mangle -A IPID_MOD -d 192.168.0.0/16 -j RETURN

iptables -t mangle -A IPID_MOD -d 255.0.0.0/8 -j RETURN

iptables -t mangle -A IPID_MOD -j MARK --set-xmark 0x10/0x10

# 防时钟偏移检测

iptables -t nat -N ntp_force_local

iptables -t nat -I PREROUTING -p udp --dport 123 -j ntp_force_local

iptables -t nat -A ntp_force_local -d 0.0.0.0/8 -j RETURN

iptables -t nat -A ntp_force_local -d 127.0.0.0/8 -j RETURN

iptables -t nat -A ntp_force_local -d 192.168.0.0/16 -j RETURN

iptables -t nat -A ntp_force_local -s 192.168.0.0/16 -j DNAT --to-destination 192.168.1.1

# 通过 iptables 修改 TTL 值 数字为需要的修改的ttl值

iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64

# iptables 拒绝 AC 进行 Flash 检测

iptables -I FORWARD -p tcp --sport 80 --tcp-flags ACK ACK -m string --algo bm --string " src=\"http://1.1.1." -j DROP

# 开机自启
uci set ua2f.enabled.enabled=1
# 自动配置防火墙（默认开启）（建议开启）
uci set ua2f.firewall.handle_fw=1
uci set ua2f.firewall.handle_tls=1
uci set ua2f.firewall.handle_mmtls=1
uci set ua2f.firewall.handle_intranet=1
# 保存配置
uci commit ua2f

# 开机自启
service ua2f enable
# 启动ua2f
service ua2f start

exit 0
