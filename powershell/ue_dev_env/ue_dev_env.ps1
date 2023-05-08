# Copyright Timothy Rawcliffe
# UE Development Environment powershell script!
#
# To install: 
#   1. Put ue_dev_env.ps1, ue_dev_env_config.ps1 and ue_dev_env.omp.json in the same directory as your user_profile.ps1
#   2. Add this line to user_profile.ps1:   . $PSScriptRoot\ue_dev_env.ps1
#   3. See the config file to setup directories and workspaces for your environment.
#
# Additional notes:
#   * Best if used with Oh My Posh command line below
#   * Font intended for use: CaskaydiaCove NF
#   * CMDER Color Palette at time of creation: Monokai

# Useful fonts and powershell tips - https://www.hanselman.com/blog/my-ultimate-powershell-prompt-with-oh-my-posh-and-the-windows-terminal

# Save off this script and the user profile config path
$script_path            = "$PSScriptRoot\ue_dev_env.ps1"
$script_config_path     = "$PSScriptRoot\ue_dev_env_config.ps1"
$omp_theme_path         = "$PSScriptRoot\ue_dev_env.omp.json"

## Load in config
. "$script_config_path"

## Oh my posh terminal stuff - https://ohmyposh.dev/docs/
# NOTE: For use with CMDER, you must remove a function prompt read only flag in vendor\profile.ps1. - Details here: https://github.com/lukesampson/pshazz/issues/100
function omp_reload
{
    oh-my-posh --init --shell pwsh --config "$omp_theme_path" | Invoke-Expression
}

omp_reload

## Terminal Icons setup - if not installed, install with the following comamnd:
# Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
Import-Module -Name Terminal-Icons

# Replace the cmder prompt entirely with this.
# [ScriptBlock]$CmderPrompt = { 
#     Microsoft.PowerShell.Utility\Write-Host "Dev$WorkspaceLetter " -NoNewLine -ForegroundColor "DarkGreen"
#     Microsoft.PowerShell.Utility\Write-Host (Get-Location)">" -NoNewLine -ForegroundColor "DarkGray"
# }

# Aliases for configs
$BuildSpecs = @(
[PSCustomObject]@{ ID = 'Client'; Aliases = @('c', 'cli', 'client')},
[PSCustomObject]@{ ID = 'Server'; Aliases = @('s', 'serv', 'server')},
[PSCustomObject]@{ ID = 'Editor'; Aliases = @('e', 'ed', 'editor')}
)

$BuildConfigs = @(
[PSCustomObject]@{ ID = 'Debug';        Aliases = @('debug', 'de')},
[PSCustomObject]@{ ID = 'Development';  Aliases = @('development', 'dev')},
[PSCustomObject]@{ ID = 'Shipping';     Aliases = @('shipping', 'ship', 's')},
[PSCustomObject]@{ ID = 'Test';         Aliases = @('test', 'tst', 't')}
)

$BuildPlatforms = @(
[PSCustomObject]@{ ID = 'Win64';        Aliases = @('w', 'win', 'win64')},
[PSCustomObject]@{ ID = 'PS5';          Aliases = @('ps5', 'playstation5')},
[PSCustomObject]@{ ID = 'Linux';        Aliases = @('linux', 'lin', 'l')}
)

$ERR = "*error*"

# return a config ID given some alias
function Get-ID-From-Alias
{
    Param
    (
        [array]     $configTable    = @(),
        [string]    $alias          = "c"
    )

    for ( $i = 0; $i -lt $configTable.count; $i++)
    {
        for ($j = 0; $j -lt $configTable[$i].Aliases.count; $j++)
        {
            if ($alias -ieq $configTable[$i].Aliases[$j])
            {
                return $configTable[$i].ID;
            }
        }
    }

    return $ERR
}

## Set Environment
function dev 
{
    Param
    (
        [string]$workspaceID = "a"
    )

    switch ($workspaceID)
    {
        "a" { $global:CurrentWorkspace = $WorkspaceA }
        "b" { $global:CurrentWorkspace = $WorkspaceB }
        "c" { $global:CurrentWorkspace = $WorkspaceC }
        "d" { $global:CurrentWorkspace = $WorkspaceD }
        default { Write-Host "**Called Dev with unimplemented workspace ID"; return; }
    }

    $env:WRKSPACE_LETTER = "$workspaceID".ToUpper()

    # Set all the paths
    dev_ue_set_paths

    # Navigate to the project home directory
    cd $UE_ProjectDirectory

    p4getworkspacestats  # Get p4 stats, requires dev_ue_set_paths paths and to be in the project dir

    # Minimal stats of new workspace
    stats -minimal:1
}

function dev_ue_set_paths
{
    #(Get-Item $CurrentWorkspace.ProjectPath) | Get-Member

    # cache off relevant directories for workspace
    $global:UE_ProjectName              = (Get-Item $CurrentWorkspace.ProjectPath).BaseName
    $global:UE_ProjectDirectory         = (Get-Item $CurrentWorkspace.ProjectPath).DirectoryName
    $global:UE_EngineScriptsDir         = "$($CurrentWorkspace.EnginePath)\Engine\Build\BatchFiles"
    $global:UE_ProjectDirectoryDrive    = (Get-Item $CurrentWorkspace.ProjectPath).DirectoryName.Substring(0,3)

    # cache off relevant apps for workspace
    $global:UE_UAT              = "$UE_EngineScriptsDir\RunUat.bat"
    $global:UE_BuildScript      = "$UE_EngineScriptsDir\Build.bat"
    $global:UE_Editor           = "$($CurrentWorkspace.EnginePath)\Engine\Binaries\Win64\UnrealEditor.exe"
    $global:UE_Insights         = "$($CurrentWorkspace.EnginePath)\Engine\Binaries\Win64\UnrealInsights.exe"
    $global:UE_BuildTool        = "$($CurrentWorkspace.EnginePath)\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"

    $global:UE_VSSolution = ""
    # check to see if project is inside UE dir or project dir
    if ($($CurrentWorkspace.ProjectPath).Contains($($CurrentWorkspace.EnginePath)))
    {
        # Project is inside engine directory, user should use UE .sln in engine dir
        $global:UE_VSSolution = "$($CurrentWorkspace.EnginePath)\UE5.sln"
    }
    

    if (!(Test-Path -Path $global:UE_VSSolution -PathType Leaf))
    {
        # Project is in it's own directory, use Proejct .sln in project dir
        $global:UE_VSSolution = "$UE_ProjectDirectory\$UE_ProjectName.sln"
    }

    # Kind of a hack. Functions don't pass return code nicely and I want to put the code from function envokations in the OMP cmd line.
    #   init to a reasonable default here and then set this after each import call
    $env:LASTEXITCODE = 0
}

