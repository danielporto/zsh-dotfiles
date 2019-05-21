# zmodload zsh/zprof 
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
autoload -Uz compinit 
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
	compinit;
else
	compinit -C;
fi;

# alias
# disabled for testing - zplug "MichaelAquilina/zsh-you-should-use"
# disabled for testing - zplug "plugins/common-aliases", from:oh-my-zsh


# terminal autocompleat
#zplug "plugins/compleat", from:oh-my-zsh 
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
# zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh
# zplug "plugins/compleat", from:oh-my-zsh

#zsh-completions
fpath=(/usr/local/share/zsh-completions $fpath)


# avoid other compleat plugins such as zplug "zsh-users/zsh-completions"
# they cause conflicts with tab completion and tmux
# other terminal stuff
# disabled for testing - zplug "plugins/sudo", from:oh-my-zsh
# disabled for testing - zplug "plugins/gnu-utils", from:oh-my-zsh
# disabled for testing - zplug "hlissner/zsh-autopair", defer:2
# zplug "lib/clipboard", from:oh-my-zsh


# for specific apps
zplug "plugins/docker", from:oh-my-zsh
# disabled for testing - zplug "plugins/docker-compose", from:oh-my-zsh
# disabled for testing - zplug "Cloudstek/zsh-plugin-appup"
# disabled for testing - zplug "rawkode/zsh-docker-run"
# disabled for testing - zplug "plugins/httpie", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "unixorn/tumult.plugin.zsh"
# disabled for testing - zplug "qianxinfeng/zsh-vscode"
#zplug "plugins/extract", from:oh-my-zsh, defer:0
#zplug "plugins/gradle", from:oh-my-zsh, defer:0
#zplug "plugins/kubectl", from:oh-my-zsh, defer:0
#zplug "plugins/terraform", from:oh-my-zsh, defer:0
#zplug "plugins/yarn", from:oh-my-zsh, defer:0


# for specific commands
# disabled for testing - zplug "lib/grep", from:oh-my-zsh
# disabled for testing - zplug "plugins/cp", from:oh-my-zsh
# disabled for testing - zplug "rummik/zsh-ing"

# git
# disabled for testing - zplug "plugins/git-extras", from:oh-my-zsh
# disabled for testing - zplug "plugins/git-flow", from:oh-my-zsh
zplug "plugins/github", from:oh-my-zsh
zplug "peterhurford/git-it-on.zsh"

# python
# disabled for testing - zplug "plugins/pip", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh

# osx
zplug "plugins/brew", from:oh-my-zsh, if:"[ $isOSX = true ]"
zplug "plugins/osx", from:oh-my-zsh, if:"[ $isOSX = true ]"
zplug "pstadler/8209487", \
    from:gist, \
    as:plugin, \
    use:brew-cask.plugin.zsh, if:"[ $isOSX = true ]"

# colors
# disabled for testing - zplug "seebi/dircolors-solarized"
# disabled for testing - zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh

# file system
# disabled for testing - zplug "plugins/dirpersist", from:oh-my-zsh
zplug "mfaerevaag/wd", as:command, use: 'wd.sh', hook-load:" wd() { . $ZPLUG_REPOS/mfaerevaag/wd/wd.sh } "
zplug "plugins/per-directory-history", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
# zplug "zdharma/fast-syntax-highlighting", defer:3
zplug "zsh-users/zsh-history-substring-search", defer:3

# disabled for testing - zplug "mafredri/zsh-async", from:github

# main theme
# bad: 

# untested
# zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
# zplug "themes/fishy", from:oh-my-zsh
# zplug 'dracula/zsh', as:theme
# zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme



# good
# zplug "themes/pygmalion", from:oh-my-zsh, as:theme
# zplug "themes/sporty_256", from:oh-my-zsh, as:theme
# zplug "themes/steeef", from:oh-my-zsh, as:theme
# zplug "oskarkrawczyk/honukai-iterm-zsh", use:honukai.zsh-theme,  from:github, as:theme
# zplug "eendroroy/alien-minimal", as:theme
zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme, as:theme

# customization examples: https://github.com/bhilburn/powerlevel9k/wiki/Show-Off-Your-Config
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_COLOR_SCHEME='light'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon virtualenv context dir vcs root_indicator newline)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time  background_jobs time)
POWERLEVEL9K_VIRTUALENV_BACKGROUND='springgreen4'
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND='springgreen3'
POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND='black'
POWERLEVEL9K_DIR_HOME_BACKGROUND='springgreen2'
POWERLEVEL9K_DIR_HOME_FOREGROUND='black'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='springgreen2'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='black'
POWERLEVEL9K_OS_ICON_BACKGROUND='grey0'
POWERLEVEL9K_OS_ICON_FOREGROUND='deepskyblue3'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='green'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='grey11'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='grey11'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='red'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='grey11'
POWERLEVEL9K_STATUS_OK_BACKGROUND='springgreen2'
POWERLEVEL9K_STATUS_OK_FOREGROUND='black'
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='red'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='black'


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
# disabled for testing - eval `dircolors -b $ZPLUG_HOME/repos/seebi/dircolors-solarized/dircolors.256dark`

# from https://github.com/zsh-users/zsh-history-substring-search/issues/59
# zsh-history-substring-search configuration
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
# zmodload zsh/terminfo
#bindkey "$terminfo[kcuu1]" history-substring-search-up
#bindkey "$terminfo[kcud1]" history-substring-search-down

# navigation keys in iterm - https://coderwall.com/p/a8uxma/zsh-iterm2-osx-shortcuts
# bindkey "[D" backward-word
# bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line


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
export PATH="$HOME/.jenv/bin:$PATH"

unsetopt cdable_vars
unsetopt auto_name_dirs

zplug load
eval "$(jenv init -)"
################################################################################


source $HOME/.profile

# zprof
