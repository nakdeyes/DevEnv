# Use this file to configure paths and options for user_profile.ps1

# Workspace A
$global:WorkspaceA = New-Object System.Object
$global:WorkspaceA | Add-Member -type NoteProperty -name "ProjectPath" -value "D:\dev\p4\nakedeyes_dev\Sub\Sub.uproject"
$global:WorkspaceA | Add-Member -type NoteProperty -name "EnginePath" -value "D:\dev\ue\UE_5.1"

# Workspace B
$global:WorkspaceB = New-Object System.Object
$global:WorkspaceB | Add-Member -type NoteProperty -name "ProjectPath" -value "D:\dev\ue\LyraStarterGame\LyraStarterGame.uproject"
$global:WorkspaceB | Add-Member -type NoteProperty -name "EnginePath" -value "D:\dev\ue\UE_5.0"

# Workspace C
$global:WorkspaceC = New-Object System.Object
$global:WorkspaceC | Add-Member -type NoteProperty -name "ProjectPath" -value "D:\dev\ue\LyraStarterGame\LyraStarterGame.uproject"
$global:WorkspaceC | Add-Member -type NoteProperty -name "EnginePath" -value "D:\dev\ue\UE_5.0"

# Workspace D
$global:WorkspaceD = New-Object System.Object
$global:WorkspaceD | Add-Member -type NoteProperty -name "ProjectPath" -value "D:\dev\ue\LyraStarterGame\LyraStarterGame.uproject"
$global:WorkspaceD | Add-Member -type NoteProperty -name "EnginePath" -value "D:\dev\ue\UE_5.0"

# Global Config values
$global:ProfileConfig = New-Object System.Object
$global:ProfileConfig | Add-Member -type NoteProperty -name "P4ParallelSyncThreads" -value 12
$global:ProfileConfig | Add-Member -type NoteProperty -name "ShareSourceNetAdapterName" -value "Ethernet 3"
$global:ProfileConfig | Add-Member -type NoteProperty -name "ShareTargetNetAdapterName" -value "Ethernet 4"

# Misc App paths
$global:EnvPaths = New-Object System.Object
$global:EnvPaths | Add-Member -type NoteProperty -name "PowershellEnvGit" -value "D:\dev\git\DevEnv\powershell\ue_dev_env"
$global:EnvPaths | Add-Member -type NoteProperty -name "Rider" -value "C:\Program Files\JetBrains\JetBrains Rider 2022.3.1\bin\rider64.exe"
$global:EnvPaths | Add-Member -type NoteProperty -name "TextEditor" -value "nvim"
$global:EnvPaths | Add-Member -type NoteProperty -name "UnrealGameSync" -value "C:\Program Files (x86)\UnrealGameSync\UnrealGameSyncLauncher.exe"
$global:EnvPaths | Add-Member -type NoteProperty -name "VisualStudio" -value "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
