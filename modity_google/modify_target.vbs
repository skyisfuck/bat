On Error Resume Next

Const link = " --enable-webgl --ignore-gpu-blacklist --allow-file-access-from-files"

Const link360 = " --enable-webgl --ignore-gpu-blacklist --allow-file-access-from-files"

browsers = "chrome.exe"

lnkpaths = "flag\Desktop"

browsersArr = Split(browsers,",")

Set oDic = CreateObject("scripting.dictionary")

For Each browser In browsersArr
    oDic.Add LCase(browser), browser
Next

lnkpathsArr = Split(lnkpaths,",")
Set oFolders = CreateObject("scripting.dictionary")

For Each lnkpath In lnkpathsArr
    oFolders.Add lnkpath, lnkpath
Next

Set fso = CreateObject("Scripting.Filesystemobject")
Set WshShell = CreateObject("Wscript.Shell")

For Each oFolder In oFolders
    If fso.FolderExists(oFolder) Then
        For Each file In fso.GetFolder(oFolder).Files
            If LCase(fso.GetExtensionName(file.Path)) = "lnk" Then
                Set oShellLink = WshShell.CreateShortcut(file.Path)
                path = oShellLink.TargetPath
                name = fso.GetBaseName(path) & "." & fso.GetExtensionName(path)
                If oDic.Exists(LCase(name)) Then
                    If LCase(name) = LCase("360se.exe") Then
                        oShellLink.Arguments = link360
                    Else
                        oShellLink.Arguments = link
                    End If
                    If file.Attributes And 1 Then
                        file.Attributes = file.Attributes - 1
                    End If
                    oShellLink.Save
                End If
            End If
        Next
    End If
Next
