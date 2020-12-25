# shellcheck disable=SC2148
# /etc/skel/.bashrc
# This bashrc file is created by Chawye Hsu, licensed under the WTFPL license.
#------------------------------------------------------------------------------#
# Support Platforms:
#    Windows: Git-Bash/MSYS2/MinGW
#      macOS: Bash
#      Linux: Bash
#------------------------------------------------------------------------------#
# Test for an interactive shell.
[[ $- != *i* ]] && return
#-----------------------#
# Environment Variables #
#-----------------------#
export LANG=en_US.UTF-8
export TZ=UTC-8
# default editor
export EDITOR=nano
# Always display git dirty state
export GIT_PS1_SHOWDIRTYSTATE=1
# Enable Node.js (chalk) color
export FORCE_COLOR=1
# Xterm colors
if [[ "$TERM" == "xterm" ]]; then
  export TERM=xterm-256color
fi
# PATH updates - Add `~/.local/bin`:
_localbin="$HOME/.local/bin"
if [[ -d $_localbin && ":$PATH:" != *":$_localbin:"* ]]; then
  export PATH="$_localbin:$PATH"
fi
# PATH updates -
case "$OSTYPE" in
  darwin*)
    # NOTES: macOS's default PATH (definition in `/etc/paths`):
    #   "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    #
    # A `/Library/Apple/usr/bin` path will be added when the
    # Xcode command line tools is installed.

    # PATH updates - Add super bin directory installed by Homebrew:
    if [[ -d "/usr/local/sbin" && ":$PATH:" != *":/usr/local/sbin:"* ]]; then
      export PATH="/usr/local/sbin:$PATH"
    fi

    # bash-completion:
    if [[ -f "/usr/local/etc/bash_completion" ]]; then
      # shellcheck disable=SC1091
      . /usr/local/etc/bash_completion
    fi

    # Programming-Languages-Specific settings
    # ---------------------------------------
    # Python: Add miniconda
    if [[ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]]; then
      # shellcheck disable=SC1091
      . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    elif [[ -d "/usr/local/Caskroom/miniconda/base/bin" ]]; then
      export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
    fi
    # Ruby: Add rbenv
    command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"
    ;;
  linux*)
    # PATH updates - Add `~/.linuxbrew/bin` (Linuxbrew bin):
    _linuxbrew="$HOME/.linuxbrew/bin"
    if [[ -d $_linuxbrew && ":$PATH:" != *":$_linuxbrew:"* ]]; then
      export PATH="$_linuxbrew:$PATH"
    fi

    # Add git-prompt (Arch Linux):
    if [[ -f "/usr/share/git/completion/git-prompt.sh" ]]; then
      # shellcheck disable=SC1091
      . /usr/share/git/completion/git-prompt.sh
    fi

    # Programming-Languages-Specific settings
    # ---------------------------------------
    # Python: Add miniconda
    if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
      # shellcheck disable=SC1090
      . "$HOME/miniconda3/etc/profile.d/conda.sh"
    elif [[ -d "$HOME/miniconda3/bin" ]]; then
      export PATH="$HOME/miniconda3/bin:$PATH"
    fi
esac
#-----------#
# Dircolors #
#-----------#
# requirement for macOS: install GNU gdircolors with `brew install coreutils`
command -v gdircolors >/dev/null 2>&1 || alias gdircolors="dircolors"
[[ -f "$HOME/.dircolorsdb" ]] && eval "$(gdircolors -b $HOME/.dircolorsdb)"
#---------------#
# Unify Aliases #
#---------------#
lsoption="-F --show-control-chars --group-directories-first --color=auto"
# Provide an uniform `ls` command on all platforms
case "$OSTYPE" in
  darwin*)
    # requirement for macOS: install GNU ls with `brew install coreutils`
    alias ls="gls $lsoption"
    ;;
  linux*)
    alias ls="ls $lsoption"
    ;;
  msys*)
    # There are too many unconcerned files and directories in Windows users' home, ignore them.
    alias ls="ls $lsoption --ignore={navdb.csv,NTUSER*,ntuser*,Application\ Data,Local\ Settings,My\ Documents,NetHood,PrintHood,Recent,SendTo,Templates,Cookies,3D\ Objects,Thumbs.db,desktop.ini,Start\ Menu,「开始」菜单}"
    ;;
