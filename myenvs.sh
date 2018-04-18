export GOPATH="$HOME/devel/gocode"
export PATH=$PATH:$GOPATH/bin

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


if [ "$isOSX" = true ]; then
    export PATH="/usr/local/opt/python@2/libexec/bin":$PATH
    # for java management
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi


# read other envs with keys and stuff
if [ -e $HOME/.ssh/sensible-envs.sh ]; then 
    source $HOME/.ssh/sensible-envs.sh
fi