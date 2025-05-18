# !/bin/bash

# 1. 创建 /etc/gost 目录
mkdir -p /etc/gost

# 2. 进入 /etc/gost 目录
cd /etc/gost

# 3. 下载 GOST 程序包
wget https://github.com/go-gost/gost/releases/download/v3.0.0/gost_3.0.0_linux_amd64.tar.gz

# 4. 解压
tar -vzxf gost_3.0.0_linux_amd64.tar.gz

# 5. 提示输入端口、账号、密码
read -p "请输入 socks5 端口（如 22550）: " PORT
read -p "请输入 socks5 用户名: " USER
read -s -p "请输入 socks5 密码: " PASS
echo

# 6. 创建 systemd 服务文件
bash -c "cat > /etc/systemd/system/gost.service" <<EOF
[Unit]
Description=GOST Proxy Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/etc/gost
ExecStart=/etc/gost/gost -L "socks5://\$USER:\$PASS@0.0.0.0:\$PORT?udp=true&udpBufferSize=4096"
Restart=on-failure
RestartSec=5
StandardOutput=append:/etc/gost/gost.log
StandardError=append:/etc/gost/gost.log

[Install]
WantedBy=multi-user.target
EOF

# 7. 替换 ExecStart 里的变量
sed -i "s|\\\$USER|$USER|g" /etc/systemd/system/gost.service
sed -i "s|\\\$PASS|$PASS|g" /etc/systemd/system/gost.service
sed -i "s|\\\$PORT|$PORT|g" /etc/systemd/system/gost.service

# 8. 设置 systemd 并启动
systemctl daemon-reload
systemctl enable gost
systemctl start gost

echo "GOST 已安装并自启动，监听端口 $PORT，用户名 $USER。"
echo "你可以用如下命令查看日志："
echo "  sudo tail -f /etc/gost/gost.log"
echo "如需更改配置，请修改 /etc/systemd/system/gost.service 后执行 sudo systemctl daemon-reload && sudo systemctl restart gost"
