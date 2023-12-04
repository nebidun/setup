#!/bin/bash

# 更新系统
apt update
apt upgrade -y

echo "请输入您希望更改的新SSH端口:" 
read new_ssh_port
sed -i '/^#Port 22/c\Port '$new_ssh_port /etc/ssh/sshd_config

# 重启SSH服务
systemctl restart ssh

echo "请输入您要增加的用户名:" 
read username

echo "请输入用户'$username'的密码:" 
read -s password

# 添加非root用户
adduser $username --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$username:$password" | chpasswd

# 安装sudo并配置权限
apt update && apt install sudo -y

echo "$username ALL=(ALL) NOPASSWD: ALL" | EDITOR='tee -a' visudo

# 禁用root用户SSH远程登录
sed -i '/^PermitRootLogin/c\PermitRootLogin no' /etc/ssh/sshd_config

# 重启SSH服务
systemctl restart ssh

# 询问是否安装防火墙
read -p "是否安装防火墙？(1. 安装 2. 不安装): " install_firewall_choice
if [ "$install_firewall_choice" == "1" ]; then
    echo "正在安装和配置防火墙..."
    apt install ufw -y
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow $new_ssh_port/tcp
    ufw enable
    echo "防火墙安装和基本配置完成。"
else
    echo "未安装防火墙。"
fi

echo "服务器设置完成。"
