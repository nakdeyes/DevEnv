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
$BuildConfigs = @(
[PSCustomObject]@{ ID = 'Client'; Aliases = @('c', 'cli', 'client')},
[PSCustomObject]@{ ID = 'Server'; Aliases = @('s', 'serv', 'server')},
[PSCustomObject]@{ ID = 'Editor'; Aliases = @('e', 'ed', 'editor')}
)

$BuildSpecs = @(
[PSCustomObject]@{ ID = 'Debug';        Aliases = @('debug', 'de')},
[PSCustomObject]@{ ID = 'Development';  Aliases = @('development', 'dev')},
[PSCustomObject]@{ ID = 'Shipping';     Aliases = @('shipping', 'ship', 's')},
[PSCustomObject]@{ ID = 'Test';         Aliases = @('test', 'tst', 't')}
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
    $global:UE_Insights         = "$($CurrentWorkspace.EnginePath)\Engine\Binaries\Win64\UnrealInsights.exe"
    $global:UE_BuildTool        = "$($CurrentWorkspace.EnginePath)\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"

    # check to see if project is inside UE dir or project dir
    if ($($CurrentWorkspace.ProjectPath).Contains($($CurrentWorkspace.EnginePath)))
    {
        # Project is inside engine directory, user should use UE .sln in engine dir
        $global:UE_VSSolution = "$($CurrentWorkspace.EnginePath)\UE5.sln"
    }
    else
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
        [bool]  $workspaceCL    = 0
    )

    ## Check for presets
    if ($detailed -ne 0)
    {
        $workspaceSize  = 1
        $workspaceCL    = 1
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
    $StatsString += "        workspace $($env:WRKSPACE_LETTER): $global:P4_WorkspaceClient - $global:P4_WorkspaceRoot`r`n"
    $StatsString += "            project: $($CurrentWorkspace.ProjectPath)`r`n"
    $StatsString += "         engine dir: $($CurrentWorkspace.EnginePath)`r`n"

    if ($workspaceSize -ne 0)
    {
        $WorkspaceDirSize = ("{0:N2} GB" -f ((gci -force "$global:P4_WorkspaceRoot" -Recurse -ErrorAction SilentlyContinue| measure Length -s).sum / 1Gb))
        $StatsString += "     workspace size: $($WorkspaceDirSize)`r`n"
    }

    if ($workspaceCL -ne 0)
    {
        $WrkspaceCLString = p4cl
        $StatsString += "       workspace CL: $($WrkspaceCLString)`r`n"
    }

    ## Print the stats string to the screen
    echo $($StatsString)
}

