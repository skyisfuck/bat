@echo off 
color 1f 
title 关闭常见的危险端口和共享
echo. 
echo. 
echo 本批处理用于启动win7及以上防火墙并关闭常见的危险端口 
echo. 
echo 请确认您正在使用的是win7及以上系统 并且未安装其他防火墙 
echo. 
echo 以避免与win7及以上系统的防火墙发生冲突 
echo. 
echo. 
echo. 
pause 
cls 
echo 正在启动防火墙 请稍候… 
sc config SharedAccess start= auto > nul 
net start SharedAccess > nul 
echo 防火墙已经成功启动 
echo. 
echo 正在关闭常见的危险端口和共享 请稍候… 
echo.   
echo 正在关闭137端口 请稍候… 
netsh advfirewall firewall add rule name = "Disable port 137 - TCP" dir = in action = block protocol = TCP localport = 137
echo. 
netsh advfirewall firewall add rule name = "Disable port 137 - UDP" dir = in action = block protocol = UDP localport = 137
echo. 
echo 正在关闭138端口 请稍候… 
netsh advfirewall firewall add rule name = "Disable port 138 - TCP" dir = in action = block protocol = TCP localport = 138
echo. 
netsh advfirewall firewall add rule name = "Disable port 138 - UDP" dir = in action = block protocol = UDP localport = 138
echo. 
echo 正在关闭139端口 请稍候… 
netsh advfirewall firewall add rule name = "Disable port 139 - TCP" dir = in action = block protocol = TCP localport = 139
echo. 
netsh advfirewall firewall add rule name = "Disable port 139 - UDP" dir = in action = block protocol = UDP localport = 139
echo. 
echo 正在关闭445端口 请稍候… 
netsh advfirewall firewall add rule name = "Disable port 445 - TCP" dir = in action = block protocol = TCP localport = 445
echo. 
netsh advfirewall firewall add rule name = "Disable port 445 - UDP" dir = in action = block protocol = UDP localport = 445
echo.
echo 正在关闭593端口 请稍候… 
netsh advfirewall firewall add rule name = "Disable port 593 - TCP" dir = in action = block protocol = TCP localport = 593
echo. 
netsh advfirewall firewall add rule name = "Disable port 593 - UDP" dir = in action = block protocol = UDP localport = 593
echo.
echo 正在关闭1025端口 请稍候… 
netsh advfirewall firewall add rule name = "Disable port 1025 - TCP" dir = in action = block protocol = TCP localport = 1025
echo. 
netsh advfirewall firewall add rule name = "Disable port 1025 - UDP" dir = in action = block protocol = UDP localport = 1025
echo.
echo 正在关闭常用共享 请稍候… 
net share 
net share ipc$ /del 
net share c$ /del 
net share d$ /del 
net share e$ /del 
net share f$ /del 
net share admin$ /del
cls  
echo. 
echo. 
echo. 
echo 常见的危险端口和共享已关闭 
echo. 
echo. 
echo. 
echo. 
echo 
echo. 
echo. 
echo. 
echo 按任意键退出 
pause>nul 
