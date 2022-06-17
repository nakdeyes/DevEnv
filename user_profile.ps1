# Use this file to run your own startup commands

# Save off this script and the user profile config path
$script_path_user_profile           = "$Env:CMDER_ROOT\config\user_profile.ps1"
$script_path_user_profile_config    = "$Env:CMDER_ROOT\config\user_profile_config.ps1"

## Load in config
. "$script_path_user_profile_config"




# Replace the cmder prompt entirely with this.
[ScriptBlock]$CmderPrompt = { 
    Microsoft.PowerShell.Utility\Write-Host "Dev$WorkspaceLetter " -NoNewLine -ForegroundColor "DarkGreen"
    Microsoft.PowerShell.Utility\Write-Host (Get-Location)">" -NoNewLine -ForegroundColor "DarkGray"
}

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

    $global:WorkspaceLetter = "$workspaceID".ToUpper()

    # Set all the paths
    dev_ue_set_paths

    # Navigate to the project home directory
    cd $UE_ProjectDirectory

    Write-Host "   workspace project: $($CurrentWorkspace.ProjectPath)"
}

function dev_ue_set_paths
{
    #(Get-Item $CurrentWorkspace.ProjectPath) | Get-Member

    # cache off relevant directories for workspace
    $global:UE_ProjectName      = (Get-Item $CurrentWorkspace.ProjectPath).BaseName
    $global:UE_ProjectDirectory = (Get-Item $CurrentWorkspace.ProjectPath).DirectoryName
    $global:UE_EngineScriptsDir = "$($CurrentWorkspace.EnginePath)\Engine\Build\BatchFiles"

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
}


## Profile Maintanence
function edit_profile
{
    . $AppPaths.TextEditor $script_path_user_profile
}

function edit_profile_config
{
    . $AppPaths.TextEditor $script_path_user_profile_config
}

function reload_profile
{
    echo ". $script_path_user_profile"
    . $script_path_user_profile
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

    $BuildCommand = ". $UE_BuildScript $BuildProjectName Win64 $BuildSpecID -waitmutex"

    Microsoft.PowerShell.Utility\Write-Host "    BUILD: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "$BuildConfigID - $BuildSpecID" -ForegroundColor "Cyan"
    Microsoft.PowerShell.Utility\Write-Host "  command: " -NoNewLine -ForegroundColor "DarkCyan"
    Microsoft.PowerShell.Utility\Write-Host "'$BuildCommand'" -ForegroundColor "Cyan"

    Invoke-Expression $BuildCommand
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
        [bool]$useInsights      = 0
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
        "Client" { $ConfigRunCommand = "$($UE_ProjectName).exe 127.0.0.1 ? service_uri=premium.firewalkcloud.com -WINDOWED -ResX=1280 -ResY=720 -WinX=0 -WinY=30" }
        "Server" { $ConfigRunCommand = "$($UE_ProjectName)Server.exe" }
        default { Write-Host "**HOW DID YOU GET HERE?!"; return; }
    }

    $RunCommand = ". $($UE_ProjectDirectory)\Binaries\Win64\$($ConfigRunCommand) -log"
    if ($useInsights -eq 1)
    {
        #$RunCommand = $RunCommand + " -trace=`"cpu,frame,bookmark,memory,loadtime`" -statnamedevents -loadtimetrace -tracehost=127.0.0.1"
        $RunCommand = $RunCommand + " -trace=`"cpu,frame,bookmark`" -statnamedevents -tracehost=127.0.0.1"
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