esac
unset lsoption
alias l="ls"
alias la="ls -A"
alias ll="ls -lh"
alias lla="ls -lhA"
alias c="clear"
alias :q="exit"
alias ..="cd .."
alias ...="cd ../.."
alias gdf="git diff"
alias gst="git status"
alias myip="curl -s https://api.ip.sb/ip"
# Provide an uniform `cls` command on all platforms
alias cls="clear"
case "$OSTYPE" in
  darwin*)
    alias here="open ."
    ;;
  msys*)
    # winpty fixes
    alias ipconfig="winpty ipconfig"
    alias nslookup="winpty nslookup"
    alias ping="winpty ping"
    alias java="winpty java"
    alias python="winpty python"
    alias pip="winpty pip"
    # Emulate ifconfig on Windows MSYS
    alias ifconfig="ipconfig"
    # Open window is only available on macOS, emulate it on Windows MSYS,
    # but not on Linux, since I don't use GUI on Linux.
    alias open="explorer"
    alias here="open ."
    ;;
esac
#---------------------------------------#
# SSH Agent on Windows (Git-Bash/MSYS2) #
#---------------------------------------#
# ref: https://help.github.com/articles/working-with-ssh-key-passphrases/#auto-launching-ssh-agent-on-git-for-windows
if [[ $OSTYPE == "msys" ]] && [[ -x "$(command -v ssh)" ]]; then
  # ensure .ssh path
  # we use $USERPROFILE instead of $HOME to locate SSH ENV,
  # so we can share ssh keys between Win32-OpenSSH and openssh(Git-Bash & MSYS2)
  if [[ ! -d "${USERPROFILE//\\//}/.ssh" ]]; then
    mkdir -p "${USERPROFILE//\\//}/.ssh" >| /dev/null
  fi
  # test ssh is Win32-OpenSSH or not
  if [[ ! "$(ssh -V 2>&1)" == *Windows* ]]; then
    # we use $USERPROFILE instead of $HOME to locate SSH ENV,
    # so we can share ssh env between Git-Bash and MSYS2,
    # but be aware of that Win32-OpenSSH does not use SSH ENV
    SSH_ENV_PATH="${USERPROFILE//\\//}/.ssh/agent.env"
    # load ssh env
    [[ -f "$SSH_ENV_PATH" ]] && . "$SSH_ENV_PATH" >| /dev/null
    # agent_run_state:
    #   0=agent running w/ key;
    #   1=agent w/o key;
    #   2=agent not running.
    agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
    if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
      (umask 077; ssh-agent >| "$SSH_ENV_PATH") && . "$SSH_ENV_PATH" >| /dev/null
      ssh-add
    elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
      ssh-add
    fi
    unset SSH_ENV_PATH
  else
    ssh-agent >| /dev/null
    ssh-add
  fi
fi
#-------------------------------------#
# Program-languages specific settings #
#-------------------------------------#
# NONE


#----------------------------#
# The Chawye's styled prompt #
#----------------------------#
function styled_prompt() {
  # Color table
  local   RESET="\[\033[0m\]"
  local   BLACK="\[\033[0;30m\]"
  local     RED="\[\033[0;31m\]"
  local   GREEN="\[\033[0;32m\]"
  local  YELLOW="\[\033[0;33m\]"
  local    BLUE="\[\033[0;34m\]"
  local MAGENTA="\[\033[0;35m\]"
  local    CYAN="\[\033[0;36m\]"
  local   WHITE="\[\033[0;37m\]"
  # Terminal title
  local TERM_TITLE="\[\e]0; \w\a\]"

  # Special system environment detection: WSL, MSYS2/MinGW
  if [[ "$(uname -r)" == *icrosoft ]]; then
    DIST="${MAGENTA}(WSL)${RESET}"
  elif [[ $MSYSTEM ]]; then
    DIST="${MAGENTA}($MSYSTEM)${RESET}"
  else
    DIST=""
  fi

  # git-prompt
  if [[ -x "$(command -v __git_ps1)" ]]; then
    GITPROMPT="$(__git_ps1 ' (%s)')"
  else
    GITPROMPT=""
  fi

  # Python virtualenv state (Deprecated, since we use conda envs...)
  if [[ -z "${VIRTUAL_ENV}" ]]; then
    VIRTUALENV=""
  else
    VIRTUALENV=" ${BLUE}[$(basename ${VIRTUAL_ENV})]${RESET}"
  fi

  # PS1 command substitution issue with newline:
  #   https://stackoverflow.com/questions/33220492/
  #   https://stackoverflow.com/questions/21517281/
  PS1="${TERM_TITLE}${GREEN}\h${DIST}: ${YELLOW}\W${CYAN}${GITPROMPT}${RESET}${VIRTUALENV}"$'\n\$ '
}
styled_prompt
