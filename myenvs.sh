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


export GOPATH="$HOME/devel/gocode"
export PATH=$PATH:$GOPATH/bin

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