## Print various workspace stats
function stats
{
    Param
    (
        # preset options, will force ON options that are otherwise not on
        [bool]  $detailed       = 0,
        [bool]  $minimal        = 0,

        # individual options that can be turned off/on
        [bool]  $header         = 1,
        [bool]  $workspaceSize  = 0,
        [bool]  $workspaceCL    = 0,
        [bool]  $pendingCLInfo  = 0
    )

    ## Check for presets
    if ($detailed -ne 0)
    {
        $workspaceSize  = 1
        $workspaceCL    = 1
        $pendingCLInfo  = 1
    }

    if ($minimal -ne 0)
    {
        $header         = 0
        $workspaceSize  = 0
        $workspaceCL    = 0
    }

    ## Begin constructing stats string
    $StatsString = ""
    if ($workspaceSize -ne 0)
    {
        $StatsString +=  "           --Workspace Stats-- `r`n"
    }
    $StatsString += "        workspace $($env:WRKSPACE_LETTER): $global:P4_WorkspaceClient (stream: $global:P4_WorkspaceStream) - $global:P4_WorkspaceRoot`r`n"
    $StatsString += "            project: $($CurrentWorkspace.ProjectPath)`r`n"
    $StatsString += "         engine dir: $($CurrentWorkspace.EnginePath)`r`n"

    if ($workspaceSize -ne 0)
    {
        $WorkspaceDirSize = ("{0:N2} GB" -f ((gci -force "$global:P4_WorkspaceRoot" -Recurse -ErrorAction SilentlyContinue| measure Length -Sum).sum / 1Gb))
        $StatsString += "     workspace size: $($WorkspaceDirSize)`r`n"
    }

    if ($workspaceCL -ne 0)
    {
        $WrkspaceCLString = p4cl
        $StatsString += "       workspace CL: $($WrkspaceCLString)`r`n"
    }

    if ($pendingCLInfo -ne 0)
    {
        [string]$DefaultChangesInfoCmd = "p4 opened -c default"
        [string]$DefaultChangesInfoCmdOutput = Invoke-Expression $DefaultChangesInfoCmd 2>&1
        
        $StatsString += "`r`n           --Changelist Stats-- `r`n"
        $StatsString += "         default CL: "
        if ($DefaultChangesInfoCmdOutput -eq $null)
        {
            $StatsString += "                *Empty!*               "
        }
        else
        {
            [int]$DefaultEdit   = [regex]::matches($DefaultChangesInfoCmdOutput, "edit default").count
            [int]$DefaultAdd    = [regex]::matches($DefaultChangesInfoCmdOutput, "add default").count
            [int]$DefaultRemove = [regex]::matches($DefaultChangesInfoCmdOutput, "delete default").count
            $StatsString += ("Pending (edit: {0:d3}, add: {1:d3}, del: {2:d3})" -f $DefaultEdit, $DefaultAdd, $DefaultRemove)
        }
        $StatsString += "`r`n"
        
        [string]$ListChangesCmd = "p4 changes -r -c $($global:P4_WorkspaceClient)"
        Invoke-Expression $ListChangesCmd | ForEach-Object {
            [string]$ChangeStr = $_.ToString()
            [int]$FirstSpaceInd = $ChangeStr.IndexOf(' ')
            [int]$CLNum = $ChangeStr.Substring($FirstSpaceInd, $ChangeStr.IndexOf(' ', $FirstSpaceInd + 1) - $FirstSpaceInd)

            $StatsString += ("  pending CL {0:d6}: " -f $CLNum)

            [string]$CLChangesInfoCmd = "p4 opened -c $CLNum"
            [string]$CLChangesInfoCmdOutput = Invoke-Expression $CLChangesInfoCmd 2>&1
            [int]$CLPendingEdit = [regex]::matches($CLChangesInfoCmdOutput, "edit change").count
            [int]$CLPendingAdd  = [regex]::matches($CLChangesInfoCmdOutput, "add change").count
            [int]$CLPendingDel  = [regex]::matches($CLChangesInfoCmdOutput, "delete change").count

            if (($CLPendingEdit -eq 0) -and ($CLPendingAdd -eq 0) -and ($CLPendingDel -eq 0))
            {
                $StatsString += "                *Empty!*               "
            }
            else
            {
                $StatsString += ("Pending (edit: {0:d3}, add: {1:d3}, del: {2:d3})" -f $CLPendingEdit, $CLPendingAdd, $CLPendingDel)
            }

            [string]$CLSelvedChangesInfoCmd = "p4 describe -s -S $CLNum"
            [string]$CLSelvedChangesInfoCmdOutput = Invoke-Expression $CLSelvedChangesInfoCmd 2>&1

            [int]$CLShelvedEdit = [regex]::matches($CLSelvedChangesInfoCmdOutput, " edit").count
            [int]$CLShelvedAdd  = [regex]::matches($CLSelvedChangesInfoCmdOutput, " add").count
            [int]$CLShelvedDel  = [regex]::matches($CLSelvedChangesInfoCmdOutput, " delete").count

            if (($CLShelvedEdit -gt 0) -or ($CLShelvedAdd -gt 0) -or ($CLShelvedDel -gt 0))
            {
                $StatsString += (" - Shelved (edit: {0:d3}, add: {1:d3}, del: {2:d3})" -f $CLShelvedEdit, $CLShelvedAdd, $CLShelvedDel)
            }

            $StatsString += "`r`n"
        }

    }

    ## Print the stats string to the screen
    echo $($StatsString)
}

function Convert-Size {
    [cmdletbinding()]
    param(
        [validateset("Bytes","KB","MB","GB","TB")]
        [string]$From,
        [validateset("Bytes","KB","MB","GB","TB")]
        [string]$To,
        [Parameter(Mandatory=$true)]
        [double]$Value,
        [int]$Precision = 4
    )

    switch($From) {
        "Bytes" {$value = $Value }
        "KB" {$value = $Value * 1024 }
        "MB" {$value = $Value * 1024 * 1024}
        "GB" {$value = $Value * 1024 * 1024 * 1024}
        "TB" {$value = $Value * 1024 * 1024 * 1024 * 1024}
    }
               
    switch ($To) {
        "Bytes" {return $value}
        "KB" {$Value = $Value/1KB}
        "MB" {$Value = $Value/1MB}
        "GB" {$Value = $Value/1GB}
        "TB" {$Value = $Value/1TB}
    }
               
    return [Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)
}

function Test-CommandExists
{
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = ‘stop’
    try {if(Get-Command $command){RETURN $true}}
    Catch {Write-Host “$command does not exist”; RETURN $false}
    Finally {$ErrorActionPreference=$oldPreference}
} #end function test-CommandExists

function env_install_prereqs()
{
    # # run as admin
    # if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
    # {  
    #     $arguments = "& '" +$myinvocation.mycommand.definition + "'"
    #     Start-Process powershell -Verb runAs -ArgumentList $arguments
    #     Break
    # }

    Write-Host " **** Installing Prereq - OhMyPosh **** "
    winget install JanDeDobbeleer.OhMyPosh
    Write-Host " **** Installing Prereq - Terminal-Icons **** "
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
    Write-Host " **** Installing Prereq - CascadiaCode fonts **** "

    $TempZipDir = "$PSScriptRoot\assets\temp"
    echo "temp zip dir: $TempZipDir"
    Get-ChildItem -Path "$TempZipDir" -Recurse | Remove-Item -force -recurse
    Expand-Archive "$PSScriptRoot\assets\CascadiaCode.zip" -DestinationPath "$TempZipDir"
    sleep 2
    Push-Location "$TempZipDir"
    $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
    foreach ($file in gci *.ttf)
    {
        $fileName = $file.Name
        if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
            echo $fileName
            dir $file | %{ $fonts.CopyHere($_.fullname) }
        }
    }
    cp *.ttf c:\windows\fonts\
    Pop-Location
    Get-ChildItem -Path "$TempZipDir" -Recurse | Remove-Item -force -recurse
    Remove-Item "$TempZipDir" -Force 
}

