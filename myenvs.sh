


export GOPATH="$HOME/devel/gocode"
export PATH=$PATH:$GOPATH/bin

# # for java management
# export PATH="$HOME/.jenv/bin:$PATH"
# eval "$(jenv init -)"

# read other envs with keys and stuff
if [ -e $HOME/.ssh/sensible-envs.sh ]; then 
    source $HOME/.ssh/sensible-envs.sh
fi