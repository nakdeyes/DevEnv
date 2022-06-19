# WELCOME! TO TIM'S STRAY BOMBAY .BASHRC!
#   Current Cygwin package requirements:
#       * bc
#       * rsync

# Set the Bash Script Directory - Then make sure to set your options in .bashrc_config in that directory
BASH_SCRIPT_DIR="/cygdrive/c/cygwin64/home/timot/"


# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# base-files version 4.2-4

# ~/.bashrc: executed by bash(1) for interactive shells.

# The latest version as installed by the Cygwin Setup program can
# always be found at /etc/defaults/etc/skel/.bashrc

# Modifying /etc/skel/.bashrc directly will prevent
# setup from updating it.

# The copy in your home directory (~/.bashrc) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the cygwin mailing list.

# User dependent .bashrc file

# If not running interactively, don't do anything
#[[ "$-" != *i* ]] && return

# Shell Options
#
# See man bash for more options...
#
# Don't wait for job termination notification
# set -o notify
#
# Don't use ^D to exit
# set -o ignoreeof
#
# Use case-insensitive filename globbing
# shopt -s nocaseglob
#
# Make bash append rather than overwrite the history on disk
# shopt -s histappend
#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell

# Completion options
#
# These completion tuning parameters change the default behavior of bash_completion:
#
# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1
#
# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1
#
# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1
#
# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
# [[ -f /etc/bash_completion ]] && . /etc/bash_completion

# History Options
#
# Don't put duplicate lines in the history.
# export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
#
# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"

# Aliases
#
# Some people use a different file for aliases
# if [ -f "${HOME}/.bash_aliases" ]; then
#   source "${HOME}/.bash_aliases"
# fi
#
# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
#
# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
#
# Default to human readable figures
# alias df='df -h'
# alias du='du -h'
#
# Misc :)
# alias less='less -r'                          # raw control characters
# alias whence='type -a'                        # where, of a sort
# alias grep='grep --color'                     # show differences in colour
# alias egrep='egrep --color=auto'              # show differences in colour
# alias fgrep='fgrep --color=auto'              # show differences in colour
#
# Some shortcuts for different directory listings
# alias ls='ls -hF --color=tty'                 # classify files in colour
# alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
# alias ll='ls -l'                              # long list
# alias la='ls -A'                              # all but . and ..
# alias l='ls -CF'                              #

# Umask
#
# /etc/profile sets 022, removing write perms to group + others.
# Set a more restrictive umask: i.e. no exec perms for others:
# umask 027
# Paranoid: neither group nor others have any perms:
# umask 077

# Functions
#
# Some people use a different file for functions
# if [ -f "${HOME}/.bash_functions" ]; then
#   source "${HOME}/.bash_functions"
# fi
#
# Some example functions:
#
# a) function settitle
# settitle () 
# { 
#   echo -ne "\e]2;$@\a\e]1;$@\a"; 
# }
# 
# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping, 
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
# cd_func ()
# {
#   local x2 the_new_dir adir index
#   local -i cnt
# 
#   if [[ $1 ==  "--" ]]; then
#     dirs -v
#     return 0
#   fi
# 
#   the_new_dir=$1
#   [[ -z $1 ]] && the_new_dir=$HOME
# 
#   if [[ ${the_new_dir:0:1} == '-' ]]; then
#     #
#     # Extract dir N from dirs
#     index=${the_new_dir:1}
#     [[ -z $index ]] && index=1
#     adir=$(dirs +$index)
#     [[ -z $adir ]] && return 1
#     the_new_dir=$adir
#   fi
# 
#   #
#   # '~' has to be substituted by ${HOME}
#   [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"
# 
#   #
#   # Now change to the new dir and add to the top of the stack
#   pushd "${the_new_dir}" > /dev/null
#   [[ $? -ne 0 ]] && return 1
#   the_new_dir=$(pwd)
# 
#   #
#   # Trim down everything beyond 11th entry
#   popd -n +11 2>/dev/null 1>/dev/null
# 
#   #
#   # Remove any other occurence of this dir, skipping the top of the stack
#   for ((cnt=1; cnt <= 10; cnt++)); do
#     x2=$(dirs +${cnt} 2>/dev/null)
#     [[ $? -ne 0 ]] && return 0
#     [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
#     if [[ "${x2}" == "${the_new_dir}" ]]; then
#       popd -n +$cnt 2>/dev/null 1>/dev/null
#       cnt=cnt-1
#     fi
#   done
# 
#   return 0
# }
# 
# alias cd=cd_func

source "${BASH_SCRIPT_DIR}/.bashrc_config"

alias visstu="cygstart \"$VS_PATH\""
alias unrealeditor="cygstart \"$UE_PATH/Engine/Binaries/Win64/UE4Editor.exe\""
alias unrealeditorcmd="cygstart \"$UE_PATH/Engine/Binaries/Win64/UE4Editor-Cmd.exe\""
alias vs='visstu $UESOLUTIONPATH'
alias ue='cygstart $UEPROJPATH'
alias ufe="cygstart \"$UE_PATH/Engine/Binaries/Win64/UnrealFrontend.exe\""

#init vars
DEVPATH="/cygdrive/${wkspce_drive[0]}/${wkspce_path[0]}"
WINDEVPATH="${wkspce_drive[0]}:/${wkspce_path[0]}"
CUR_WORKSPACE_LETTER="a"
UEPROJPATH=""
UEPROJABSPATH=""
UEPROJNAME=""
UESOLUTIONPATH=""
UEVSPROJTARGET=""
UEBUILDSCRIPTSPATH="${UE_PATH}/Engine/Build/BatchFiles"
UEEDITORPATH="${UE_PATH}/Engine/Binaries/Win64/UE4Editor.exe"
UEBUILDTOOLPATH="${UE_PATH}/Engine/Binaries/DotNET/UnrealBuildTool.exe"
UEP4CLIENT=""
UEP4HOST=""
UEDEFAULTMAP=""

set CYGWIN="winsymlinks:nativestrict"

