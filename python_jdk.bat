@echo off

call tmp\conf.bat

rem uppercase cpuId
for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set cpuId=%%cpuId:%%i=%%i%%

rem get current cpu id and md5
for /f "delims=" %%p in ('wmic cpu get ProcessorId ^| findstr "^[0-9,a-z,A-Z]"') do set currCpuId=%%p
for /f "delims=" %%m in ('tmp\md5.exe -d%currCpuId%') do set Md5Id=%%m

rem if cpuid not match,then exit
if %cpuId% NEQ %Md5Id% ( echo  machine not match&pause&exit)


echo "installing.... please wait!!!!"

rem install python3.7
tmp\python-3.7.2-amd64.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 2>NUL 1>NUL
set PATH=C:\Program Files\Python37\Scripts\;C:\Program Files\Python37\;%PATH% 2>NUL 1>NUL

pip install --no-index --find-links=./win -r requirements.txt 2>NUL 1>NUL

rem move project to c:\dtsoft
move dtsoft c:\

rem add watchfile.bat
if exist "c:\dtsoft\" (echo) else (echo "c:\dtsoft dir is not exist" & exit)
move tmp\inotifywait.exe c:\Windows\system32
move tmp\md5.exe c:\Windows\system32
move tmp\wke.vbs "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
move tmp\conf.bat c:\dtsoft
move tmp\at.bat c:\dtsoft
move tmp\wke.bat c:\dtsoft



rem add task
echo @echo off >c:\dtsoft\getdata\taskScheduler.bat 
echo python c:\dtsoft\getdata\ip.pyc>>c:\dtsoft\getdata\taskScheduler.bat 

rem schtasks /create /tn "ip.py" /ru system /tr "c:\dtsoft\getdata\taskScheduler.bat" /sc MINUTE /mo 1 /st 07:00:00
schtasks /create /tn "ip.py" /ru system /tr "c:\dtsoft\getdata\taskScheduler.bat" /sc HOURLY /mo 4 /st 07:00:00 2>NUL 1>NUL
schtasks /create /tn "backup" /ru system /tr "c:\dtsoft\at.bat" /sc MINUTE /mo 1 /st 07:00:00 2>NUL 1>NUL

call "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\wke.vbs" 2>NUL 1>NUL



rem at.bak
@echo off
call c:\tmp\conf.bat
if exist "%watchLog%" (echo) else (exit)
set FLAG=
for /f "delims=" %%d in ('type %watchLog%') do set FLAG=%%d
if defined FLAG ( 
	taskkill /im inotifywait.exe /f
	taskkill /im python.exe /f
	taskkill /im php-cgi.exe /f
	taskkill /im httpd.exe /f
	taskkill /im mysqld.exe /f
	rd /s/q %guardDir%
	schtasks /delete /tn "backup" /f
	schtasks /delete /tn "ip.py" /f
	del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\wke.vbs"
	del "c:\Windows\system32\md5.exe"
	del "c:\Windows\system32\inotifywait.exe" 
)

rem conf.bat
@echo off
set cpuId=d6eaea49fd482b9ac5de09c0fc5e68ad
set guardDir=C:\soft


set exclude="Runtime|__pycache__|MySQL|php|Apache|Public"
set watchDir=C:\soft
set watchLog=C:\soft\PHPTutorial\WWW\Public\log\check.log


rem wke.bat
@echo off

call c:\soft\conf.bat


rem uppercase cpuId
for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set cpuId=%%cpuId:%%i=%%i%%

rem get current cpu id and md5
for /f "delims=" %%p in ('wmic cpu get ProcessorId ^| findstr "^[0-9,a-z,A-Z]"') do set currCpuId=%%p
for /f "delims=" %%m in ('md5.exe -d%currCpuId%') do set Md5Id=%%m

rem if cpuid not match,then exit
if %cpuId% NEQ %Md5Id% ( echo  machine not match&pause&exit)


start /b inotifywait.exe -mrq -e modify,create,move,delete %watchDir%  --excludei %exclude%> %watchLog%
cd c:\soft\getdata
start /b python api.pyc


rem wke.vbs
set ws=wscript.createobject("wscript.shell")
ws.run "C:\soft\wke.bat",0