function env_install_vim()
{
    Write-Host " **** Installing VIM **** "

    ## Scoop
    if (Test-CommandExists "scoop")
    {
        Write-Host "  scoop detected.. skipping.."
    }
    else
    {
        Write-Host "  installing scoop..."
        Invoke-Expression "iwr -useb get.scoop.sh | iex"
    }

    ## git
    if (Test-CommandExists "git")
    {
        Write-Host "  git detected.. skipping.."
    }
    else
    {
        Write-Host "  installing git..."
        Invoke-Expression "scoop install git"
    }

    ## Neovim
    if (Test-CommandExists "nvim")
    {
        Write-Host "  nvim detected.. skipping.."
    }
    else
    {
        Write-Host "  installing nvim..."
        Invoke-Expression "scoop install neovim"
    }

    ## Yarn
    if (Test-CommandExists "yarn")
    {
        Write-Host "  yarn detected.. skipping.."
    }
    else
    {
        Write-Host "  installing yarn..."
        Invoke-Expression "scoop install yarn"
    }

    ## NodeJS (for Coc nvim plugin)
    if (Test-CommandExists "node")
    {
        Write-Host "  node detected.. skipping.."
    }
    else
    {
        Write-Host "  installing node..."
        Invoke-Expression "scoop install nodejs"
    }

    ## Neovim plug ins
    Write-Host "  installing nvim plugin manager..."
    Invoke-Expression "curl -fLo $($env:USERPROFILE)/scoop/apps/neovim/0.8.1/share/nvim/runtime/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

    ## Invoke installation of neovim plug-ins (requires init.vim to be present to do much)
    Write-Host "  installing nvim plugin manager..."
    Invoke-Expression "nvim -c PlugInstall"
}

## Profile Maintanence
function env_script_edit
{
    . $EnvPaths.TextEditor $script_path
}

function env_config_edit
{
    . $EnvPaths.TextEditor $script_config_path
}

function env_omp_edit
{
    . $EnvPaths.TextEditor $omp_theme_path
}

function env_script_reload
{
    echo ". $PROFILE"
    . $PROFILE
}