# dev - switch to a workspace, and build spec
function dev() {
    if [ $# -eq 0 ]; then
        echo "ERROR: dev() requires at least 1 argument ( workspace letter ( a,b,c,etc. )), and potentially a 2nd for spec. Workspaces available: "
        dev_info
        return 0
    fi

    if [[ "$1" =~ ^(help|-help|--help|-h|--h)$ ]]; then
        display_dev_help | more
        return 0
    fi
    
    local wrkspce_ind
    if [ "$1" -eq "$1" ] 2>/dev/null; then
        wrkspce_ind=$1
    else
        wrkspce_ind=$(workspace_letter_to_number $1)
    fi

    CUR_WORKSPACE_LETTER="$1"
    
    # TODO: Take in build spec and set on that.
    DEVPATH="/cygdrive/${wkspce_drive[$wrkspce_ind]}/${wkspce_path[$wrkspce_ind]}"
    WINDEVPATH="${wkspce_drive[$wrkspce_ind]}:/${wkspce_path[$wrkspce_ind]}"
    UEP4CLIENT="${wkspce_p4cli[$wrkspce_ind]}"
    UEP4HOST="${wkspce_p4host[$wrkspce_ind]}"
    UEDEFAULTMAP="${wkspce_defaultMap[$wrkspce_ind]}"

    findAndSetUESolutionAndProjectName
    
    #magic to convert forward slash to back slash for windows
    WINDEVPATH=$(sed 's/\//\\/g' <<< "$WINDEVPATH")
    
    echo "   dev: $DEVPATH"
    
    cd $DEVPATH
}

# dev_info - spew workspace info, pass a workspace letter and get that workspace, provide no args and get all of them
function dev_info() {
    if [ $# -eq 0 ]; then
        # no args.. loop through all workspaces and spew info
        echo "Found ${#wkspce_path[*]} workspaces."
        for ((i=0; i<${#wkspce_path[*]}; i++));
        do
            dev_info_help $i
        done
        return 0
    fi
    
    local inputNum
    if [ "$1" -eq "$1" ] 2>/dev/null; then
        inputNum=$1
    else
        inputNum=$(workspace_letter_to_number $1)
    fi
    
    local workspaceCount
    workspaceCount=${#wkspce_path[@]}
    workspaceCount=$((workspaceCount - 1))
    
    # check for bounds..
    if [ $inputNum -gt $workspaceCount ]; then
        echo "ERROR: dev_info() got index that is out of bounds.. index: $inputNum .. bounds: {0 - $workspaceCount}"
        return 0
    fi
    if [ $inputNum -lt 0 ]; then
        echo "ERROR: dev_info() got index that is out of bounds.. index: $inputNum .. bounds: {0 - $workspaceCount}"
        return 0
    fi
    
    dev_info_help $inputNum
}

# dev_info_help - spew workspace info for a particular workspace. requires an arg
function dev_info_help() {
    if [ $# -eq 0 ]; then
        echo "ERROR: dev_info_help() requires at least one argument "
        return 0
    fi
    
    #echo "dev_info_help: ${1}"
    local inputNum=$1
    local workspaceCount
    workspaceCount=${#wkspce_path[@]}
    workspaceCount=$((workspaceCount - 1))
    
    # check for bounds..
    if [ $inputNum -gt $workspaceCount ]; then
        echo "ERROR: dev_info_help() got index that is out of bounds.. index: $inputNum .. bounds: {0 - $workspaceCount}"
        return 0
    fi
    if [ $inputNum -lt 0 ]; then
        echo "ERROR: dev_info_help() got index that is out of bounds.. index: $inputNum .. bounds: {0 - $workspaceCount}"
        return 0
    fi
    
    # spew the info for this workspace!
    local wrkspce_letter
    wrkspce_letter=$(tr 0123456789 ABCDEFGHIJ <<< "$inputNum")
    echo "  Workspace $wrkspce_letter:"
    echo "         path: ${wkspce_drive[$inputNum]}:/${wkspce_path[$inputNum]}"
    #echo "         spec: ${wkspce_target[$inputNum]},${wkspce_spec[$inputNum]}"
    echo ""
}

function display_dev_help() {
    PUR='\033[0;35m'
    CYN='\033[0;36m'
    LPR='\033[1;35m'
    NC='\033[0m' # No Color
    echo -e ""
    echo -e "${CYN}Tim's Game Dev Bash Script v0.1 .. Help"
    echo -e "      Useful commands for Game Development with Unreal Engine and Visual Studio."
    echo -e ""
    echo -e "${PUR}  COMMAND                 INFO"
    echo -e "  ------------            ------------${NC}"
    echo -e "${LPR}  ------------  WORKSPACE ------------ ${NC}"
    echo -e "  ${CYN}dev${NC}                     Main command to switch development workspaces. Typical useage: "
    echo -e "                          'dev a' will set Workspace A to the current workspace ('dev 1' also"
    echo -e "                          works). 'dev b' will set to Workspace B and so forth. Typical use case"
    echo -e "                          is 1 workspace per Perforce Depot. NOTE: You probably should call this"
    echo -e "                          upon first opening your shell for the other commands to be useful!"
    echo -e "  ${CYN}dev -h${NC}                  Provide the (-h|--h|help|-help|--help) argument to the dev function, and"
    echo -e "                          see this help screen!"
    echo -e ""
    echo -e "${LPR}  ------------ LAUNCH APPS ------------ ${NC}"
    echo -e "  ${CYN}ue${NC}                      Launch the Unreal Engine Project found in the currently activated workspace."
    echo -e "  ${CYN}vs${NC}                      Open the Visual Studio Solution associated with this UE project ( the one generated"
    echo -e "                          with 'vs_gen'."
    echo -e "  ${CYN}ufe${NC}                     Launch the Unreal Engine Frontend Application. Used for Performance capture instpection and more!"
    echo -e "  ${CYN}ex${NC}                      Open Explorer in the root folder of the current workspace."
    echo -e ""
    echo -e "${LPR}  ------------   PERFORCE  ------------ ${NC}"
    echo -e "  ${CYN}p4v${NC}                     Launch P4V."
    echo -e "  ${CYN}p4Sync${NC}                  Pull latest from the P4 workspace associated with this workspace."
    echo -e "  ${CYN}p4MergeFromParent${NC}       Merges from parent stream, to stream in associated workspace. Use with caution! You need to have"
    echo -e "                          an empty default changelist (it is used during the merge, and anything in there will be submitted with"
    echo -e "                          the merge). You probably want to have everything shelved when you call this to be safe :D"
    echo -e "  ${CYN}p4MergeCheck${NC}            Checks to see if there are currently files available to merge from the parent Stream. Provides"
    echo -e "                          an option to do the merge if there are files available to merge."
    echo -e "  ${CYN}p4Opened${NC}                Checks to see if there are any currently 'opened' P4 files (read: checked-out, marked for add, delete, etc.)"
    echo -e "  ${CYN}pullAndBuild${NC}            Runs, p4Sync, vs_gen, then buildEditor, to pull and build."
    echo -e ""
    echo -e "${LPR}  ------------    BUILD    ------------ ${NC}"
    echo -e "  ${CYN}vs_gen${NC}                  Generate the Visual Studio Solution associated with the UE project in this workspace."
    echo -e "  ${CYN}buildClient${NC}             Compile the Client associated with this workspace's UE Project / VS Solution."
    echo -e "  ${CYN}buildEditor${NC}             Compile the Editor associated with this workspace's UE Project / VS Solution."
    echo -e ""
    echo -e "${LPR}  ------------ LAUNCH GAME ------------ ${NC}"
    echo -e "  ${CYN}ded_serv <map>${NC}          Run a dedicated server for the Project in the selected workspace. You can optionally provide"
    echo -e "                          a map to start on. (Defaults to '${UEDEFAULTMAP}')"
    echo -e "  ${CYN}listen_serv <map>${NC}       Run a listen server for the Project in the selected workspace. You can optionally provide a"
    echo -e "                          map to start on. (Defaults to '${UEDEFAULTMAP}')"
    echo -e "  ${CYN}client_con <count>${NC}      Launch a local game client that will connect to a local listen or dedicated server. You can"
    echo -e "                          optionally provide a count of clients to open between 1-4 (defaults to 1)."
    echo -e "  ${CYN}serv_cli <count> <map>${NC}  Launch a dedicated server, and a set of clients to connect to it. You can optionally supply"
    echo -e "                          a client count and a map to run (defaults to 1 client and '${UEDEFAULTMAP}' map). DISCLAIMER:"
    echo -e "                          The <count> and <map> parameters are ORDER DEPENDANT. Don't try to supply a map without a"
    echo -e "                          a client count."
    echo -e ""
    echo -e "${LPR}  ------------    MISC.    ------------ ${NC}"
    echo -e "  ${CYN}bash_edit${NC}               Open the .bashrc script file with the associated Windows Editor."
    echo -e "  ${CYN}bashedit${NC}"
    echo -e "  ${CYN}bash_config_edit${NC}        Open the .bashrc_config script file with the associated Windows Editor."
    echo -e "  ${CYN}bash_reload${NC}             Reload the .bashrc script file. Call this if you edit the script and want to reload without"
    echo -e "  ${CYN}bashreload${NC}              restarting Cygwin."
    echo -e "  ${CYN}excyg${NC}                   Open Windows Explorer at the specified Cygwin Path."
    echo -e "  ${CYN}kvs${NC}                     Force Kill Visual Studio"
    echo -e "  ${CYN}kue${NC}                     Force Kill any and all UE games and editors."
    echo -e ""
    echo -e "${LPR}  ------------   WINDOWS   ------------ ${NC}"
    echo -e "  ${CYN}hard_restart${NC}            Force Windows to do a proper full restart, skipping any Sleep/Hibernate functionality."
    echo -e "  ${CYN}hard_shutdown${NC}           Force Windows to do a proper full shutdown, skipping any Sleep/Hibernate functionality."
    echo -e "  ${CYN}signout${NC}                 Do a Windows Signout."
    echo -e ""
}

function findAndSetUESolutionAndProjectName() {
    # go to this folder, then do relative path searches.. this is the only way the searches will work with symlinks 
    cd $DEVPATH

    # find unreal solution.. only solution in the project path
    UESOLUTIONPATH=`find . -maxdepth 1 -name "*.sln"`

    # find the unreal project file, only .uproject in the project path
    UEPROJPATH=`find . -maxdepth 1 -name "*.uproject"`

    cd Source
    UEVSPROJTARGET=`find . -maxdepth 1 -name "*Editor.Target.cs"`
    cd ../

    # strip just the project name out now, so we can use it for build commands later.
    UEPROJNAME=${UEPROJPATH##*/}
    UEPROJNAME=${UEPROJNAME%.*}

    # Find absolute path for the UE project
    UEPROJABSPATH=`realpath ${UEPROJPATH}`
    
    # We found the *Editor.Target.cs in the Source directory, strip out the project name from that, for building later. 
    # Strip before first /
    UEVSPROJTARGET=${UEVSPROJTARGET##*/}
    # Strip after 'Editor'
    UEVSPROJTARGET=${UEVSPROJTARGET%Editor*}

    #echo " UE solution found: ${UESOLUTIONPATH} .. proj found: ${UEPROJPATH} ... proj name: ${UEPROJNAME} ... full path: ${UEPROJABSPATH}"
    #echo "      VS Proj Target Name: ${UEVSPROJTARGET} "
}

# dumb function to get a workspace array index from a letter ( i.e. "a" returns 0, as its the first workspace in the array
function workspace_letter_to_number() {
    if [ $# -eq 0 ]; then
        echo "ERROR: workspace_letter_to_number() requires at least one argument "
        return -1
    fi
    
    local inputLetter
    local retNum
    
    inputLetter="$1"
    
    retNum=$(tr abcdefghij 0123456789 <<< "$inputLetter")
    
    # make sure our return value is within array bounds
    local workspaceCount
    workspaceCount=${#wkspce_path[@]}
    workspaceCount=$((workspaceCount - 1))
    if [ $retNum -gt $workspaceCount ]; then
        #echo "retNum: $retNum .. gt workspaceCount: $workspaceCount"
        retNum=$workspaceCount
    fi
    
    #echo " workspace_letter_to_number - input: $inputLetter .. index: $retNum"
    #return $retNum
    echo $retNum 
}

function ex() {
    #echo explorer.exe \"$WINDEVPATH\"
    cygstart explorer.exe \"$WINDEVPATH\"
}

function client_con() {
    # find and clamp the number of clients
    NUM_CLIENTS=1
    if [ $# -ne 0 ]; then
        NUM_CLIENTS=$1

        if [ $NUM_CLIENTS -gt 4 ]; then
            NUM_CLIENTS=4
        fi
    fi

    # execute from devpath
    cd $DEVPATH

    WIN_UE_PROJ_PATH=$(cygpath -w ${UEPROJABSPATH})

    WINDOW_X_SIZE=1138
    WINDOW_Y_SIZE=640

    # launch that many clients!
    for (( c=1; c<=$NUM_CLIENTS; c++ )); do
        # default window pos
        CUR_WIN_X=0
        CUR_WIN_Y=20

        # move 2 and 4 to the right
        if [ $c = 2 ] || [ $c = 4 ]; then
            CUR_WIN_X=`expr ${CUR_WIN_X} + ${WINDOW_X_SIZE}`
        fi

        #move 3 and 4 down
        if [ $c = 3 ] || [ $c = 4 ]; then
            CUR_WIN_Y=`expr ${CUR_WIN_Y} + ${CUR_WIN_Y} + ${CUR_WIN_Y} + ${WINDOW_Y_SIZE}`
        fi

        unrealeditor ${WIN_UE_PROJ_PATH} 127.0.0.1 -game -WINDOWED -ResX=${WINDOW_X_SIZE} -ResY=${WINDOW_Y_SIZE} -WinX=${CUR_WIN_X} -WinY=${CUR_WIN_Y} -ConsoleX=${CUR_WIN_X} -ConsoleY=${CUR_WIN_Y} -log -nosteam
    done

}

function clients() {
    # find and clamp the number of clients
    NUM_CLIENTS=1
    if [ $# -ne 0 ]; then
        NUM_CLIENTS=$1

        if [ $NUM_CLIENTS -gt 4 ]; then
            NUM_CLIENTS=4
        fi
    fi

    # execute from devpath
    cd $DEVPATH

    WIN_UE_PROJ_PATH=$(cygpath -w ${UEPROJABSPATH})

    WINDOW_X_SIZE=1138
    WINDOW_Y_SIZE=640

    # launch that many clients!
    for (( c=1; c<=$NUM_CLIENTS; c++ )); do
        # default window pos
        CUR_WIN_X=0
        CUR_WIN_Y=20

        # move 2 and 4 to the right
        if [ $c = 2 ] || [ $c = 4 ]; then
            CUR_WIN_X=`expr ${CUR_WIN_X} + ${WINDOW_X_SIZE}`
        fi

        #move 3 and 4 down
        if [ $c = 3 ] || [ $c = 4 ]; then
            CUR_WIN_Y=`expr ${CUR_WIN_Y} + ${CUR_WIN_Y} + ${CUR_WIN_Y} + ${WINDOW_Y_SIZE}`
        fi

        unrealeditor ${WIN_UE_PROJ_PATH} -game -WINDOWED -ResX=${WINDOW_X_SIZE} -ResY=${WINDOW_Y_SIZE} -WinX=${CUR_WIN_X} -WinY=${CUR_WIN_Y} -ConsoleX=${CUR_WIN_X} -ConsoleY=${CUR_WIN_Y} -log -nosteam
    done

}

function listen_serv() {
    # check for optional map
    MAP_TO_PLAY=${UEDEFAULTMAP}
    if [ $# -ne 0 ]; then
        MAP_TO_PLAY=$1
    fi

    cd $DEVPATH
    WIN_UE_PROJ_PATH=$(cygpath -w ${UEPROJABSPATH})
    unrealeditor ${WIN_UE_PROJ_PATH} ${MAP_TO_PLAY}?listen -game -WINDOWED -ResX=1138 -ResY=640 -WinX=1138 -WinY=660 -ConsoleX=1138 -ConsoleY=660 -log -nosteam
}

function ded_serv() {
    # check for optional map
    MAP_TO_PLAY=${UEDEFAULTMAP}
    if [ $# -ne 0 ]; then
        MAP_TO_PLAY=$1
    fi

    cd $DEVPATH
    WIN_UE_PROJ_PATH=$(cygpath -w ${UEPROJABSPATH})
    unrealeditor ${WIN_UE_PROJ_PATH} ${MAP_TO_PLAY} -server -log -nosteam
}

function serv_cli() {
    ded_serv $2
    client_con $1
}

#### Dev aliases
# Bash Stuff
alias bash_edit='cygstart ${BASH_SCRIPT_DIR}/.bashrc'
alias bash_config_edit='cygstart ${BASH_SCRIPT_DIR}/.bashrc_config'
alias bash_reload='cd /cygdrive/c/ && . ~/.bashrc'
alias bashedit='bash_edit'
alias bashreload='bash_reload'
alias excyg='WIN_CYG_DIR=$(cygpath -w ${BASH_SCRIPT_DIR}); cygstart explorer.exe ${WIN_CYG_DIR}'

# Application Shortcuts
alias p4v='p4sethost; cygstart p4v'

# Kill Application Shortcuts!
alias kvs='ps -W | awk "/devenv.exe/,NF=1" | xargs kill -f'
alias kue='ps -W | awk "/UE4Editor.exe/,NF=1" | xargs kill -f'

# perforce stuff
alias p4sethost='p4 set P4HOST=${UEP4HOST}'
alias p4Clean='p4sethost; p4 -c ${UEP4CLIENT} clean -e -a -d -I -n ${WINDEVPATH}\\...'
alias p4Opened='p4sethost; p4 -c ${UEP4CLIENT} opened'
alias p4Login='p4sethost; p4 -c ${UEP4CLIENT} login'

function p4Sync_parseSyncOutputLine() {
    
    # search for most common case: file updated
    searchstring="- updating "
    file_name=${1#*$searchstring}
    index=$((${#1} - ${#file_name} - ${#searchstring}-1))

    # search for file addition if required
    if (( index < 0 )); then
        searchstring="- added as "
        file_name=${1#*$searchstring}
        index=$((${#1} - ${#file_name} - ${#searchstring}-1))
    fi

    # search for file deletion if required
    if (( index < 0 )); then
        searchstring="- deleted as "
        file_name=${1#*$searchstring}
        index=$((${#1} - ${#file_name} - ${#searchstring}-1))
    fi

    file_name=${1:0:${index}}

    SYNC_EDITOR_LINE_COUNT=$(($SYNC_EDITOR_LINE_COUNT+1))
    SYNC_PREFIX_ARR[2]=${SYNC_PREFIX_ARR[1]}
    SYNC_PREFIX_ARR[1]=${SYNC_PREFIX_ARR[0]}
    SYNC_PREFIX_ARR[0]=$(printf "syncing %03d/%03d)" ${SYNC_EDITOR_LINE_COUNT} ${P4SYNC_OUTPUT_COUNT})

    SYNC_OUTPUT_ARR[2]=${SYNC_OUTPUT_ARR[1]}
    SYNC_OUTPUT_ARR[1]=${SYNC_OUTPUT_ARR[0]}
    SYNC_OUTPUT_ARR[0]=$(echo ${file_name} | cut -c-$((${COLUMNS}-16)))

    echo -en "\e[3A \r\e[0J" # up - moves 3 lines up and clear to end
    printf "${CYN}%s${NC} %s\n${CYN}%s${NC} %s\n${CYN}%s${NC} %s\n" ${SYNC_PREFIX_ARR[2]} ${SYNC_OUTPUT_ARR[2]} ${SYNC_PREFIX_ARR[1]} ${SYNC_OUTPUT_ARR[1]} ${SYNC_PREFIX_ARR[0]} ${SYNC_OUTPUT_ARR[0]}
}

function p4Sync() {
    p4sethost

    # sync client
    P4SYNC_OUTPUT=$(p4 -c ${UEP4CLIENT} sync -n)
    P4SYNC_OUTPUT_COUNT=$(echo "${P4SYNC_OUTPUT}" | wc -l)

    CYN='\033[0;36m'
    LPR='\033[1;35m'
    NC='\033[0m' # No Color
    
    if [ "$P4SYNC_OUTPUT" == "" ] ; then
        printf "\r\e[0K${CYN}syncing 000/000)       ${LPR}No Files to sync!${NC}\n"
    else
        SYNC_PREFIX_ARR=("syncing 000/000)" "syncing 000/000)" "syncing 000/000)")
        SYNC_OUTPUT_ARR=(" " " " " ")
        printf "${CYN}%s %s\n%s %s\n%s %s${NC}\n" ${SYNC_PREFIX_ARR[2]} ${SYNC_OUTPUT_ARR[2]} ${SYNC_PREFIX_ARR[1]} ${SYNC_OUTPUT_ARR[1]} ${SYNC_PREFIX_ARR[0]} ${SYNC_OUTPUT_ARR[0]}
        SYNC_EDITOR_LINE_COUNT=0

        COLUMNS=$(tput cols)
        COLUMNS=$((COLUMNS-2)) # specific col width to cut to for spew in loop below
        OLD_IFS=${IFS}
        IFS='
'
        p4 -c ${UEP4CLIENT} sync ${sync_flags} | {
        while IFS= read -r line ; do
            final_line=${line:0:((${#line}-1))}
            p4Sync_parseSyncOutputLine ${final_line}
        done
        }
        IFS=${OLD_IFS}
    fi
}

function p4MergeCheck()
{
    p4sethost

    if [[ -z "$(p4 -c ${UEP4CLIENT} merge -n)" ]] 2>/dev/null; then 
        echo "There are NOT currently any files to merge from parent. Branch from client '${UEP4CLIENT}' is up to date."
    else
        echo "There ARE currently files to merge from parent! Perform a merge from parent on client '${UEP4CLIENT}'?"
        while true; do
            read -p "    (y)es / (n)no: " yn
            case $yn in
                [Yy]* ) p4MergeFromParent; return;; 
                [Nn]* ) echo " ..exiting.. "; return;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
}

function p4MergeFromParent()
{
    ### Check for open perforce files and give an opportunity to exit the program without doing anything
    echo "Checking for open p4 files.."
    p4sethost
    
    ##################### Check for open p4 files. Start.
    P4ANYFILESOPEN="NO"
    if [[ -z "$(p4 -c ${UEP4CLIENT} opened)" ]] 2>/dev/null; then 
        P4ANYFILESOPEN="NO"
    else
        P4ANYFILESOPEN="YES"
    fi

    P4DEFFILESOPEN="NO"
    if [[ -z "$(p4 -c ${UEP4CLIENT} opened -c default)" ]] 2>/dev/null; then 
        P4DEFFILESOPEN="NO"
    else
        P4DEFFILESOPEN="YES"
    fi

    if [ "$P4DEFFILESOPEN" == "YES" ] || [ "$P4ANYFILESOPEN" == "YES" ]; then
        RED='\033[0;31m'
        NC='\033[0m' # No Color
        printf "  ${RED}CAUTION!${NC} File(s) open in Default Changelist: ${RED}${P4DEFFILESOPEN}${NC} .. File(s) open in any Changelist: ${RED}${P4ANYFILESOPEN}${NC} \n"
        if [ "$P4DEFFILESOPEN" == "YES" ]; then
            printf "     * p4 Merge will use default p4 changelist when merging, and any files in the default p4 changelist will be submitted as \n"
            printf "     part of the process. It is HIGHLY recommended to shelve or revert files in the default p4 changelist before continuing.. \n"
        fi

        if [ "$P4ANYFILESOPEN" == "YES" ]; then
            printf "     * It is recommended to shelve or revert all files on this workspace before merging to avoid merge conflicts.\n"
        fi

        #echo "    Continue? (y)es / (n)no: "
        while true; do
            read -p "    Continue? (y)es / (n)no: " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) echo " ..exiting without doing anything.. "; return;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    ##################### Check for open p4 files. End.

    # sync client
    p4Sync

    # merge from parent stream to current stream
    echo -n "    Merging files from parent.."
    P4MERGE_OUTPUT="$(p4 -c ${UEP4CLIENT} merge)"
    P4MERGE_OUTPUT_COUNT="$(echo "${P4MERGE_OUTPUT}" | wc -l)"
    P4MERGE_OUTPUT_COUNT=$((P4MERGE_OUTPUT_COUNT/2))
    echo " ..Merged ${P4MERGE_OUTPUT_COUNT} files!"

    if (( P4MERGE_OUTPUT_COUNT <= 0 )); then
        echo " No files merged from parent. Workspace p4 stream appears to be up to date."
    else
        # attempt auto resolve of merged files
        echo -n "    Resolving files.."
        P4RESOLVE_OUTPUT="$(p4 -c ${UEP4CLIENT} resolve -am)"
        P4RESOLVE_OUTPUT_COUNT="$(echo "${P4RESOLVE_OUTPUT}" | wc -l)"
        P4RESOLVE_OUTPUT_COUNT=$((P4RESOLVE_OUTPUT_COUNT/3))
        echo " ..Resolved ${P4RESOLVE_OUTPUT_COUNT} files!"

        # attempt to submit the resolved files
        p4 -c ${UEP4CLIENT} submit -d "Merging from Mainline to child stream from workspace ${UEP4CLIENT}" > /dev/null 2>&1
        echo " Submitted CL with merged files!"
    fi
}

# Build Stuff!
# Unreal build commands from: https://answers.unrealengine.com/questions/668555/compile-and-reload-from-the-command-line.html?sort=oldest
# generate the VS solution from the UE Project
function vs_gen() {
    cd $DEVPATH
    WIN_UE_PROJ_PATH=$(cygpath -w ${UEPROJABSPATH})

    WINDOW_SPEW_CMND_EXE=$(printf "%q -projectfiles -project=\"%s\" -game -rocket -progress" "$UEBUILDTOOLPATH" "$WIN_UE_PROJ_PATH")
    windowSpewCommand 3 1 "VSGen" 3 1
}

# build the game solution
function buildClient() {
    cd $DEVPATH
    WIN_UE_PROJ_PATH=$(cygpath -w ${UEPROJABSPATH})

    WINDOW_SPEW_CMND_EXE=$(printf "%q/Build.bat %q Win64 Development \"%s\" -waitmutex" "$UEBUILDSCRIPTSPATH" "$UEVSPROJTARGET" "$WIN_UE_PROJ_PATH")
    windowSpewCommand 5 1 "bldCli" 3 1
}

# build the Editor Solution
function buildEditor() {
    cd $DEVPATH
    WIN_UE_PROJ_PATH=$(cygpath -w ${UEPROJABSPATH})

    WINDOW_SPEW_CMND_EXE=$(printf "%q/Build.bat %qEditor Win64 Development \"%s\" -waitmutex" "$UEBUILDSCRIPTSPATH" "$UEVSPROJTARGET" "$WIN_UE_PROJ_PATH")
    windowSpewCommand 5 1 "bldEd" 3 1
}

# run a command with output, and spew it to a window of a set amount of lines.
#   $1 - window line size - How many lines of spew to display
#   $2 - spew all override - If 1, the command will simply be spewed to the console like normal, rather than using any scrolling window. Overrides the window line size
#   $3 - label string for the spew
#   $4 - label line number digit count - the number of digits that are reserved line numbers. Set to 0 to omit line numbers
#   $5 - spew command - If 1, the command being executed will be printed to the console before execution
#   $WINDOW_SPEW_CMND_EXE - This is the Variable that should be set before calling this function, that contains the command to execute and spew.
function windowSpewCommand() {
    # define colors
    CYN='\033[0;36m'
    NC='\033[0m' # No Color

    #optional print command to console
    if [[ $# -gt 4 && ${5} -eq 1 ]]; then
        printf "${NC} --%s-- '${CYN}%s${NC}'\n" "$3" "$WINDOW_SPEW_CMND_EXE"
    fi

    #sanitize inputs
    # find and clamp the number of lines in the window
    WINSPEW_LINESIZE=$1
    if [ $WINSPEW_LINESIZE -lt 1 ]; then
        WINSPEW_LINESIZE=1
    fi
    if [ $WINSPEW_LINESIZE -gt 20 ]; then
        WINSPEW_LINESIZE=20
    fi

    # create default string with line output digit count considered
    DEFAULT_BLANK_LINE_LABEL=""
    for ((i=0; i<${4}; i++)); do
        DEFAULT_BLANK_LINE_LABEL="${DEFAULT_BLANK_LINE_LABEL}-"
    done

    # find label and label len
    WINSPEW_LABEL="$3"
    WINSPEW_LABELLEN=${#3}

    # configure colors and line spacing
    OLD_IFS=${IFS}
    IFS='
'
    #Winspew Prefix array
    unset WINSPEW_PREFIX_ARR
    unset WINSPEW_OUTPUT_ARR
    for ((i=0; i<${WINSPEW_LINESIZE}; i++)); do
        WINSPEW_PREFIX_ARR[$i]="${WINSPEW_LABEL} ${DEFAULT_BLANK_LINE_LABEL})"
        WINSPEW_OUTPUT_ARR[$i]=" "
        printf "${CYN}%s${NC} %s\n" ${WINSPEW_PREFIX_ARR[$i]} ${WINSPEW_OUTPUT_ARR[$i]}
    done

    WINSPEW_LINE_COUNT=0
    COLUMNS=$(tput cols)
    COLUMNS=$((COLUMNS - ${WINSPEW_LABELLEN} - "$4" + 6)) # specific col width to cut to for spew in loop below

    eval $WINDOW_SPEW_CMND_EXE | {
    while IFS= read -r line ; do
        final_line=${line:0:((${#line}-1))}
        windowSpewCommand_parseBuildOutputLine ${WINSPEW_LABEL} ${4} ${final_line} ${WINSPEW_LINESIZE}
    done
    }

    IFS=${OLD_IFS}
}

# helper function for windowSpewCommand that actually draws the lines and handles drawing them in the line window.
#   $1 - label string for the spew
#   $2 - label line number digit count - the number of digits that are reserved line numbers. Set to 0 to omit line numbers
#   $3 - the line output
#   $4 - the build window line count
function windowSpewCommand_drawBuildOutputLine() {
    WINSPEW_LINE_COUNT=$(($WINSPEW_LINE_COUNT+1))
    
    for ((i=($WINSPEW_LINESIZE - 1); i>=0; i--)); do
        if [ $i -eq 0 ]; then
            WINSPEW_PREFIX_ARR[0]=$(printf "%s %0${2}d)" "$1" ${WINSPEW_LINE_COUNT})
            WINSPEW_OUTPUT_ARR[0]=${3}
        else
            I_MINUS_ONE=$(($i-1))
            WINSPEW_PREFIX_ARR[$i]=${WINSPEW_PREFIX_ARR[${I_MINUS_ONE}]}
            WINSPEW_OUTPUT_ARR[$i]=${WINSPEW_OUTPUT_ARR[${I_MINUS_ONE}]}
        fi
    done

    echo -en "\e[${4}A \r\e[0J" # up - moves $4 lines up and clear to end

    for ((i=($WINSPEW_LINESIZE - 1); i>=0; i--)); do
        printf "${CYN}%s${NC} %s\n" ${WINSPEW_PREFIX_ARR[$i]} ${WINSPEW_OUTPUT_ARR[$i]}
    done
}

# helper function to help windowSpewCommand parse a command output line before spewing it to the console.
#   $1 - label string for the spew
#   $2 - label line number digit count - the number of digits that are reserved line numbers. Set to 0 to omit line numbers
#   $3 - the line output
#   $4 - the build window line count
function windowSpewCommand_parseBuildOutputLine() 
{
    string_length=${#3}
    line_length=$(($COLUMNS-10))

    if (($string_length <= $line_length)); then
        windowSpewCommand_drawBuildOutputLine ${1} ${2} ${3} ${4}
    else
        line_start_ind=0
        while (($line_start_ind < $string_length)); do
            line_segment=${3:$line_start_ind:$line_length}
            line_start_ind=$(($line_start_ind+$line_length))

            windowSpewCommand_drawBuildOutputLine ${1} ${2} ${line_segment} ${4}
        done
    fi
}

function pullAndBuild() {
    cd $DEVPATH
    #echo -en "\e[?25h" # Show Cursor..
    PUR='\033[0;35m'
    CYN='\033[0;36m'
    NC='\033[0m' # No Color
    printf "${PUR}--- Syncing Perforce Client... ${NC}\n"
    SYNC_START=`date +%s.%N`
    p4Sync
    SYNC_END=`date +%s.%N`
    SYNC_DUR=$( echo "$SYNC_END - $SYNC_START" | bc -l )
    printf "${PUR}--- Syncing Perforce Client Complete! .. Time: %.02f s ${NC}\n" $SYNC_DUR
    sleep 1
    printf "${PUR}--- Generating VS Solution...${NC}\n"
    GEN_START=`date +%s.%N`
    vs_gen
    GEN_END=`date +%s.%N`
    GEN_DUR=$( echo "$GEN_END - $GEN_START" | bc -l )
    printf "${PUR}--- Generating VS Solution Complete! .. Time: %.02f s ${NC}\n" $GEN_DUR

    sleep 1
    printf "${PUR}--- Building Editor Solution...${NC}\n"
    BUILD_START=`date +%s.%N`
    buildEditor
    BUILD_END=`date +%s.%N`
    BUILD_DUR=$( echo "$BUILD_END - $BUILD_START" | bc -l )
    printf "${PUR}--- Building Editor Solution Complete! .. Time: %.02f s ${NC}\n" $BUILD_DUR
    TOTAL_TIME=$( echo "($SYNC_END - $SYNC_START) + ($GEN_END - $GEN_START) + ($BUILD_END - $BUILD_START)" | bc -l )
    
    printf "\n${CYN} pullAndBuild Complete.\n"
    printf "       sync: %.02f s\n" $SYNC_DUR
    printf "     vs_gen: %.02f s\n" $GEN_DUR
    printf "      build: %.02f s\n      ---------\n" $BUILD_DUR
    printf "      Total: %.02f s${NC}\n" $TOTAL_TIME
}

function pullBuildDev() {
    cd $DEVPATH
    #echo -en "\e[?25h" # Show Cursor..
    PUR='\033[0;35m'
    CYN='\033[0;36m'
    NC='\033[0m' # No Color
    printf "${PUR}--- Syncing Perforce Client... ${NC}\n"
    SYNC_START=`date +%s.%N`
    p4Sync
    SYNC_END=`date +%s.%N`
    SYNC_DUR=$( echo "$SYNC_END - $SYNC_START" | bc -l )
    printf "${PUR}--- Syncing Perforce Client Complete! .. Time: %.02f s ${NC}\n" $SYNC_DUR
    sleep 1
    printf "${PUR}--- Generating VS Solution...${NC}\n"
    GEN_START=`date +%s.%N`
    vs_gen
    GEN_END=`date +%s.%N`
    GEN_DUR=$( echo "$GEN_END - $GEN_START" | bc -l )
    printf "${PUR}--- Generating VS Solution Complete! .. Time: %.02f s ${NC}\n" $GEN_DUR
    sleep 1
    printf "${PUR}--- Opening VS Solution...${NC}\n"
    vs
    sleep 1
    printf "${PUR}--- Building Editor Solution...${NC}\n"
    BUILD_START=`date +%s.%N`
    buildEditor
    BUILD_END=`date +%s.%N`
    BUILD_DUR=$( echo "$BUILD_END - $BUILD_START" | bc -l )
    printf "${PUR}--- Building Editor Solution Complete! .. Time: %.02f s ${NC}\n" $BUILD_DUR
    TOTAL_TIME=$( echo "($SYNC_END - $SYNC_START) + ($GEN_END - $GEN_START) + ($BUILD_END - $BUILD_START)" | bc -l )
    
    printf "\n${CYN} pullAndBuild Complete.\n"
    printf "       sync: %.02f s\n" $SYNC_DUR
    printf "     vs_gen: %.02f s\n" $GEN_DUR
    printf "      build: %.02f s\n      ---------\n" $BUILD_DUR
    printf "      Total: %.02f s${NC}\n" $TOTAL_TIME
}

function pullBuildEd() {
    cd $DEVPATH
    #echo -en "\e[?25h" # Show Cursor..
    PUR='\033[0;35m'
    CYN='\033[0;36m'
    NC='\033[0m' # No Color
    printf "${PUR}--- Syncing Perforce Client... ${NC}\n"
    SYNC_START=`date +%s.%N`
    p4Sync
    SYNC_END=`date +%s.%N`
    SYNC_DUR=$( echo "$SYNC_END - $SYNC_START" | bc -l )
    printf "${PUR}--- Syncing Perforce Client Complete! .. Time: %.02f s ${NC}\n" $SYNC_DUR
    sleep 1
    printf "${PUR}--- Generating VS Solution...${NC}\n"
    GEN_START=`date +%s.%N`
    vs_gen
    GEN_END=`date +%s.%N`
    GEN_DUR=$( echo "$GEN_END - $GEN_START" | bc -l )
    printf "${PUR}--- Generating VS Solution Complete! .. Time: %.02f s ${NC}\n" $GEN_DUR
    sleep 1
    printf "${PUR}--- Building Editor Solution...${NC}\n"
    BUILD_START=`date +%s.%N`
    buildEditor
    BUILD_END=`date +%s.%N`
    BUILD_DUR=$( echo "$BUILD_END - $BUILD_START" | bc -l )
    printf "${PUR}--- Building Editor Solution Complete! .. Time: %.02f s ${NC}\n" $BUILD_DUR
    TOTAL_TIME=$( echo "($SYNC_END - $SYNC_START) + ($GEN_END - $GEN_START) + ($BUILD_END - $BUILD_START)" | bc -l )
    
    printf "\n${CYN} pullAndBuild Complete.\n"
    printf "       sync: %.02f s\n" $SYNC_DUR
    printf "     vs_gen: %.02f s\n" $GEN_DUR
    printf "      build: %.02f s\n      ---------\n" $BUILD_DUR
    printf "      Total: %.02f s${NC}\n" $TOTAL_TIME

    printf "${PUR}--- Opening Unreal Editor...${NC}\n"
    ue
}

#Cooks minimum set of content by default, cooks all with -a/-all
function ueCook() {
    OPTIONAL_PARAMS=""
    if [[ "$1" =~ ^(all|-all|--all|-a|--a)$ ]]; then
        OPTIONAL_PARAMS="-cook_all"
    fi

    unrealeditorcmd ${WIN_UE_PROJ_PATH} -run=cook -targetplatform=Windows -iterate -map=Lobby+MainMenu+TransitionMap+TransportShip+Transition_Airlock+s1c1l1_terminal+s1c1l2_crew+s1c1l3_mall
}

function runClangOnSource_convertToWinPathAndCheckout() {
    WIN_P4_EDIT_PATH=$(cygpath -wa "$1")
    echo -en "\e[1A"
    echo -e "\e[0K\r         .. ${2} \\ ${3} checking out: '${1}'" 
    p4 -c ${UEP4CLIENT} edit "$WIN_P4_EDIT_PATH" > /dev/null 2>&1
}

function runClangOnSource_formatFile() {
    #WIN_P4_EDIT_PATH=$(cygpath -wa "$1")
    echo -en "\e[1A"
    echo -e "\e[0K\r         .. ${2} \\ ${3} clang-format on file: '${1}'" 
    "$CLANG_PATH" -style=file -i "$1"
}

## Clang! - Run clang on the full source directory using the project's clang format
function runClangOnSource() {
    
    ##################### Check for open p4 files. Start.
    P4ANYFILESOPEN="NO"
    if [[ -z "$(p4 -c ${UEP4CLIENT} opened)" ]] 2>/dev/null; then 
        P4ANYFILESOPEN="NO"
    else
        P4ANYFILESOPEN="YES"
    fi

    P4DEFFILESOPEN="NO"
    if [[ -z "$(p4 -c ${UEP4CLIENT} opened -c default)" ]] 2>/dev/null; then 
        P4DEFFILESOPEN="NO"
    else
        P4DEFFILESOPEN="YES"
    fi

    if [ "$P4DEFFILESOPEN" == "YES" ] || [ "$P4ANYFILESOPEN" == "YES" ]; then
        RED='\033[0;31m'
        NC='\033[0m' # No Color
        printf "  ${RED}CAUTION!${NC} File(s) open in Default Changelist: ${RED}${P4DEFFILESOPEN}${NC} .. File(s) open in any Changelist: ${RED}${P4ANYFILESOPEN}${NC} \n"
        if [ "$P4DEFFILESOPEN" == "YES" ]; then
            printf "     * Any files in the default changelist will be moved to the final CL when using this command.\n"
        fi

        if [ "$P4ANYFILESOPEN" == "YES" ]; then
            printf "     * It is recommended to shelve or revert all files on this workspace before running Clang on the full Source directory, to avoid conflicts and unintentional checkins.\n"
        fi

        #echo "    Continue? (y)es / (n)no: "
        while true; do
            read -p "    Continue? (y)es / (n)no: " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) echo " ..exiting without doing anything.. "; return;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
    ##################### Check for open p4 files. End.

    # Set the P4 Host
    p4sethost
    
    printf "\nRun Clang-Format on Source: \n"

    cd $DEVPATH
    
    ### Find all appropriate code files in the source directory
    FIND_OUTPUT="$(find Source -regex '.*\.\(cpp\|hpp\|h\|cc\|inl\|cxx\)')"
    FIND_OUTPUT_COUNT="$(echo "${FIND_OUTPUT}" | wc -l)"

    ### Do the P4 Checkout on the list.
    FILE_ITERATION=0
    printf "     Checking out Source Directory...\n"
    echo -e "         .. ${FILE_ITERATION} / ${FIND_OUTPUT_COUNT}" 
    for i in $FIND_OUTPUT; do # Not recommended, will break on whitespace
        FILE_ITERATION=$((FILE_ITERATION+1))
        runClangOnSource_convertToWinPathAndCheckout "$i" ${FILE_ITERATION} ${FIND_OUTPUT_COUNT}
    done
    echo -e "         .. Complete!" 

    ### Do the Clang Format on the list
    FILE_ITERATION=0
    printf "     Running Clang Format on source...\n"
    echo -e "         .. ${FILE_ITERATION} / ${FIND_OUTPUT_COUNT}" 
    for i in $FIND_OUTPUT; do # Not recommended, will break on whitespace
        FILE_ITERATION=$((FILE_ITERATION+1))
        runClangOnSource_formatFile "$i" ${FILE_ITERATION} ${FIND_OUTPUT_COUNT}
    done
    echo -e "         .. Complete!" 

    ### Revert unchanged and move to new CL
    printf "     Reverting unchanged files...\n"
    REVERT_UNCHANGED_OUTPUT="$(p4 -c ${UEP4CLIENT} revert -a)"
    if [ "$REVERT_UNCHANGED_OUTPUT" == "" ] ; then
        REVERT_UNCHANGED_COUNT=0
    else
        REVERT_UNCHANGED_COUNT="$(echo "${REVERT_UNCHANGED_OUTPUT}" | wc -l)"
    fi
    OPENED_DEFAULT_OUTPUT="$(p4 -c ${UEP4CLIENT} opened -c default)"
    printf "         .. Complete! Reverted %d files. \n\n" $REVERT_UNCHANGED_COUNT

    if [ "$OPENED_DEFAULT_OUTPUT" == "" ] ; then
        printf " Clang Format Complete! No Files effected by Clang Format."
    else
        OPENED_DEFAULT_COUNT="$(echo "${OPENED_DEFAULT_OUTPUT}" | wc -l)"
        p4 --field "Description=Clang-Format run on Source directory. ${OPENED_DEFAULT_COUNT} files effected." -c ${UEP4CLIENT} change -o | p4 -c ${UEP4CLIENT} change -i > /dev/null 2>&1
        printf " Clang Format Complete! Effected %d files and put in a new Perforce CL. Please examine and submit if desired!" ${OPENED_DEFAULT_COUNT}
    fi
}

## PC Shutdown / Restart / Signout shortcuts
function hard_shutdown() {
    shutdown /s /f /t 0
}

function hard_restart() {
    shutdown /r /f /t 0
}

function signout() {
    shutdown -l
}

################################### Fast Drive Symlink System.. Simple system to junction a workspace on a slow drive to a folder on a fast drive
function fstlink() {
    # fastlink - check to see if we are linked already or not with link lock file.
    checkForLinkLock
    
    if [ $LINK_LOCK_FOUND -eq 1 ]; then
        echo " ERROR: fstlink failed - symlink already created! Either it has alredy been made or there is an artificial/incorrect .linklock file"
        return 0
    fi

    #echo " continue with fstlink!"
    cd $DEVPATH

    # figure out source(slow) and dest(fast) directories
    findFastLinkDirs

    # delete dest folder
    rm -rf ${FAST_LINK_DEST_FAST_DIR}

    # copy source(slow) -> dest(fast)
    echo "Copying directories: ${FAST_LINK_SRC_SLOW_DIR} --> ${FAST_LINK_DEST_FAST_DIR}"
    rsync -a --info=progress2 ${FAST_LINK_SRC_SLOW_DIR}/ ${FAST_LINK_DEST_FAST_DIR}/

    # Go up one directory so we can make the junction in the right place
    cd ../

    # Beware! Delete Source directory :|
    rm -rf ${FAST_LINK_SRC_SLOW_DIR}

    # Make Junction
    cmd.exe /c mklink /J ${FAST_LINK_LAST_DIR_NAME} ${FAST_LINK_DEST_FAST_WIN_DIR}

    # add link lock
    addLinkLock

    echo $'\nSUCCESS! Fast Link completed.'
}

function fstunlink() {
    # fastunlink - check to see if we are linked already or not with the link lock file
    checkForLinkLock

    if [ $LINK_LOCK_FOUND -eq 0 ]; then
        echo " ERROR: fstunlink failed - no symlink created! Either there isn't one or the .linklock file has been mucked with!"
        return 0
    fi

    #echo " continue with fstunlink!"
    cd $DEVPATH

    # figure out source(slow) and dest(fast) directories
    findFastLinkDirs

    # UnMake Junction (go up one directory then rm file)
    cd ../
    rm -f ${FAST_LINK_LAST_DIR_NAME}
    echo "Junction removed."
    
    # delete source folder
    rm -rf ${FAST_LINK_SRC_SLOW_DIR}

    # copy dest(fast) -> source(slow)
    echo "Copying directories: ${FAST_LINK_DEST_FAST_DIR} --> ${FAST_LINK_SRC_SLOW_DIR}"
    rsync -a --info=progress2 ${FAST_LINK_DEST_FAST_DIR}/ ${FAST_LINK_SRC_SLOW_DIR}/

    # delete dest
    rm -rf ${FAST_LINK_DEST_FAST_DIR}

    # remove link lock
    removeLinkLock

    echo $'\nSUCCESS! Fast Unlink completed.'
}

### check for the link lock file and set LINK_LOCK_FOUND to 0 or 1 depending on if found
function checkForLinkLock() {
    #echo " - Checking for Link Lock file.. "
    LINK_LOCK_FOUND=0
    linkLockTestFile="${DEVPATH}/.linklock"
    if test -f "${linkLockTestFile}"; then
        LINK_LOCK_FOUND=1
    fi
    #echo " - Link Lock File Found: ${LINK_LOCK_FOUND}"
}

### Find the Source (Slow) and Dest (Fast) Directories to use for the current workspace Fast Symlink stuff
function findFastLinkDirs() {

    FAST_LINK_LAST_DIR_NAME=${DEVPATH}
    shopt -s extglob           # enable +(...) glob syntax
    FAST_LINK_LAST_DIR_NAME=${FAST_LINK_LAST_DIR_NAME%%+(/)}    # trim however many trailing slashes exist
    FAST_LINK_LAST_DIR_NAME=${FAST_LINK_LAST_DIR_NAME##*/}       # remove everything before the last / that still remains
    
    # Fast Dest Directory is the symlink dir, then a folder in that that is named *workspace_letter*.*final_dev_path_folder_name*
    FAST_LINK_DEST_FAST_DIR="${FAST_SYMLINK_DIR}/${CUR_WORKSPACE_LETTER}.${FAST_LINK_LAST_DIR_NAME}"
    
    # Slow Source Directory is just the dev path :D
    FAST_LINK_SRC_SLOW_DIR=${DEVPATH}

    FAST_LINK_DEST_FAST_WIN_DIR=$(cygpath -w ${FAST_LINK_DEST_FAST_DIR})

    #echo " - Find Fast Link dirs:"
    #echo "       Source (slow): ${FAST_LINK_SRC_SLOW_DIR}"
    #echo "         Dest (fast): ${FAST_LINK_DEST_FAST_DIR}"
    #echo "   Dest (fast) - WIN: ${FAST_LINK_DEST_FAST_WIN_DIR}"
}

### Add the link lock file
function addLinkLock() {
    #echo " - Add Link Lock File"
    cd $DEVPATH
    touch .linklock
}


### Remove the link lock file
function removeLinkLock() {
    #echo " - Remove Link Lock File"
    cd $DEVPATH
    rm .linklock
}