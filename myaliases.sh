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
function restore_mac_packages {
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

function backup_mac_packages {
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

function update_mac_packages {
  if [ ! isOSX ]; then
    echo "Ignoring command, not OSX."
    return -1
  fi  
  
  HOMEBRW_BIN=`which brew`
  if [ ! -e $HOMEBRW_BIN ]; then
        echo 'install homebrew as: /usr/bin/ruby -e "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
        return -1
  fi 
  brew cu -y
  echo "To force update: brew cu -a -f"
  cd $CURRENT
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
  docker images -aq | xargs docker rmi
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
alias sshoc='ssh dporto@146.193.41.217'
alias sshpi='ssh pi@146.193.41.244'
#alias sshmpi="ssh -A -t contact.mpi-sws.org ssh -A -t "
#alias sshmpi-tmux=tmux-cssh -ss "ssh -A -t contact.mpi-sws.org ssh -A -t "
#alias sshmpitmux=tmux-cssh -ss "ssh -A -t contact.mpi-sws.org ssh -A -t "
alias sshmpitunnel="ssh -fND 1080 contact.mpi-sws.org "


# alias setgopath='export GOPATH=`pwd` ; export PATH=$GOPATH/bin:$PATH'
# alias cdgopath='cd $HOME/devel/gocode'
# alias cdgopathcurrent='cd $GOPATH'

# custom
synch_kaioken () {
  rsync -avz -e ssh $HOME/devel/wksp_vftsprint/prj_vftsprint/code/kaiokengov dporto@146.193.41.217:/home/dporto/kaioken/kaioken_sync  
}

alias tmuxrestart='kill -9 `pidof tmux`'


