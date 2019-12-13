@echo off

set i=1

:start
tasklist | findstr /r "^mitmdump.*[1-9][0-9],"
if %ERRORLEVEL% == 0 (
       if %i% == 3 (
           goto :end
       ) else if %i% lss 3 (
           set /A i=%i%+1
           ping 111.1.1.111 -w 1 -n 1 >nul
           goto :start
       ) else (
           goto :end
       )
)

tasklist | findstr /r "^YJ.*[2-9][0-9][0-9],"
if %ERRORLEVEL% == 0 (
    ping 111.1.1.111 -w 1 -n 10 >nul
    start /b cmd /k "d: && cd \test\a && mitmdump.exe >mitmdump.log"
    goto :end
) else (
    ping 111.1.1.111 -w 1 -n 4 >nul
    goto :start
)

:end
