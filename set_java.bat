@echo off

if "%3%" == "" (
    echo "USAGE: %0% IP USER PASS"
	pause
	exit
)

set IP=%1%
set USER=%2%
set PASS=%3%
cd /d %~dp0


for %%x in (java.exe) do set check_java=%%~$PATH:x
if defined check_java goto main else call :find_java

:find_java
for /r c:\ %%i in (bin\j*va.exe) do set check_java=%%i
if not defined check_java call :echo_error
if defined check_java call :set_java
goto :eof

:set_java
set JAVA_HOME=%check_java:~0,-13%
set PATH=%JAVA_HOME%\bin;%PATH%
set ClassPath= .;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar
setx JAVA_HOME "%check_java:~0,-13%" >NUL
setx PATH "%JAVA_HOME%\bin" >NUL
setx ClassPath ".;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar" >NUL
goto :main

:echo_error
echo "ERROR: JAVA is not install this machine"
pause
exit
goto :eof


:main
curl -c cckk.ck -o kvm.log -s -k -X POST "https://%IP%/session/create" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:63.0) Gecko/20100101 Firefox/63.0" -H "Accept: */*" -H "Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2" --compressed -H "Referer: https://%IP%/" -H "Content-Type: text/plain;charset=UTF-8" -H "Connection: keep-alive" --data "%USER%,%PASS%"
curl -b cckk.ck  -o vm.jnlp -s -k  https://%IP%/kvm/vm/jnlp
vm.jnlp
curl -b cckk.ck  -o kvm.jnlp -s -k  https://%IP%/kvm/kvm/jnlp
kvm.jnlp
curl -b cckk.ck  -o kvm.log -s -k -X POST "https://%IP%/session/deactivate" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:63.0) Gecko/20100101 Firefox/63.0" -H "Accept: */*" -H "Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2" --compressed -H "Referer: https://%IP%/" -H "Content-Type: text/plain;charset=UTF-8" -H "Connection: keep-alive" -H "Cookie: session_id=8ac52966-d4d2-4858-b6ab-c6d5b917e033; username=%USER%; systemname=SN# 99C5180; session_expiry=120; loggedin=true" --data ""
goto :eof

