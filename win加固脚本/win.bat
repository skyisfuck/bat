@Rem 20180116 发现【启用并正确配置WSUS】部分配置不生效，添加部分注册表配置，配置完重启生效，不过组策略里还是显示未配置，暂未找到原因。
@Rem 20180122 在“正确配置WSUS”项中新增了一项配置：对于有已登录用户的计算机，计划的自动更新安装不执行重新启动。
@Rem 20180208 更新关于组策略不显示自动更新相关配置的解释：组策略的修改结果会保存在两个地方：1. 注册表  2. 组策略历史文件（C:\WINDOWS\system32\GroupPolicy\Machine\Registry)注册表里的结果是给应用对象读取来生效的；组策略历史文件是组策略读取的，只是组策略的状态记录，所以组策略里显示“未配置”。
@Rem 20180614 注释“禁用DHCP Client服务”，Server 2012中Network Location Awareness服务和DHCP Client存在依存关系，禁用DHCP服务会导致网络配置失效
@Rem 20190711 配置参数分离，添加NTP配置

@echo off
title Windows 安全加固脚本

rem 防火墙
netsh advfirewall firewall set rule name="远程桌面 - 用户模式(TCP-In)" new remoteip=192.168.2.10,192.168.2.9
netsh advfirewall firewall set rule name="远程桌面 - 用户模式(UDP-In)" new remoteip=192.168.2.10,192.168.2.9




echo [Unicode]>win.inf
echo Unicode=yes>>win.inf
echo [System Access]>>win.inf

for /f "delims=" %%i in ('type "win.ini"^| find /i "="') do set %%i

@Rem 启用密码复杂度策略
echo **** 启用密码复杂度策略
echo PasswordComplexity = 1 >>win.inf

@Rem 配置密码长度最小值为minlen
echo **** 配置密码长度最小值为minlen
echo MinimumPasswordLength = %minlen% >>win.inf

@Rem 更改管理员账户名称为admin
echo **** 更改管理员帐户名称为admin_name
echo NewAdministratorName = "%admin_name%" >>win.inf

@Rem 配置帐户锁定阈值为deny
echo **** 配置帐户锁定阈值为deny
echo LockoutBadCount = %deny%>>win.inf

@Rem 配置“强制密码历史”
echo **** 记住N次已使用的密码
echo PasswordHistorySize = %remember% >>win.inf
echo=

@Rem 删除或禁用高危账户
echo **** 禁用Guest用户
echo EnableGuestAccount = 0 >>win.inf
echo=

@Rem 配置“复位帐户锁定计数器”时间
echo **** 5分钟后重置帐户锁定计数器
echo ResetLockoutCount = 5 >>win.inf
echo=

@Rem 配置帐户锁定时间
echo **** 设置帐户锁定时间为5分钟
echo LockoutDuration = 5 >>win.inf
echo=

@Rem 配置密码最长使用期限（可选,缺省不配置）
echo **** 设置180天更改密码（可选）
echo MaximumPasswordAge = %PASS_MAX_DAYS% >>win.inf
echo=

echo [Event Audit]>>win.inf
@Rem 配置日志审核策略
echo **** 配置日志审核策略
echo AuditSystemEvents = 3 >>win.inf
echo AuditLogonEvents = 3 >>win.inf
echo AuditObjectAccess = 3 >>win.inf
echo AuditPrivilegeUse = 3 >>win.inf
echo AuditPolicyChange = 3 >>win.inf
echo AuditAccountManage = 3 >>win.inf
echo AuditProcessTracking = 3 >>win.inf
echo AuditDSAccess = 3 >>win.inf
echo AuditAccountLogon = 3 >>win.inf
echo=

@Rem 正确配置Windows日志
echo **** 正确配置Windows日志（当日志文件大于128M时按需覆盖事件）
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System" /v MaxSize /t REG_DWORD /d 0x8000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System" /v Retention /t REG_DWORD /d 0x00000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application" /v MaxSize /t REG_DWORD /d 0x8000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application" /v Retention /t REG_DWORD /d 0x00000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security" /v MaxSize /t REG_DWORD /d 0x8000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security" /v Retention /t REG_DWORD /d 0x00000000 /f
echo=

echo [Privilege Rights]>>win.inf
@Rem 限制可关闭系统的帐户和组
echo **** 配置仅“Administrators”用户组可关闭系统
echo SeShutdownPrivilege = *S-1-5-32-544 >>win.inf
echo=

@Rem 限制可从远端关闭系统的帐户和组
echo **** 配置仅“Administrators”用户组可从远端关闭系统
echo SeRemoteShutdownPrivilege = *S-1-5-32-544 >>win.inf
echo=

@Rem 限制“取得文件或其它对象的所有权”的帐户和组
echo **** 配置仅“Administrators”用户组可取得文件或其它对象的所有权
echo SeTakeOwnershipPrivilege = *S-1-5-32-544 >>win.inf
echo=

@Rem 配置“允许本地登录”策略
echo **** 配置仅“Administrators”和“Users”用户组可本地登录
echo SeInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-545 >>win.inf
echo=

@Rem 配置“从网络访问此计算机”策略
echo **** 配置仅“Administrators”和“Users”用户组可从网络访问此计算机
echo SeNetworkLogonRight = *S-1-5-32-544,*S-1-5-32-545 >>win.inf
echo=

