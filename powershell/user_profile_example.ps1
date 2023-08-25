# Use this file to run your own startup commands

### Method 1: Assumes that $PSScriptRoot is set, and ue_dev_env folder is copied there
# Import UE Dev Env script
. $PSScriptRoot\ue_dev_env\ue_dev_env.ps1

### Method 2: Assumes you want to leave your user_profile.ps1 somewhere else, and want to point
###     at some ue_dev_env folder somewhere ( along with option config override )

### Set the dev env script root directory and execute the dev env script
$DevEnvPsScriptRoot="E:\dev\GitHub\DevEnv\powershell\ue_dev_env"
$DevEnvConfigPath="C:\Users\tim.rawcliffe\Documents\PowerShell\ue_dev_env_config.ps1"
. $DevEnvPsScriptRoot\ue_dev_env.ps1