function env_install_prereqs()
{
    # run as admin
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
    {  
        $arguments = "& '" +$myinvocation.mycommand.definition + "'"
        Start-Process powershell -Verb runAs -ArgumentList $arguments
        Break
    }

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

## Profile Maintanence
function env_script_edit
{
    . $AppPaths.TextEditor $script_path
}

function env_config_edit
{
    . $AppPaths.TextEditor $script_config_path
}

function env_omp_edit
{
    . $AppPaths.TextEditor $omp_theme_path
}

function env_script_reload
{
    echo ". $script_path"
    . $script_path
}

## UE stuff - Building
function vs_gen 
{
    # $GenProjBat = "$($CurrentWorkspace.EnginePath)\Engine\Build\BatchFiles\GenerateProjectFiles.bat"

    # . $GenProjBat "$UE_UProject" -progress

    $GenerateCommand = ". $global:UE_BuildTool -projectfiles -project=$($CurrentWorkspace.ProjectPath) -game -engine -rocket -progress"
    echo " generate project files command: $GenerateCommand"
    Invoke-Expression $GenerateCommand
}

function build
{
    Param
    (
        [string]$buildConfig    = "ed",
        [string]$buildSpec      = "dev"
    )

    $BuildConfigID = Get-ID-From-Alias $BuildConfigs $buildConfig
    if ($BuildConfigID -ieq $ERR)
    {
        Write-Host " !!! build given a config it does not understand ('$buildConfig'). Doing Nothing! Please select 'client', 'editor', 'server' or some other supported build config."
        return
    }

    $BuildSpecID = Get-ID-From-Alias $BuildSpecs $buildSpec
    if ($BuildSpecID -ieq $ERR)
    {
        Write-Host " !!! build given a spec it does not understand ('$buildSpec'). Doing Nothing! Please select 'dev', 'test', 'ship' or some other supported build spec."
        return
    }
    
    # Should match the name of the *.Target.cs to use to build.
    $BuildProjectName = ""
    switch ($BuildConfigID)
    {
        "Client" { $BuildProjectName = $UE_ProjectName }
        "Editor" { $BuildProjectName = "$($UE_ProjectName)Editor" }
        "Server" { $BuildProjectName = "$($UE_ProjectName)Server" }
        default { Write-Host "**HOW DID YOU GET HERE?!"; return; }
    }

    $BuildCommand = ". $UE_BuildScript $BuildProjectName Win64 $BuildSpecID $($CurrentWorkspace.ProjectPath) -waitmutex"

    Microsoft.PowerShell.Utility\Write-Host "    BUILD: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "$BuildConfigID - $BuildSpecID" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "  command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$BuildCommand'" -ForegroundColor "Cyan"

    Invoke-Expression -Command $BuildCommand
    $env:LASTEXITCODE = $global:LASTEXITCODE
    #Start-Process -FilePath "$UE_BuildScript" -ArgumentList "$BuildProjectName Win64 $BuildSpecID $($CurrentWorkspace.ProjectPath) -waitmutex" -NoNewWindow -Wait -PassThru
}

function cook
{
    Param
    (
        [string]$buildConfig    = "cli",
        [string]$buildSpec      = "dev",
        [bool]  $iterative      = 1
    )

    $BuildConfigID = Get-ID-From-Alias $BuildConfigs $buildConfig
    if ($BuildConfigID -ieq $ERR)
    {
        Write-Host " !!! Cook given a config it does not understand ('$buildConfig'). Doing Nothing! Please select 'client', 'server' or some other supported build config."
        return
    }
    if ($BuildConfigID -ieq "Editor")
    {
        Write-Host " !!! Cooking for the editor as a config is not really supported. Try 'client' or 'server' "
        return
    }

    $BuildSpecID = Get-ID-From-Alias $BuildSpecs $buildSpec
    if ($BuildSpecID -ieq $ERR)
    {
        Write-Host " !!! Cook given a spec it does not understand ('$buildSpec'). Doing Nothing! Please select 'dev', 'test', 'ship' or some other supported build spec."
        return
    }

    # Different configs require slightly different args, so tweak those here. 
    switch ($BuildConfigID)
    {   
        "Client" { $ConfigSpecificArgs = "-platform=Win64 -clientconfig=$BuildSpecID" }
        "Server" { $ConfigSpecificArgs = "-targetplatform=Win64 -target=`"$($UE_ProjectName)Server`" -serverconfig=`"$BuildSpecID`" -nocompileeditor" }
        default { Write-Host "**HOW DID YOU GET HERE?!"; return; }
    }

    if ($iterative -eq 1)
    {
        $ConfigSpecificArgs = $ConfigSpecificArgs + " -iterativecooking"
    }

    $CookCommand = ". $UE_UAT BuildCookRun -project=$($CurrentWorkspace.ProjectPath) -noP4 -unattended $ConfigSpecificArgs -cook"

    Microsoft.PowerShell.Utility\Write-Host "     COOK: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "$BuildConfigID - $BuildSpecID" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "  command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$CookCommand'" -ForegroundColor "Cyan"

    Invoke-Expression $CookCommand
}

function run
{
    Param
    (
        [string]$buildConfig    = "cli",
        [string]$buildSpec      = "dev",
        [bool]$useInsights      = 0,
        [bool]$replay           = 0,
        [bool]$clientConnect    = 1
    )

    $BuildConfigID = Get-ID-From-Alias $BuildConfigs $buildConfig
    if ($BuildConfigID -ieq $ERR)
    {
        Write-Host " !!! run given a config it does not understand ('$buildConfig'). Doing Nothing! Please select 'client', 'server' or some other supported build config."
        return
    }
    if ($BuildConfigID -ieq "Editor")
    {
        Write-Host " !!! run for the editor as a config is not really supported. Try 'client' or 'server' "
        return
    }

    $BuildSpecID = Get-ID-From-Alias $BuildSpecs $buildSpec
    if ($BuildSpecID -ieq $ERR)
    {
        Write-Host " !!! run given a spec it does not understand ('$buildSpec'). Doing Nothing! Please select 'dev', 'test', 'ship' or some other supported build spec."
        return
    }

    switch ($BuildConfigID)
    {   
        "Client" { 
            $ConfigRunCommand = "$($UE_ProjectName).exe" 
            if ($clientConnect -eq 1)
            {
                $ConfigRunCommand = $ConfigRunCommand + " 127.0.0.1 ? service_uri=premium.firewalkcloud.com"
            }
            $ConfigRunCommand = $ConfigRunCommand + " -WINDOWED -ResX=1280 -ResY=720 -WinX=0 -WinY=30"
        }
        "Server" { $ConfigRunCommand = "$($UE_ProjectName)Server.exe" }
        default { Write-Host "**HOW DID YOU GET HERE?!"; return; }
    }

    $RunCommand = ". $($UE_ProjectDirectory)\Binaries\Win64\$($ConfigRunCommand) -log"
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
    Microsoft.PowerShell.Utility\Write-Host "$BuildConfigID - $BuildSpecID" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "  command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$RunCommand'" -ForegroundColor "Cyan"

    Invoke-Expression $RunCommand
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
    . $AppPaths.VisualStudio $UE_VSSolution
}

function ueInsights
{
    . $UE_Insights
}

# Open Unreal Game Sync, should open from project directory to pick up P4 Config stuff
function ugs
{
    . $AppPaths.UnrealGameSync
}

## Perforce stuff

# Get current p4 cl
function p4cl
{
    p4 changes -m1 //...#have
}

function p4clean
{
    p4 clean -ade -I
}

function p4getworkspacestats
{
    Param
    (
        [bool]  $silent = 1
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


    if ($silent -eq 0)
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

## PS5 stuff
function PS5Deploy
{
    Param
    (
        [int]$buildNum   = 0
    )

    # Need to run the script out of it's own directory
    $script_dir = "$global:P4_WorkspaceRoot\Tools\Bin\WorkflowTools\Propper"
    Write-Host "Deploy PS5 build # $buildNum ... "
    Push-Location $script_dir
    .\install_ps5_build.cmd $buildNum
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



## Kill Apps
function kvs
{
    taskkill.exe /im devenv.exe /t /f | Out-Null
}

function kue
{
    Invoke-Expression "taskkill.exe /im $($UE_ProjectName).exe /t /f | Out-Null" 
    Invoke-Expression "taskkill.exe /im $($UE_ProjectName)Server.exe /t /f | Out-Null"
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

### Print all the members of some object, like a file Item
#(Get-Item $CurrentWorkspace.ProjectPath) | Get-Member

### Installed Engine Build command
# \Engine\Build\BatchFiles/RunUAT BuildGraph -target="Make Installed Build Win64" -script="./Engine/Build/InstalledEngineBuild.xml" -set:WithFullDebugInfo=true -UNATTENDED -set:WithDDC=false -set:SignExecutables=false -VS2019

### Cook Content
#WINDOW_SPEW_CMND_EXE=$(printf "%q/RunUAT.bat BuildCookRun -project=\"%s\" -noP4 -unattended -platform=\"Win64\" -clientconfig=\"Development\" -cook" "$UEBUILDSCRIPTSPATH" "$WIN_UE_PROJ_PATH")

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