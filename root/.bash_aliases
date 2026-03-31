# ~/.bash_aliases

# Directory Navigation
# Pattern: gT<name> = cd to project directory
alias gTever-ready='cd ~/repos/ever-ready-frontend'
alias gTelai='cd ~/bloop/elai'
alias gTordelo='cd ~/bloop/OrdeloAgent'

# Color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ls shortcuts
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alert for long running commands: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# AWS profiles
alias awsBtl='export AWS_PROFILE=byteloop && echo "Switched to BtyleLoop"'
alias awsErr='export AWS_PROFILE=err && echo "Switched to Err"'
alias awsErai='export AWS_PROFILE=erai && echo "Switched to Erai"'

# UI applications
alias pycharmOld="nohup /opt/pycharm-community-2021.1.3/bin/pycharm.sh </dev/null &>/dev/null &"
alias pycharm="nohup /opt/pycharm-community-2024.1.4/bin/pycharm.sh </dev/null &>/dev/null &"
alias dbeaver="nohup dbeaver </dev/null &>/dev/null &"
alias intellij="nohup /opt/idea-IC-211.7628.21/bin/idea.sh </dev/null &>/dev/null &"

# Git - Basics
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'

# Git - Branches
alias gb='git branch'
alias gbd='git branch -d'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'

# Git - Remote
alias gp='git pull'
alias gP='git push'
alias gPf='git push --force-with-lease'
alias gf='git fetch'
alias gfa='git fetch --all'

# Git - Log
alias gl='git log --oneline'

# Git - TUI
alias lg='lazygit'

# Git - Restore
alias grs='git restore'
alias grss='git restore --staged'

# Docker
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drmi='docker rmi -f'

# Misc
alias reload='source ~/.bashrc'
alias aliases='cat ~/.bash_aliases'

# Dev workflow
alias setPyPath='export PYTHONPATH=$(pwd)'

# just
alias j='just'
alias jj='just --justfile ~/.justfile'
