cd $env:USERPROFILE\Desktop
(type "$env:USERPROFILE\Desktop\modify_target.vbs") -replace ('flag',"$env:USERPROFILE")|out-file $env:USERPROFILE\Desktop\modify_target.vbs