function env_script_git_pull
{
    [string]$script_dir = $script_path.Substring(0, $script_path.LastIndexOf('\'))
    [string]$Cmd = "cp $($EnvPaths.PowershellEnvGit)\ue_dev_env.ps1 $script_dir"
    Write-Output " copy git script to local folder.. command: $Cmd"
    Invoke-Expression $Cmd
}

function env_script_git_push
{
    [string]$Cmd = "cp $script_path $($EnvPaths.PowershellEnvGit)"
    Write-Output " copy local script to git folder.. command: $Cmd"
    Invoke-Expression $Cmd
}

## UE stuff - Building
function vs_gen 
{
    # Just use GenerateProjectFiles.bat
    # $GenProjBat = "$($CurrentWorkspace.EnginePath)\Engine\Build\BatchFiles\GenerateProjectFiles.bat"
    # $GenerateCommand = ". $($GenProjBat) $($CurrentWorkspace.ProjectPath) -rocket -progress"

    # Generate commands with Unreal Build Tool. Works great, but not if it isn't compiled yet :D
    $GenerateCommand = ". $global:UE_BuildTool -projectfiles -project=$($CurrentWorkspace.ProjectPath) -game -engine -rocket -progress"

    echo " generate project files command: $GenerateCommand"
    Invoke-Expression $GenerateCommand

    dev_ue_set_paths
}

function build
{
    Param
    (
        [string]$buildSpec      = "ed",
        [string]$buildConfig    = "dev"
    )

    $BuildConfigID = Get-ID-From-Alias $BuildConfigs $buildConfig
    if ($BuildConfigID -ieq $ERR)
    {
        Write-Host " !!! build given a config it does not understand ('$buildConfig'). Doing Nothing! Please select 'dev', 'test', 'ship' or some other supported build config."
        return
    }
    
    $BuildSpecID = Get-ID-From-Alias $BuildSpecs $buildSpec
    if ($BuildSpecID -ieq $ERR)
    {
        Write-Host " !!! build given a spec it does not understand ('$buildSpec'). Doing Nothing! Please select 'client', 'editor', 'server' or some other supported build spec."
        return
    }
    
    # Should match the name of the *.Target.cs to use to build.
    $BuildProjectName = ""
    switch ($BuildSpecID)
    {
        "Client" { $BuildProjectName = $UE_ProjectName }
        "Editor" { $BuildProjectName = "$($UE_ProjectName)Editor" }
        "Server" { $BuildProjectName = "$($UE_ProjectName)Server" }
        default { Write-Host "**HOW DID YOU GET HERE?!"; return; }
    }

    $BuildCommand = ". $UE_BuildScript $BuildProjectName Win64 $BuildConfigID $($CurrentWorkspace.ProjectPath) -waitmutex"

    Microsoft.PowerShell.Utility\Write-Host "    BUILD: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "$BuildSpecID - $BuildConfigID" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "  command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$BuildCommand'" -ForegroundColor "Cyan"

    Invoke-Expression -Command $BuildCommand
    $env:LASTEXITCODE = $global:LASTEXITCODE
    #Start-Process -FilePath "$UE_BuildScript" -ArgumentList "$BuildProjectName Win64 $BuildSpecID $($CurrentWorkspace.ProjectPath) -waitmutex" -NoNewWindow -Wait -PassThru
}

function buildShaderCompilerWorker
{
    $BuildCommand = ". $UE_BuildScript ShaderCompileWorker Win64 Development"

    Microsoft.PowerShell.Utility\Write-Host "    BUILD: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "$BuildSpecID - $BuildConfigID" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "  command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$BuildCommand'" -ForegroundColor "Cyan"

    Invoke-Expression -Command $BuildCommand
    $env:LASTEXITCODE = $global:LASTEXITCODE
}

function buildUEInsights
{
    $BuildCommand = ". $UE_BuildScript UnrealInsights Win64 Development"

    Microsoft.PowerShell.Utility\Write-Host "    BUILD: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "$BuildSpecID - $BuildConfigID" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "  command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$BuildCommand'" -ForegroundColor "Cyan"

    Invoke-Expression -Command $BuildCommand
    $env:LASTEXITCODE = $global:LASTEXITCODE
}

function cook
{
    Param
    (
        [string]$buildSpec      = "cli",
        [string]$buildConfig    = "dev",
        [bool]  $iterative      = 1
    )

    $BuildConfigID = Get-ID-From-Alias $BuildConfigs $buildConfig
    if ($BuildConfigID -ieq $ERR)
    {
        Write-Host " !!! Cook given a config it does not understand ('$buildConfig'). Doing Nothing! Please select 'dev', 'test', 'ship' or some other supported build config."
        return
    }
    
    $BuildSpecID = Get-ID-From-Alias $BuildSpecs $buildSpec
    if ($BuildSpecID -ieq $ERR)
    {
        Write-Host " !!! Cook given a spec it does not understand ('$buildSpec'). Doing Nothing! Please select 'client', 'server' or some other supported build spec."
        return
    }
    if ($BuildSpecID -ieq "Editor")
    {
        Write-Host " !!! Cooking for the editor as a spec is not really supported. Try 'client' or 'server' "
        return
    }

    # Different configs require slightly different args, so tweak those here. 
    switch ($BuildSpecID)
    {   
        "Client" { $ConfigSpecificArgs = "-platform=Win64 -clientconfig=$BuildConfigID" }
        "Server" { $ConfigSpecificArgs = "-targetplatform=Win64 -target=`"$($UE_ProjectName)Server`" -serverconfig=`"$BuildConfigID`" -nocompileeditor" }
        default { Write-Host "**HOW DID YOU GET HERE?!"; return; }
    }

    if ($iterative -eq 1)
    {
        $ConfigSpecificArgs = $ConfigSpecificArgs + " -iterativecooking"
    }

    $CookCommand = ". $UE_UAT BuildCookRun -project=$($CurrentWorkspace.ProjectPath) -noP4 -unattended $ConfigSpecificArgs -cook"

    Microsoft.PowerShell.Utility\Write-Host "     COOK: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "$BuildSpecID - $BuildConfigID" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "  command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$CookCommand'" -ForegroundColor "Cyan"

    Invoke-Expression $CookCommand
}

function run
{
    Param
    (
        [string]$buildSpec      = "cli",
        [string]$buildConfig    = "dev",
        [string]$map            = "",
        [bool]$useInsights      = 0,
        [bool]$replay           = 0,
        [bool]$clientConnect    = 1,
        [bool]$log              = 1
    )

    $BuildConfigID = Get-ID-From-Alias $BuildConfigs $buildConfig
    if ($BuildConfigID -ieq $ERR)
    {
        Write-Host " !!! run given a config it does not understand ('$buildConfig'). Doing Nothing! Please select 'dev', 'test', 'ship' or some other supported build config."
        return
    }
    $BuildSpecID = Get-ID-From-Alias $BuildSpecs $buildSpec
    if ($BuildSpecID -ieq $ERR)
    {
        Write-Host " !!! run given a spec it does not understand ('$buildSpec'). Doing Nothing! Please select 'client', 'server' or some other supported build spec."
        return
    }

    switch ($BuildSpecID)
    {   
        "Client" { 
            $ConfigRunCommand = "$($UE_ProjectName).exe $($map)"
            
            if ($clientConnect -eq 1)
            {
                $ConfigRunCommand = $ConfigRunCommand + " 127.0.0.1 ? service_uri=premium.firewalkcloud.com"
            }
            $ConfigRunCommand = $ConfigRunCommand + " -WINDOWED -ResX=1280 -ResY=720 -WinX=0 -WinY=30"
        }
        "Server" { $ConfigRunCommand = "$($UE_ProjectName)Server.exe" }
        "Editor" {

            $ConfigRunCommand = "UnrealEditor.exe"
            Invoke-Expression "$($global:UE_Editor) $($global:UE_ProjectName)"
            return  # editor is pretty bespoke so just launch it from here
        }
        default { Write-Host "**HOW DID YOU GET HERE?!"; return; }
    }

    $RunCommand = ". $($UE_ProjectDirectory)\Binaries\Win64\$($ConfigRunCommand)"
    if ($log -eq 1)
    {
        $RunCommand = $RunCommand + " -log"
    }

    if ($useInsights -eq 1)
    {
        #$RunCommand = $RunCommand + " -trace=`"cpu,frame,bookmark,memory,loadtime`" -statnamedevents -loadtimetrace -tracehost=127.0.0.1"
        $RunCommand = $RunCommand + " -trace=`"cpu,frame,bookmark`" -statnamedevents -tracehost=127.0.0.1"
    }

    if ($replay -eq 1)
    {
        $RunCommand = $RunCommand + " -pmreplay"
    }

    Microsoft.PowerShell.Utility\Write-Host "      RUN: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "$BuildSpecID - $BuildConfigID" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "  command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$RunCommand'" -ForegroundColor "Cyan"

    Invoke-Expression $RunCommand
}

function package
{
    Param
    (
        [string]$spec           = "cli",
        [string]$config         = "dev",
        [string]$platform       = "win64",
        [string]$archivePath    = "",
        [bool]  $iterativeCook  = 1
    )

    $ConfigID = Get-ID-From-Alias $BuildConfigs $config
    if ($ConfigID -ieq $ERR)
    {
        Write-Host " !!! Package given a config it does not understand ('$config'). Doing Nothing! Please select 'dev', 'test', 'ship' or some other supported build config."
        return
    }
    
    $SpecID = Get-ID-From-Alias $BuildSpecs $spec
    if ($SpecID -ieq $ERR)
    {
        Write-Host " !!! Package given a spec it does not understand ('$spec'). Doing Nothing! Please select 'client', 'server' or some other supported build spec."
        return
    }
    if ($SpecID -ieq "Editor")
    {
        Write-Host " !!! Packing for the editor as a spec is not really supported. Try 'client' or 'server' "
        return
    }

    $PlatformID = Get-ID-From-Alias $BuildPlatforms $platform
    if ($SpecID -ieq $ERR)
    {
        Write-Host " !!! Package given a platform it does not understand ('$platform'). Doing Nothing! Please select 'win', 'ps5', 'linux' or some other supported platform."
        return
    }

    [string]$ConfigSpecificArgs = ""
    if ($iterative -eq 1)
    {
        $ConfigSpecificArgs = $ConfigSpecificArgs + " -iterativecooking"
    }

    ##WINDOW_SPEW_CMND_EXE=$(printf "%q/RunUAT.bat BuildCookRun -project=\"%s\" -noP4 -unattended -build -platform=\"XSX\" -clientconfig=\"Development\" -nocompileeditor -cook -cookflavor=multi -stage -pak -package -deploy -archive -archivedirectory=\"%s\"" "$UEBUILDSCRIPTSPATH" "$WIN_UE_PROJ_PATH" "$WIN_BuildDirName")
    $PackageCommand = ". $UE_UAT BuildCookRun -project='$($CurrentWorkspace.ProjectPath)' -noP4 -unattended -build -platform='$($PlatformID)' -clientconfig=$($ConfigID) -nocompileeditor -cook -cookflavor=multi $ConfigSpecificArgs -stage -pak -package -archive -archivedirectory='$($archivePath)'"

    Microsoft.PowerShell.Utility\Write-Host "      package: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "$PlatformID - $SpecID - $ConfigID -> $archivePath" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "      command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$PackageCommand'" -ForegroundColor "Cyan"

    Invoke-Expression $PackageCommand
}

function make_installed_build
{
    $BuildCommand = ". $UE_UAT BuildGraph -target=`"Make Installed Build Win64`" -script=`"Engine/Build/InstalledEngineBuild.xml`" -set:WithFullDebugInfo=true -UNATTENDED -set:WithDDC=false -set:SignExecutables=false -VS2019"
    Write-Host "    make installed build command: '$BuildCommand'"

    Invoke-Expression $BuildCommand
}

function package_client
{
    . $UE_UAT BuildCookRun -project="$($CurrentWorkspace.ProjectPath)" -build -targetplatform=Win64 -cook -stage -clientconfig=Development
}

function package_server
{
    . $UE_UAT BuildCookRun -nop4 -project="$($CurrentWorkspace.ProjectPath)" -cook -stage -pak -prereqs -targetplatform=Win64 -build -CrashReporter -target=FWChaosServer -serverconfig=Development -utf8output -compile
}

## UE Stuff - launching
function vs
{
    . $EnvPaths.VisualStudio $UE_VSSolution
}

function rider
{
    . $EnvPaths.Rider $UE_VSSolution
}

function ueInsights
{
    . $UE_Insights
}

function ueCommandlet
{
    # Could upgrade to this approach if we want the output to not go to it's own window that auto-closes
    Param
    (
        [string]$commandlet    = "*none*"
    )

    if ($commandlet -eq "*none*")
    {
        Write-Output " ueCommandlet did not detect a valid commandlet name. Please supply a valid commandlet name as a parameter to this function."
        return
    }
    [string]$commandletExpression = ". $($global:UE_Editor) $($global:UE_ProjectName) -run=$($commandlet) | Out-Null"
    Write-Output "  Running Commandlet '$($commandlet)' with expression: '$($commandletExpression)'"
    Invoke-Expression $commandletExpression
}

# Open Unreal Game Sync, should open from project directory to pick up P4 Config stuff
function ugs
{
    . $EnvPaths.UnrealGameSync
}

## Perforce stuff

# Get current p4 cl
function p4cl
{
    p4 changes -m1 //...#have
}

function p4clean
{
    $Command = "p4 clean -ade -I"

    Microsoft.PowerShell.Utility\Write-Host " p4clean - command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$Command'" -ForegroundColor "Cyan"

    Invoke-Expression -Command $Command
    $env:LASTEXITCODE = $global:LASTEXITCODE
}

function p4getworkspacestats
{
    Param
    (
        [bool]  $verbose = 0
    )
    
    ### Get Client Name
    $global:P4_WorkspaceClient = p4 -Ztag -F %clientName% info

    ## Check Login Status, ask to login if not logged in
    $LoginStatusOutput = p4 login -s 2>&1 | Out-String
    if ( -not($LoginStatusOutput -like "*ticket expires*")) # looking for part of success string "user xxx logged in and ticket expires in YY mins"
    {
        echo " Not logged into perfoce client associated with '$global:P4_WorkspaceClient' Please enter password"
        p4login
    }

    ### Get Workspace root
    $WorkspaceCommandOutput = p4 where //... | Out-String
        
    $DriveNameStringInd = $WorkspaceCommandOutput.IndexOf($global:UE_ProjectDirectoryDrive)
    $ReturnCharStringInd = $WorkspaceCommandOutput.IndexOf("\...", $DriveNameStringInd)
    $global:P4_WorkspaceRoot = $WorkspaceCommandOutput.Substring($DriveNameStringInd, ($ReturnCharStringInd - $DriveNameStringInd))

    ### Get workspace stream
    $global:P4_WorkspaceStream = p4 -F "%Stream%" -ztag client -o | Out-String
    if ($global:P4_WorkspaceStream.Length -gt 3)
    {
        $global:P4_WorkspaceStream = $global:P4_WorkspaceStream.Substring(0,$global:P4_WorkspaceStream.Length - 2) ## Cut trailing return char
    }
    

    if ($verbose -ne 0)
    {
        echo "  p4 workspace root: $global:P4_WorkspaceRoot"
        echo "          p4 client: $global:P4_WorkspaceClient" 
    }
}

# sync to a supplied CL, or to latest if none is supplied
function p4sync
{
    Param
    (
        [string]$changelist     = "",
        [bool]  $reportSyncedCL = 1
    )

    $SyncCommand = ". p4 sync --parallel=threads=$($ProfileConfig.P4ParallelSyncThreads) //..."
    if ($changelist -eq "")
    {
        Write-Host "  Sync to latest CL"
        # $SyncCommand = "$($SyncCommand) "
    }
    else {
        Write-Host "  Sync to CL ${changelist}"
        $SyncCommand = "$($SyncCommand)@$($changelist)"
    }

    Write-Host "    sync command: '$SyncCommand'"
    Invoke-Expression $SyncCommand

    if ($reportSyncedCL -ne 0)
    {
        Write-Host " FINISHED! Synced to CL: "
        p4cl
    }
    else {
        Write-Host " FINISHED!"
    }
}

function p4login
{
    p4 login
}

# A very specific function to find - what is the newest changelist with a purged file? This helps you find out
# how far back in time you can go given a workspace with +S revisions history
function p4NewestPurged
{
    Param
    (
        [string]$p4Path     = "//chaos/main/Unreal/...",
        [string]$match_pattern = "purge change",
        [string]$not_match_pattern = "BuiltData|Subtitles|ContentSource",
        [int]$debugSpew = 0
    )

    #init
    [int]$matchPatternLen = $match_pattern.Length + 1
    [int]$newestPurgedCL = 0
    [string]$newestPurgedFileInfo = ""
    [int]$filecounter = 0

    [string]$P4Command = "p4 files -a $($p4Path)"
    Write-Output "Running Expression: '$($P4Command)' - include '$($match_pattern)' - exclude '$($not_match_pattern)'"
    Invoke-Expression $P4Command | Select-String -Pattern $match_pattern | Select-String -Pattern $not_match_pattern -NotMatch | ForEach-Object { 
        $filecounter = $filecounter + 1
        [string]$foundString = $_.ToString()
        [int]$purgeChangeInd = $foundString.IndexOf($match_pattern) + $matchPatternLen
        [int]$nextSpace = $foundString.IndexOf(" ", $purgeChangeInd)
        [int]$Changelist = $foundString.Substring($purgeChangeInd, $nextSpace - $purgeChangeInd)
        [bool]$newest = ($newestPurgedCL -lt $Changelist)
        if ($newest)
        {
            $newestPurgedCL = $Changelist
            $newestPurgedFileInfo = $foundString
        }

        if ($newest)
        {
            Write-Output "newest purged file $($filecounter) - CL '$($Changelist)' - $($foundString)" 
        }
        elseif ($debugSpew)
        {
            Write-Output "              file $($filecounter) - CL '$($Changelist)' - $($foundString)" 
        }
    }

    Write-Output ""
    Write-Output " Newest file CL with Purged file - CL# $($newestPurgedCL) "
    Write-Output " File Info:"
    Write-Output "      $($newestPurgedFileInfo)"
    Write-Output " CL# $($newestPurgedCL) Info:"
    Invoke-Expression "p4 describe -s $($newestPurgedCL)"
}

# A function to add or remove filetype flags on many files in bulk. 
function p4BulkChangefiletype
{
    Param
    (
        # The P4 path of files to look at
        [string]$p4Path     = "//chaos/main/Unreal/...",

        # Extra match / not match patterns that can be used to select files
        [string]$match_pattern = " ",
        [string]$not_match_pattern = "BuiltData|Subtitles|ContentSource",

        # The file type pattern of files to change filetype
        [string]$filetype_match_pattern = "S",

        # The new file type
        [string]$new_filetype = "binary+l",

        # Spew shelved changes if enabled
        [int]$spew_shelved = 0,

        # Spew checked out files if enabled
        [int]$spew_checked_out = 0,

        # Flag to actually request the file type change (else will just print)
        [int]$do_filetype_change = 0,

        # Verbose output spew for debugging and verbose info.
        [int]$verbose = 0
    )

    # Get existing filetype ( parse from last paren)
    # p4 files //Chaos/main/Unreal/Chaos/Content/Berserker_3P_Looping_01_AM.uasset

    #init
    [int]$filecounter = 0
    [int]$correct_filetype_counter = 0
    [int]$successful_edit_counter = 0
    [int]$shelved_file_counter = 0
    [int]$checked_out_file_counter = 0

    [string]$P4Command = "p4 files -e $($p4Path)"

    Write-Output ""
    Write-Output " P4 Bulk File type change"
    Write-Output "      **          Expression: '$($P4Command)'"
    Write-Output ""
    Write-Output "      ** File Include Filter: '$($match_pattern)'"
    Write-Output "      ** File Exclude Filter: '$($not_match_pattern)'"
    Write-Output ""
    Write-Output "      **    file type filter: '$($filetype_match_pattern)'"
    Write-Output "      **       new file type: '$($new_filetype)'"

    if ($do_filetype_change)
    {
        Write-Output ""
        Write-Output "      **      --- DOING FILE TYPE CHANGE! ---"
    }
    else
    {
        Write-Output ""
        Write-Output "      **      --- not changing files.. run with '-do_filetype_change:1' to change file type! ---"
    }
    
    if ($spew_shelved)
    {
        Write-Output ""
        Write-Output "      **      --- spew Shelved ENABLED ---"
    }

    if ($verbose)
    {
        Write-Output ""
        Write-Output "      **      --- verbose ENABLED ---"
    }
    Write-Output ""
    Write-Output ""

    Invoke-Expression $P4Command | Select-String -Pattern $match_pattern | Select-String -Pattern $not_match_pattern -NotMatch | ForEach-Object { 
        
        $filecounter = $filecounter + 1
        [string]$fullFileString = $_.ToString()
        [string]$fileNameString = $fullFileString.Substring(0, $fullFileString.IndexOf('#'))
        [int]$lastParenCloseInd = $fullFileString.LastIndexOf(')')
        [int]$lastParenOpenInd = $fullFileString.LastIndexOf('(', $lastParenCloseInd)
        [string]$filetypeStr = $fullFileString.Substring($lastParenOpenInd+1, $lastParenCloseInd - $lastParenOpenInd - 1)

        [int]$fileTypeMatchInd = $filetypeStr.IndexOf($filetype_match_pattern)
        [bool]$filetypeMatches = ($fileTypeMatchInd -ge 0 )

        if ($filetypeMatches)
        {
            $correct_filetype_counter = $correct_filetype_counter + 1

            if ($spew_shelved)
            {
                [string]$p4ShelvedChangesCommand = "p4 changes -s shelved $($fileNameString)"
                [string]$shelved_output = Invoke-Expression $p4ShelvedChangesCommand

                [bool]$any_shelved = ($shelved_output.IndexOf("Change") -ge 0)

                if ($any_shelved)
                {
                    $shelved_file_counter = $shelved_file_counter + 1
                }

                if ($any_shelved -or $verbose)
                {
                    Write-Output "    SHELVED CHANGES FOUND: $($any_shelved) - Total Files: $($shelved_file_counter) - File: $($fileNameString)"
                }
            }

            if ($spew_checked_out)
            {
                [string]$p4CheckedOutChangesCommand = "p4 changes -s pending $($fileNameString)"
                [string]$p4CmdOutput = Invoke-Expression $p4CheckedOutChangesCommand

                [bool]$any_checked_out = ($p4CmdOutput.IndexOf("Change") -ge 0)

                if ($any_checked_out)
                {
                    $checked_out_file_counter = $checked_out_file_counter + 1
                }

                #if ($any_checked_out -or $verbose)
                #{
                    Write-Output "     CHECKED OUT CHANGES FOUND: $($any_checked_out) - Total Files: $($checked_out_file_counter) - File: $($fileNameString)"
                    Write-Output "         checked out, output: $($p4CmdOutput)"
                #}
            }

            if ($do_filetype_change)
            {
                [string]$p4EditCommand = "p4 edit -t $($new_filetype) '$($fileNameString)'"
                [string]$editCmdOutput = Invoke-Expression $p4EditCommand 2>&1
                [bool]$commandSucceeded = ($editCmdOutput.IndexOf("opened for edit") -ge 0)
                
                if ($commandSucceeded)
                {
                    $successful_edit_counter = $successful_edit_counter + 1
                }
                
                #if ($verbose -or ($editCmdOutput -eq "") -or !$commandSucceeded)
                if ($verbose)
                {
                    Write-Output "    doing edit cmd: '$($p4EditCommand)'"
                    Write-Output "   edit cmd output: $($editCmdOutput)"
                    Write-Output "      edit success: $($commandSucceeded)"
                }
                elseif (!$commandSucceeded -or ($editCmdOutput -eq ""))
                {
                    Write-Output "     check out failed.. output: $($editCmdOutput)"
                }
            }
        }

        if ($verbose)
        {
            Write-Output " file $($filecounter) - type: '$($filetypeStr)' match? $($filetypeMatches) - filename: $($fileNameString)"
            Write-Output "      full file string: '$($fullFileString)'" 
        }
    }

    Write-Output ""
    Write-Output "    FINISHED"
    Write-Output ""
    Write-Output "   Found $($filecounter) files. Of those files, $($correct_filetype_counter) of those files matched file type filter '$($filetype_match_pattern)'"
    if ($spew_shelved)
    {
        Write-Output ""
        Write-Output "              Shelved file check.. has shelved changes: $($shelved_file_counter) / $($correct_filetype_counter)"
    }
    Write-Output ""
    Write-Output "             Successful attempted file edits: $($successful_edit_counter) / $($correct_filetype_counter)"
    Write-Output ""

    if ($do_filetype_change)
    {
        Write-Output "   DO FILE TYPE CHANGE ENABLED - edited $($correct_filetype_counter) files and changed file type to '$($new_filetype)'"
        Write-Output ""
    }
    else
    {
       Write-Output "      **      --- run with '-do_filetype_change:1' to change file type! ---"
        Write-Output ""
    }
}

function p4GetAverageRevisionSize
{
    Param
    (
        [string]$p4Path     = "",
        [int]$debugSpew     = 0
    )

    # look up count of non-purged revisions, get server size of all non-purged revisions, divide!
    [string]$P4Command = "p4 sizes -a -z $($p4Path)"
    [string]$CommandOutput = Invoke-Expression $P4Command

    [long]$filesInd = $CommandOutput.LastIndexOf("files")
    [long]$prevSpace = $CommandOutput.LastIndexOf(" ", $filesInd - 2)
    [long]$bytesInd = $CommandOutput.LastIndexOf("bytes")

    [long]$filecount = $CommandOutput.Substring($prevSpace + 1, $filesInd - $prevSpace - 2)
    [long]$totalsize = $CommandOutput.Substring($filesInd + 6, $bytesInd - $filesInd - 7)

    if ($filecount -eq 0)
    {
        if ($debugSpew)
        {
            Write-Host " ZERO FILE COUNT FOR FILE Estimating filesize for: $($p4Path) "
            Write-Host " - output: $($CommandOutput)"
            Write-Host " - file count: '$($filecount)' revisions"
            Write-Host " - total size: '$($totalsize)' bytes"
        }

        Write-Output 0
        return
    }

    [long]$averagesize = $totalsize / $filecount

    if ($debugSpew)
    {
        Write-Host "Estimating filesize for: $($p4Path) "
        Write-Host " - output: $($CommandOutput)"
        Write-Host " - file count: '$($filecount)' revisions"
        Write-Host " - total size: '$($totalsize)' bytes"
        Write-Host " - avrge size: '$($averagesize)' bytes"
    }

    Write-Output $averagesize
}

function p4EstimatePurged
{
    Param
    (
        [string]$p4Path     = "//Chaos/main/...",
        [string]$p4RevisionSel = "@2022/03/01,2022/08/01",
        [string]$match_pattern = "purge change",
        [string]$not_match_pattern = "ContentSource",
        [int]$debugSpew = 0
    )

    [string]$P4Command = "p4 sizes -a -z $($p4Path)$($p4RevisionSel)"

    Write-Output " Looking at files '$($p4Path)' across Revisions '$($p4RevisionSel)'"
    Write-Output ""
    Write-Output ""
    Write-Output "     Server sizes w/ purges estimated with command '$($P4Command)'"
    Write-Output ""
    [string] $UnpurgedSizeOutput = Invoke-Expression $P4Command
    #Write-Output "$UnpurgedSizeOutput"

    [long]$filesInd = $UnpurgedSizeOutput.LastIndexOf("files")
    [long]$prevSpace = $UnpurgedSizeOutput.LastIndexOf(" ", $filesInd - 2)
    [long]$bytesInd = $UnpurgedSizeOutput.LastIndexOf("bytes")

    [long]$UnpurgedRevisionCount = $UnpurgedSizeOutput.Substring($prevSpace + 1, $filesInd - $prevSpace - 2)
    [long]$UnpurgedSize = $UnpurgedSizeOutput.Substring($filesInd + 6, $bytesInd - $filesInd - 7)

    [string]$UnpurgedSizeMB = Convert-Size -From Bytes -To MB $($UnpurgedSize) -Precision 2
    [string]$UnpurgedSizeGB = Convert-Size -From Bytes -To GB $($UnpurgedSize) -Precision 2

    Write-Output "   Unpurged Revision Count: '$($UnpurgedRevisionCount)' - file size: $($UnpurgedSize) Bytes"
    Write-Output ""
    Write-Output ""
    
    $P4Command = "p4 files -a $($p4Path)$($p4RevisionSel)"
    Write-Output "     Gathering all revisions in range with command '$($P4Command)'"
    Write-Output ""

    $RevisionsHash = @{}

    [long]$PurgedRevisionCount = 0
    Invoke-Expression $P4Command | Select-String -Pattern $match_pattern | Select-String -Pattern $not_match_pattern -NotMatch | ForEach-Object {
        $PurgedRevisionCount = $PurgedRevisionCount + 1
        [string]$foundString = $_.ToString()

        [string]$assetName = $foundString.Substring(0, $foundString.IndexOf("#"))

        if ($RevisionsHash.ContainsKey($assetName))
        {
            $RevisionsHash[$assetName].purgedRevs = $RevisionsHash[$assetName].purgedRevs + 1
        }
        else
        {
            $RevisionsHash[$assetName] = @{}
            $RevisionsHash[$assetName].purgedRevs = 1
            $RevisionsHash[$assetName].averageSize = Invoke-Expression "p4GetAverageRevisionSize -p4Path:$($assetName) -debugSpew:$($debugSpew)"
        }

        if ($debugSpew)
        {
            Write-Output "          rev: $($foundString)"
            Write-Output "   asset name: $($assetName)"
            Write-Output "  purged revs: '$($RevisionsHash[$assetName].purgedRevs)'"
            Write-Output " average size: '$($RevisionsHash[$assetName].averageSize)'"
        }
    }
    
    [long] $PurgedEstimatedSize = 0
    foreach ($RevisionSet in $RevisionsHash.GetEnumerator() )
    {
        $PurgedEstimatedSize = $PurgedEstimatedSize + ($RevisionSet.Value.purgedRevs * $RevisionSet.Value.averageSize)
        if ($debugSpew)
        {
            Write-Host "purged revs: $($RevisionSet.Value.purgedRevs) - average size: $($RevisionSet.Value.averageSize) - file: $($RevisionSet.Name)"
            Write-Host "  running estimate total: $($PurgedEstimatedSize) Bytes"
        }
    }

    [string]$PurgedSizeMB = Convert-Size -From Bytes -To MB $($PurgedEstimatedSize) -Precision 2
    [string]$PurgedSizeGB = Convert-Size -From Bytes -To GB $($PurgedEstimatedSize) -Precision 2

    [long]$TotalRevisions = $UnpurgedRevisionCount + $PurgedRevisionCount
    [long]$TotalSize = $UnpurgedSize + $PurgedEstimatedSize
    [string]$TotalSizeMB = Convert-Size -From Bytes -To MB $($TotalSize) -Precision 2
    [string]$TotalSizeGB = Convert-Size -From Bytes -To GB $($TotalSize) -Precision 2

    
    Write-Output " Found $($PurgedRevisionCount) purged revisions estimated at $($PurgedEstimatedSize) Bytes on files '$($p4Path)$($p4RevisionSel)'"

    Write-Output ""
    Write-Output ""
    Write-Output ""
    Write-Output " FINAL RESULTS for files '$($p4Path)' in range '$($p4RevisionSel)'"
    Write-Output ""
    Write-Output ""
    Write-Output "     UNPURGED (Actual size)"
    Write-Output "          Revisions: $($UnpurgedRevisionCount)"
    Write-Output "               Size: ($($UnpurgedSizeGB) GB)   ($($UnpurgedSizeMB) MB)   ($($UnpurgedSize) Bytes)"
    Write-Output ""
    Write-Output "     PURGED (Estimated size)"
    Write-Output "          Revisions: $($PurgedRevisionCount)"
    Write-Output "               Size: ($($PurgedSizeGB) GB)   ($($PurgedSizeMB) MB)   ($($PurgedEstimatedSize) Bytes)"
    Write-Output ""
    Write-Output "      TOTAL (Actual + Estimated size)"
    Write-Output "          Revisions: $($TotalRevisions)"
    Write-Output "               Size: ($($TotalSizeGB) GB)   ($($TotalSizeMB) MB)   ($($TotalSize) Bytes)"



    ## Iterate over all files from p4path
    ## Look at all revisions in RevisionSel
    ## If not purged files: just do p4 sizes -a -z on files and add together
    ## If a purged file is found: Find average of each delta for non-purged and add in estimated per revision * num revisions purged
}

function p4DepotSize
{
    Param
    (
        [string]$p4Path     = "//chaos/main/Unreal/...",
        [int]$allrevisions  = 0,
        [int]$server_size   = 0,
        [int]$debugSpew     = 0
    )

    # init
    [uint64]$TotalBytes = 0
    [uint64]$TotalRevisions = 0

    # create command
    [string]$P4Command = "p4 sizes"
    if ($server_size -ne 0)
    {
        $P4Command = $P4Command + " -z"
    }
    else 
    {
        $P4Command = $P4Command + " -s"
    }

    if ($allrevisions -ne 0)
    {
        $P4Command = $P4Command + " -a"
    }
    $P4Command = $P4Command + " $($p4Path)"
    
    Write-Output "Running Expression: '$($P4Command)'"
    Invoke-Expression $P4Command | ForEach-Object {
        [string]$OutputStr = $_.ToString()
        [int]$bytesInd = $OutputStr.LastIndexOf("bytes")
        [int]$bytesNumStartInd = $OutputStr.LastIndexOf(" ", $bytesInd - 2)
        $TotalBytes = [uint64]$OutputStr.Substring($bytesNumStartInd, ($bytesInd - $bytesNumStartInd))

        [int]$filesInd = $OutputStr.LastIndexOf("files")
        [int]$filesNumStartInd = $OutputStr.LastIndexOf(" ", $filesInd - 2)
        $TotalRevisions = [uint64]$OutputStr.Substring($filesNumStartInd, ($filesInd - $filesNumStartInd))
    }

    Write-Output ""
    [string]$SizeMB = Convert-Size -From Bytes -To MB $($TotalBytes) -Precision 2
    [string]$SizeGB = Convert-Size -From Bytes -To GB $($TotalBytes) -Precision 2
    Write-Output ""
    Write-Output " Revisions Counted: $TotalRevisions .. Bytes Counted: $TotalBytes .. $SizeMB MB .. $SizeGB GB"
}

## PS5 stuff
function PS5Deploy
{
    Param
    (
        [int]$buildNum   = 0
    )

    # Need to run the script out of it's own directory
    [string] $script_dir = "$global:P4_WorkspaceRoot\Tools\Bin\WorkflowTools\Propper\PS5DeployTool"
    Write-Host "Deploy PS5 build # $buildNum ... "
    Push-Location $script_dir
    ## .\PS5DeployTool.bat -downloadPath=D:\PS5Builds
    [string] $ExeCommand = "./PS5DeployTool.ps1 -nexusServer https://nexus.firewalkstudios.com -downloadPath D:\PS5Builds -targetedBuild $buildNum"
    Write-Output "Executing command: '$ExeCommand'"
    Invoke-Expression $($ExeCommand)
    ## Start-Process powershell -Verb runAs -ArgumentList $("" + $ExeCommand)
    Pop-Location
}

## Accelbyte stuff
function ABCLI
{
    Param
    (
        [int]$buildNum = 0
    )

    # Need to run the script out of it's own directory
    $script_dir = "$global:P4_WorkspaceRoot\Tools\Bin\AccelByteTools"
    Write-Host "ABCLI - run cmd: 'createOnDemandServer -r 1p -i $buildNum' ... "
    Push-Location $script_dir
    Start-Process powershell .\launch.bat
    Pop-Location
}

## Windows stuff
# Open explorer in the current directory
function ex
{
    Invoke-Item .
}

# Open explorer in engine directory
function exe
{
    Invoke-Item "$($CurrentWorkspace.EnginePath)"
}

# Open explorer in project directory
function exp
{
    Invoke-Item "$UE_ProjectDirectory"
}

function net_adapter_reset
{
    # Disable Net adapters
    [string]$ExeCommand = "Disable-NetAdapter -Name 'Ethernet 2'; sleep 3; Enable-NetAdapter -Name 'Ethernet 2'; sleep 2"

    Write-Host " Disable Command: '$ExeCommand'"
    Start-Process powershell -Verb runAs -ArgumentList $("" + $ExeCommand)
}



## Kill Apps
function kvs
{
    taskkill.exe /im devenv.exe /t /f | Out-Null
}

function kue
{
    Invoke-Expression "taskkill.exe /im $($UE_ProjectName).exe /t /f | Out-Null" 
    Invoke-Expression "taskkill.exe /im $($UE_ProjectName)Server.exe /t /f | Out-Null"
    Invoke-Expression "taskkill.exe /im UnrealEditor.exe /t /f | Out-Null"
}

function hard_restart
{
    shutdown /r /f /t 0
}

function hard_shutdown
{
    shutdown /s /f /t 0
}

## Defaults - Do it here so all functions are defined.
dev a


####################################################
##### OMG You are so lame.. Scratch notes section! 

## Command line args to launch perf flythrough
# Revolt_Persistent?game=/Game/Modes/BeautifulCorner/BeautifulCorner_GM.BeautifulCorner_GM_C -ExecCmds="FWWorldPerfFlythrough.Enable 1"

### Print all the members of some object, like a file Item
#(Get-Item $CurrentWorkspace.ProjectPath) | Get-Member

### Installed Engine Build command
# \Engine\Build\BatchFiles/RunUAT BuildGraph -target="Make Installed Build Win64" -script="./Engine/Build/InstalledEngineBuild.xml" -set:WithFullDebugInfo=true -UNATTENDED -set:WithDDC=false -set:SignExecutables=false -VS2019

### Cook Content
#WINDOW_SPEW_CMND_EXE=$(printf "%q/RunUAT.bat BuildCookRun -project=\"%s\" -noP4 -unattended -platform=\"Win64\" -clientconfig=\"Development\" -cook" "$UEBUILDSCRIPTSPATH" "$WIN_UE_PROJ_PATH")

### Package Project w/ archive
#WINDOW_SPEW_CMND_EXE=$(printf "%q/RunUAT.bat BuildCookRun -project=\"%s\" -noP4 -unattended -build -platform=\"Win64\" -clientconfig=\"Development\" -cook -cookflavor=multi -stage -archive -archivedirectory=\"%s\"" "$UEBUILDSCRIPTSPATH" "$WIN_UE_PROJ_PATH" "$WIN_BuildDirName")

### Package for console
#WINDOW_SPEW_CMND_EXE=$(printf "%q/RunUAT.bat BuildCookRun -project=\"%s\" -noP4 -unattended -build -platform=\"XSX\" -clientconfig=\"Development\" -nocompileeditor -cook -cookflavor=multi -stage -pak -package -deploy -archive -archivedirectory=\"%s\"" "$UEBUILDSCRIPTSPATH" "$WIN_UE_PROJ_PATH" "$WIN_BuildDirName")

### Package for win server
#WINDOW_SPEW_CMND_EXE=$(printf "%q/RunUAT.bat BuildCookRun -project=\"%s\" -noP4 -unattended -build -platform=\"Win64\" -targetplatform=Win64 -target=AnacrusisServer -serverconfig=Development -nocompileeditor -cook -cookflavor=multi -stage -pak -archive -archivedirectory=\"%s\"" "$UEBUILDSCRIPTSPATH" "$WIN_UE_PROJ_PATH" "$WIN_BuildDirName")

### Iterative Cook
## D:\UE4\SBUE\Win\Engine\Build\BatchFiles/RunUAT BuildCookRun -project="D:\w\87c67ea3ba86a5c5\supreme_blitheness\Anacrusis.uproject" -noP4 -unattended -platform="Win64" -build -clientconfig="Development" -cook -cookflavor=multi -iterativecooking   -withEditor

### Restart Computer remotely
## Restart-Computer -ComputerName "TRAWCLIFFE-DEV1" -Force

### Force restart Remote Desktop services
# Get-Service -ComputerName TRAWCLIFFE-DEV1 -Name "Remote Desktop Services" | Restart-Service -Force

function TestOutput
{
    Param
    (
        [int]   $numLines   = 6,
        [string]$linetext   = "Debug Line "
    )
    
    for ( $i = 0; $i -lt $numLines; $i++)
    {
        Write-Output "$linetext $i / $numLines"
        sleep 1
    }
}

function Invoke-Expression-Window
{
    Param
    (
        [string]$command    = ". TestOutput"
    )

    $global:IEW_COM = $command
    #(Invoke-Expression -Command $command | select @{n='WithText';e={$_ + " 12345"}}).WithText

    #(Invoke-Expression -Command $command) | % { "My string $($_) my string2" }

    #Invoke-Expression $command | Out-Null


    ## Works, but waits until execution finish before processing. 
    # $inputLineNum = 1
    # (Invoke-Expression -Command $command) | % {
    #    Write-Host "$inputLineNum`: $_"
    #    $inputLineNum++
    # }

    # Write-Host "About to create process.."
    # $myprocss = Start-Process "$command" -PassThru 
    # Write-Host "Process created.. waiting for exit.. "
    # $myprocss.WaitForExit()
    # Write-Host "Done!"
    

    #Start-Process Invoke-Expression ("$command 10")
    #Start-Process Invoke-Expression ("$global:IEW_COM 10")
    #Start-Process powershell {Invoke-Expression ("$command 10")}
    #Start-Process powershell {Invoke-Expression ("$global:IEW_COM 10")}
    #Start-Process powershell -ArgumentList "-noexit -command `"$global:IEW_COM 10`""
    #Invoke-Command -ScriptBlock { $("$global:IEW_COM 10") } -JobName WinRM -ThrottleLimit 16 -AsJob

    #$cmd_job = Start-Job -Name PShellJob -ScriptBlock { $("Invoke-Expression $global:IEW_COM 10") }
    #$cmd_job = Start-Job -Name PShellJob -ScriptBlock { PowerShell } -ArgumentList $("$global:IEW_COM 10")
    $FOO = {$global:IEW_COM}
    $cmd_job = Start-Job -ScriptBlock {${Function:$FOO}} -ArgumentList 10
    $job_time = 0
    $job_total_time = 150
    $job_completed = 0
    while (!$job_completed -and ($job_time -lt $job_total_time))
    {
        #cls
        $cmd_job | Select-Object -Property *

        $job_completed = ($cmd_job.JobStateInfo -eq "Completed")
        sleep 0.5
        $job_time++
    }


    #Invoke-Expression 'cmd /c start powershell -Command { Invoke-Expression ("$global:IEW_COM 10") }'
    Invoke-Expression $("$global:IEW_COM 20")
}
