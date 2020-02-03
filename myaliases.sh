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


DOTFILES_ROOT="$HOME/.dotfiles"

# mac environment reinstall
function mac_restore_packages {
  if [ "$isOSX" = false ]; then
    echo "Ignoring command, not OSX."
    return -1
  fi  
  
  HOMEBRW_BIN=`which brew`
  if [ ! -e $HOMEBRW_BIN ]; then
        echo 'install homebrew as: /usr/bin/ruby -e "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
        return -1
  fi 
  cd $DOTFILES_ROOT && brew bundle  
}




function mac_backup_packages {
  if [ "$isOSX" != true  ]; then
    echo "Ignoring command, not OSX."
    return -1
  fi  
  
  HOMEBRW_BIN=`which brew`
  if [ ! -e $HOMEBRW_BIN ]; then
        echo 'install homebrew as: /usr/bin/ruby -e "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
        return -1
  fi 
  CURRENT=$PWD 
  cd $DOTFILES_ROOT && mv Brewfile Brewfile.bak && brew bundle dump
  echo "Remember to push updates back to repository! ( dotfiles_update && dotfiles_push )"
  cd $CURRENT
}

function brewbackup {
  mac_backup_packages;
}

function mac_update_packages {
  if [ "$isOSX" != true  ]; then
    echo "Ignoring command, not OSX."
    return -1
  fi  
  
  HOMEBRW_BIN=`which brew`
  if [ ! -e $HOMEBRW_BIN ]; then
        echo 'install homebrew as: /usr/bin/ruby -e "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
        return -1
  fi 
  brew cu $1 $2 $3
  echo "-------------------------------------------------------------"
  echo "To force update: mac_update_packages -y -a -f"
  echo "-------------------------------------------------------------"

  cd $CURRENT
}


function dotfiles_pull {
  CURRENT=$PWD 
  cd $DOTFILES_ROOT && git pull --rebase
  cd $CURRENT
}

function dotfiles_update {
   CURRENT=$PWD 
   DAY=$(date "+%H:%M:%S   %d/%m/%y")
   cd $DOTFILES_ROOT && git add -A && git commit -m "Update $DAY $1" 
   cd $CURRENT
}

function dotfiles_push {
   CURRENT=$PWD 
   cd $DOTFILES_ROOT && git push
   cd $CURRENT
}

function dotfiles_status {
   CURRENT=$PWD 
   cd $DOTFILES_ROOT && git status
   cd $CURRENT
}

function dotfiles_changes {
   CURRENT=$PWD 
   cd $DOTFILES_ROOT && git diff -r 
   cd $CURRENT
}

function dotfiles_dependecies_install {
   vim +PlugInstall +qall \
   && ~/.vim/plugged/youcompleteme/install.py --clang-completer
}

# docker
alias c='docker-compose'
alias cb='docker-compose build'
alias cup='docker-compose up'
alias cr='docker-compose run --service-ports --rm'
alias crl='docker-compose run --service-ports --rm local'
alias crd='docker-compose run --service-ports --rm develop'
alias crt='docker-compose run --rm test'
alias crp='docker-compose run --rm provision'
alias crci='docker-compose run --rm ci'
alias crwt='docker-compose run --rm watchtest'
alias cps='docker-compose ps'
alias clogs='docker-compose logs'
alias dockerdaemontcp='socat TCP-LISTEN:2375,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock'

crm(){
	docker-compose stop $1
	docker-compose rm --force $1
}

dockerpurge() {
  docker-compose down &> /dev/null
  docker ps -aq --no-trunc | xargs docker rm
  docker images -aq | xargs docker rmi --force
  for i in `docker volume ls -qf dangling=true`; do docker volume rm $i; done
}

dockercleanup() {
  docker-compose down &> /dev/null
  docker ps -aq --no-trunc | xargs docker rm
  for i in `docker images|grep \<none\>|awk '{print $3}'`;do docker rmi -f $i;done
  for i in `docker volume ls -qf dangling=true`; do docker volume rm $i; done
}


# ssh - deprecated. use stormssh instead
alias sshunsafe='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sshfs='sshfs -o max_readahead=32768,max_read=65536,max_write=8192 -o auto_cache -o reconnect'

# tmux shortcuts
alias mmmm="tmux"
alias mmm="tmux attach || tmux new"
alias mux='tmux'
alias muxx='tmux choose-tree'
alias muxs='tmux choose-tree'
alias muxls='tmux list-sessions'
alias muxrld='kill -9 `pidof tmux`'
alias muxrntab='tmux rename-window'
alias muxrnsession='tmux rename-session'
alias muxrnsession='tmux rename-session'
alias muxneewsession='tmux new-session -d -s '
alias muxkill='tmux kill-session -t'

# Restart facetime without rebooting the system
alias facetimekill='sudo killall VDCAssistant'

# Remove all items safely, to Trash
#alias rrm='rm'
#alias rm='trash'

# Always use color output for `ls`
#alias ls="command ls ${colorflag}"
#alias ls="ls -G --color"

# brew ctags default to brew one
# alias ctags="`brew --prefix`/bin/ctags"

# maven uses 1 thread per core per default
alias mvn="mvn -T 1C"

alias play='ansible-playbook'
alias cls='clear'
alias xx='clear'
alias xxx='exit'
alias qq='exit'
alias youtube-dl-pl='youtube-dl -o "%(playlist_index)s-%(title)s.%(ext)s" -f mp4 '
alias gsd_cluster_vpn='sshuttle -r dporto@cloudtm.ist.utl.pt -e "ssh -i ~/.ssh/id_rsa_inesc_cluster_dporto"  10.100.0.0/24 -D'
