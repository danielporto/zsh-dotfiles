
#zmodload zsh/zprof 
# What OS are we in?
# What OS are we in?
isOSX=false
isLinux=false
isLinux32=false
isLinux64=false
isDocker=false
isRaspberry=false

case "$OSTYPE" in
    darwin*) #echo "It's a Mac!!" ;
            isOSX=true ;;        
    linux*) isLinux=true ;
            #echo "It's a Linux!!" ;
            # test for 32bit architecture
            if [ -n "$(uname -a | grep 'i686')" ]; then  isLinux32=true; fi ;
            # test for 64bit architecture
            if [ -n "$(uname -a | grep '86_64')" ]; then isLinux64=true;  fi ;
            # test for arm raspberry pi architecture
            if [ -n "$(uname -a | grep 'armv7')" ]; then isRaspberry=true;  fi ;
            # test for container
            if [ -n "$(cat /proc/1/cgroup | grep 'docker')" ]; then isDocker=true;  fi ;;
    *) echo "System not recognized"; exit 1 ;;
esac

################################################################################
# General configuration
################################################################################
fpath=($fpath $HOME/.zsh/func)
typeset -U fpath
if $isOSX ;then
    # for brew zsh-completions
    fpath=(/usr/local/share/zsh-completions $fpath)
fi


# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"

# bash-like word delimiters
autoload -U select-word-style
select-word-style bash

# Set CLICOLOR if you want Ansi Colors in iTerm2
export CLICOLOR=1
# Set colors to match iTerm2 Terminal Colors
export TERM=xterm-256color


## History Configuration
HISTSIZE=5000
HISTFILE=~/.zsh_history
#Number of history entries to save to disk
SAVEHIST=5000
#Erase duplicates in the history file
HISTDUP=erase
# Make some commands not show up in history
HISTIGNORE="ls:cd -:pwd:exit:date:* --help"
#Append history to the history file (no overwriting)
setopt appendhistory
setopt sharehistory
setopt incappendhistory

# Theme settings
PURE_CMD_MAX_EXEC_TIME=10

################################################################################
# Plugins
################################################################################

# zplug settings
export ZPLUG_HOME=$HOME/.zplug
source $ZPLUG_HOME/init.zsh

# alias
zplug "MichaelAquilina/zsh-you-should-use"
zplug "plugins/common-aliases", from:oh-my-zsh

# terminal
zplug "plugins/compleat", from:oh-my-zsh 
# avoid other compleat plugins such as zplug "zsh-users/zsh-completions"
# they cause conflicts with tab completion and tmux
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/gnu-utils", from:oh-my-zsh
zplug "hlissner/zsh-autopair", defer:2
# zplug "lib/clipboard", from:oh-my-zsh


# for specific apps
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "Cloudstek/zsh-plugin-appup"
zplug "rawkode/zsh-docker-run"
zplug "plugins/httpie", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "unixorn/tumult.plugin.zsh"
zplug "qianxinfeng/zsh-vscode"
#zplug "plugins/extract", from:oh-my-zsh, defer:0
#zplug "plugins/gradle", from:oh-my-zsh, defer:0
#zplug "plugins/kubectl", from:oh-my-zsh, defer:0
#zplug "plugins/terraform", from:oh-my-zsh, defer:0
#zplug "plugins/yarn", from:oh-my-zsh, defer:0


# for specific commands
zplug "lib/grep", from:oh-my-zsh
zplug "plugins/cp", from:oh-my-zsh
zplug "rummik/zsh-ing"

# git
zplug "plugins/git-extras", from:oh-my-zsh
zplug "plugins/git-flow", from:oh-my-zsh
zplug "plugins/github", from:oh-my-zsh
zplug "peterhurford/git-it-on.zsh"

# python
zplug "plugins/pip", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh

# osx
zplug "plugins/brew", from:oh-my-zsh, if:"[ $isOSX = true ]"
zplug "plugins/osx", from:oh-my-zsh, if:"[ $isOSX = true ]"
zplug "pstadler/8209487", \
    from:gist, \
    as:plugin, \
    use:brew-cask.plugin.zsh, if:"[ $isOSX = true ]"

# colors
zplug "seebi/dircolors-solarized"
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh

# file system
zplug "plugins/dirpersist", from:oh-my-zsh
zplug "mfaerevaag/wd", as:command, use: 'wd.sh', hook-load:" wd() { . $ZPLUG_REPOS/mfaerevaag/wd/wd.sh } "
zplug "plugins/per-directory-history", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
# zplug "zdharma/fast-syntax-highlighting", defer:3
zplug "zsh-users/zsh-history-substring-search", defer:3

# main theme
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
# zplug "themes/fishy", from:oh-my-zsh

# zplug "themes/pygmalion", from:oh-my-zsh, as:theme
# zplug 'dracula/zsh', as:theme
# zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
# zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme

# Install plugins if there are plugins that have not been installed
if ! zplug check; then
    zplug install
fi

# Then, source plugins and add commands to $PATH
zplug load

# ########################
# after plugins configurations


# tab highlight colors
zstyle ':completion:*' menu select

# highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

# ls colors
eval `dircolors -b $ZPLUG_HOME/repos/seebi/dircolors-solarized/dircolors.256dark`

# from https://github.com/zsh-users/zsh-history-substring-search/issues/59
# zsh-history-substring-search configuration
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
# zmodload zsh/terminfo
#bindkey "$terminfo[kcuu1]" history-substring-search-up
#bindkey "$terminfo[kcud1]" history-substring-search-down

# Using hub feels best when it's aliased as git.
# Your normal git commands will all work, hub merely adds some sugar.
# THIS HAS TO BE AT THE END, otherwise package manager might not work
eval "$(hub alias -s)"

# init pyenv shims
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

export PATH="$HOME/bin:/usr/local/sbin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"


unsetopt cdable_vars
unsetopt auto_name_dirs

zplug load

################################################################################


#source $HOME/.profile