@Rem 删除可匿名访问的共享和命名管道
echo **** 将“网络访问: 可匿名访问的共享”、“网络访问: 可匿名访问的命名管道”，配置为空
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v NullSessionShares /t REG_MULTI_SZ /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v NullSessionPipes /t REG_MULTI_SZ /f
echo=

@Rem 限制匿名用户连接
echo **** 将“网络访问: 不允许 SAM 帐户和共享的匿名枚举”、“网络访问: 不允许 SAM 帐户的匿名枚举”，配置为“启用”
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymoussam /t REG_DWORD /d 0x00000001 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymous /t REG_DWORD /d 0x00000001 /f
echo=

@Rem 关闭Windows自动播放
echo **** 启用“关闭自动播放策略”且对所有驱动器生效
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0x000000ff /f
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0x000000ff /f
echo=

@Rem 禁止Windows自动登录
echo **** 禁止Windows自动登录
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 0 /f
echo=

@Rem 正确配置“锁定会话时显示用户信息”策略
echo **** 配置锁定会话时不显示用户信息
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLockedUserId /t REG_DWORD /d 0x00000003 /f
echo=

@Rem 正确配置“提示用户在密码过期之前进行更改”策略
echo **** 配置在密码过期前14天提示更改密码
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v PasswordExpiryWarning /t REG_DWORD /d 0x0000000e /f
echo=

@Rem 禁用Windows磁盘默认共享
echo **** 删除并禁用Windows磁盘默认共享
for /f "tokens=1 delims= " %%i in ('net share') do (
net share %%i /del ) >nul 2>nul
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanServer\Parameters" /v AutoShareServer /t REG_DWORD /d 0x00000000 /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanServer\Parameters" /v AutoShareWks /t REG_DWORD /d 0x00000000 /f
echo=

@Rem 启用Windows数据执行保护(DEP)
echo **** 设置仅为基本Windows程序和服务启用DEP
@Rem Server 2008:
bcdedit /set nx OptIn
@Rem Server 2003:
@Rem /noexecute=optin
echo=

@Rem 启用“不显示最后用户名”策略
echo **** 配置登录屏幕上不要显示上次登录的用户名
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Currentversion\Policies\System" /v DontDisplayLastUserName /t REG_DWORD /d 0x00000001 /f
echo=

@Rem 启用并正确配置NTP（自定义NTP地址）
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\W32Time\Parameters" /v NtpServer /t REG_SZ /d %NTP_ip%,0x9 /f
w32tm /config /manualpeerlist:"%NTP_ip%" /syncfromflags:manual /update
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\W32Time\TimeProviders\NtpServer" /v Enabled /t REG_DWORD /d 0x00000001 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\W32Time\Config" /v AnnounceFlags /t REG_DWORD /d 0x00000005 /f
sc config "W32Time" start= delayed-auto >nul 2>nul
netsh firewall add portopening protocol = UDP port =123 name = NTPSERVER >nul 2>nul
net start w32time >nul 2>nul || net stop w32time >nul 2>nul && net start w32time >nul 2>nul && w32tm /resync >nul 2>nul
w32tm /resync >nul 2>nul
echo=

@Rem 启用并正确配置屏幕保护程序
echo **** 启用屏幕保护程序，等待时间为10分钟，并设置在恢复时需要密码保护
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d C:\Windows\system32\scrnsave.scr /f
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d 1 /f
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d %TMOUT% /f
echo=

@Rem 禁用不必要的服务
echo **** 禁用以下服务：Windows Internet Name Service (WINS)、Remote Access Connection Manager、Simple TCP/IP Services、Simple Mail Transport Protocol (SMTP) 、DHCP Client、DHCP Server、Message Queuing
wmic service where name="SimpTcp" call stopservice >nul 2>nul
sc config "SimpTcp" start= disabled >nul 2>nul
wmic service where name="SMTPSVC" call stopservice >nul 2>nul
sc config "SMTPSVC" start= disabled >nul 2>nul
wmic service where name="WINS" call stopservice >nul 2>nul
sc config "WINS" start= disabled >nul 2>nul
wmic service where name="RasMan" call stopservice >nul 2>nul
sc config "RasMan" start= disabled >nul 2>nul
wmic service where name="DHCPServer" call stopservice >nul 2>nul
sc config "DHCPServer" start= disabled >nul 2>nul
@Rem wmic service where name="DHCP" call stopservice >nul 2>nul
@Rem sc config "DHCP" start= disabled >nul 2>nul
wmic service where name="MSMQ" call stopservice >nul 2>nul
sc config "MSMQ" start= disabled >nul 2>nul
echo=

@Rem 安装最新补丁包和补丁
echo **** 检测是否安装补丁
wmic qfe get hotfixid >nul 2>nul || echo 尚未安装补丁，请安装！
echo=

echo [Version]>>win.inf
echo signature="$CHICAGO$">>win.inf
echo Revision=1 >>win.inf

secedit /configure /db win.sdb /cfg win.inf
del win.inf /q
del win.sdb /q

echo=
echo=
echo=
echo=
echo 【配置完成，部分配置重启系统后生效】
echo=
echo=
echo=
echo=
echo 按任意键退出
pause
goto exit
