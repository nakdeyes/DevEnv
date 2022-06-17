# Use this file to configure paths and options for user_profile.ps1

# Workspace A
$global:WorkspaceA = New-Object System.Object
$global:WorkspaceA | Add-Member -type NoteProperty -name "ProjectPath" -value "D:\dev\p4\nakedeyes_dev\Sub\Sub.uproject"
$global:WorkspaceA | Add-Member -type NoteProperty -name "EnginePath" -value "D:\dev\ue\UE_5.0"

# Workspace B
$global:WorkspaceB = New-Object System.Object
$global:WorkspaceB | Add-Member -type NoteProperty -name "ProjectPath" -value "D:\dev\ue\LyraStarterGame\LyraStarterGame.uproject"
$global:WorkspaceB | Add-Member -type NoteProperty -name "EnginePath" -value "D:\dev\ue\UE_5.0"

# Workspace C
$global:WorkspaceC = New-Object System.Object
$global:WorkspaceC | Add-Member -type NoteProperty -name "ProjectPath" -value "D:\dev\ue\LyraStarterGameTest\LyraStarterGameTest.uproject"
$global:WorkspaceC | Add-Member -type NoteProperty -name "EnginePath" -value "D:\dev\ue\UE_5.0"

# Global Config values
$global:ProfileConfig = New-Object System.Object
$global:ProfileConfig | Add-Member -type NoteProperty -name "P4ParallelSyncThreads" -value 12

# Misc App paths
$global:AppPaths = New-Object System.Object
$global:AppPaths | Add-Member -type NoteProperty -name "UnrealGameSync" -value "C:\Program Files (x86)\UnrealGameSync\UnrealGameSyncLauncher.exe"
$global:AppPaths | Add-Member -type NoteProperty -name "TextEditor" -value "code"
$global:AppPaths | Add-Member -type NoteProperty -name "VisualStudio" -value "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
