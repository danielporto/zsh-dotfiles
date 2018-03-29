function isOSX {
    case "$OSTYPE" in
        darwin*) return 0 ;;
        *) return 1 ;;
    esac
}

function isLinux {
    case "$OSTYPE" in
        linux*) return 0 ;;
        *) return 1 ;;
    esac
}

function isDocker {
 isLinux && \
    if [[ ! $(cat /proc/1/sched | head -n 1 | grep "[init|systemd]") ]]; then 
        return 0
    else 
        return 1
    fi
}


# mac environment reinstall
function mac_restore_packages {
  if [ ! isOSX ]; then
    echo "Ignoring command, not OSX."
    return -1
  fi  
  
  HOMEBRW_BIN=`which brew`
  if [ ! -e $HOMEBRW_BIN ]; then
        echo 'install homebrew as: /usr/bin/ruby -e "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
        return -1
  fi 
  cd $ZPLUG_ROOT/.. && brew bundle  
}

function mac_backup_packages {
  if [ ! isOSX ]; then
    echo "Ignoring command, not OSX."
    return -1
  fi  
  
  HOMEBRW_BIN=`which brew`
  if [ ! -e $HOMEBRW_BIN ]; then
        echo 'install homebrew as: /usr/bin/ruby -e "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
        return -1
  fi 
  CURRENT=$PWD 
  cd $ZPLUG_ROOT/.. && mv Brewfile Brewfile.bak && brew bundle dump
  echo "Remember to push updates back to repository!"
  cd $CURRENT
}

function mac_update_packages {
  if [ ! isOSX ]; then
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
  cd $ZPLUG_ROOT/.. && git pull --rebase
}

function dotfiles_update {
   $DAY=date "+%H:%M:%S   %d/%m/%y"
   cd $ZPLUG_ROOT/.. && git add -A && git commit -m "Update $DAY $1" 
}

function dotfiles_push {
   $DAY=date "+%H:%M:%S   %d/%m/%y"
   cd $ZPLUG_ROOT/.. && git push
}

function dotfiles_status {
   $DAY=date "+%H:%M:%S   %d/%m/%y"
   cd $ZPLUG_ROOT/.. && git status
}

function dotfiles_changes {
   $DAY=date "+%H:%M:%S   %d/%m/%y"
   cd $ZPLUG_ROOT/.. && git diff -r 
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

# alias setgopath='export GOPATH=`pwd` ; export PATH=$GOPATH/bin:$PATH'
# alias cdgopath='cd $HOME/devel/gocode'
# alias cdgopathcurrent='cd $GOPATH'

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



