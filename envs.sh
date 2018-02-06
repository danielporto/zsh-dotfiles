


export GOPATH="$HOME/devel/gocode"
export PATH=$PATH:$GOPATH/bin

# # for java management
# export PATH="$HOME/.jenv/bin:$PATH"
# eval "$(jenv init -)"

export HOMEBREW_GITHUB_API_TOKEN="fd700f1f835dc28f3b41eb9f90db3ad40ae4616f"
# read other envs with keys and stuff
if [ -n $HOME/.ssh/sensible-envs.sh ]; then 
    source $HOME/.ssh/sensible-envs.sh
fi