export GOPATH="$HOME/devel/gocode"
export PATH=$PATH:$GOPATH/bin

# What OS are we in?
isOSX=1
isLinux=1
isLinux32=1
isLinux64=1
isDocker=1
isRaspberry=1

case "$OSTYPE" in
    darwin*) #echo "It's a Mac!!" ;
             isOSX=0 ;
             ;;        
    linux*) isLinux=0 ;
            #echo "It's a Linux!!" ;
            # test for 32bit architecture
            if [[ ! $(uname -a | grep "[i686]") ]]; then  isLinux32=0 fi ;
            # test for 64bit architecture
            if [[ ! $(uname -a | grep "[x86_64]") ]]; then isLinux64=0  fi ;
            # test for arm raspberry pi architecture
            if [[ ! $(uname -a | grep "[armv7]") ]]; then isRaspberry=0  fi ;
            # test for container
            if [[ ! $(cat /proc/1/cgroup | grep "[docker]") ]]; then isDocker=0  fi ;
            ;;
    *) echo "System not recognized"; exit 1 ;
        ;;
esac

if [ isOSX ]; then
    export PATH="/usr/local/opt/python@2/libexec/bin":$PATH
    # for java management
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi


# read other envs with keys and stuff
if [ -e $HOME/.ssh/sensible-envs.sh ]; then 
    source $HOME/.ssh/sensible-envs.sh
fi