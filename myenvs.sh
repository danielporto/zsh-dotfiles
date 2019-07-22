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
    # Link Homebrew casks in `/Applications` rather than `~/Applications`
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"

    # fish shell osx compatible binaries
    # fix https://stackoverflow.com/questions/10666570/binutils-stat-illegal-option-c
    # https://techblog.willshouse.com/2013/05/20/brew-install-gnu-stat/
    export PATH="/usr/local/opt/binutils/bin:$PATH"
    # export LDFLAGS="-L/usr/local/opt/binutils/lib"
    # export CPPFLAGS="-I/usr/local/opt/binutils/include"
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    alias stat="gstat"

fi

# for java management
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH=$HOME/local/flutter/bin:$PATH

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Make vim the default editor
export EDITOR="vim"

# Prefer US English and use UTF-8
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Highlight section titles in manual pages
export LESS_TERMCAP_md="$ORANGE"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"


# compilers
# libxml2 is keg-only, which means it was not symlinked into /usr/local,
# because macOS already provides this software and installing another version in
# parallel can cause all kinds of trouble.
export PATH="/usr/local/opt/libxml2/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/libxml2/lib"
export CPPFLAGS="-I/usr/local/opt/libxml2/include"
export PKG_CONFIG_PATH="/usr/local/opt/libxml2/lib/pkgconfig"

# java SDK
export ANT_HOME=/usr/local/opt/ant
export MAVEN_HOME=/usr/local/opt/maven
export GRADLE_HOME=/usr/local/opt/gradle

# android SDK
#export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
export ANDROID_SDK_ROOT=/Volumes/data/Users/dan/Library/Android/sdk
export PATH=$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools:$PATH

# General paths
export PATH=$ANT_HOME/bin:$PATH
export PATH=$MAVEN_HOME/bin:$PATH
export PATH=$GRADLE_HOME/bin:$PATH
#zprof
export PATH="/usr/local/opt/libxslt/bin:$PATH"
export PATH="$PATH":"$HOME/.pub-cache/bin"




# read other envs with keys and stuff
if [ -e $HOME/.ssh/sensible-envs.sh ]; then 
    source $HOME/.ssh/sensible-envs.sh
fi




