# check if storm/veracrypt/rsync/gdrive are installed (use a docker container? no. because we need a container with it)
# check if the vault is in synch
# download the vault and extract the content to .ssh
# synchronize the content with the vault (rsync)
# upload the vault

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

GDRIVE_LOCAL_PATH="$HOME/.gdrive"
VAULT_GDRIVE_PATH=/Chaveiro/sshvault
VAULT_LOCAL_PATH=$GDRIVE_LOCAL_PATH/Chaveiro/sshvault
VAULT_LOCAL_MOUNTPATH=$HOME/.sshvault

LOCAL_BIN_PATH="$HOME/.local"
GDRIVE_CLI_BIN="gdrive"
GDRIVE_DOWNLOAD_URL=""
    
if  isOSX ; then
    export VERACRYPT_DOWNLOAD_URL="" #none, installed via homebrew
    export GDRIVE_DOWNLOAD_URL="https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_darwin"
    export VERACRYPT_CLI_BIN="/Applications/VeraCrypt.app/Contents/MacOS/VeraCrypt"
fi
if  isLinux ; then
    export VERACRYPT_DOWNLOAD_URL="https://launchpad.net/veracrypt/trunk/1.21/+download/veracrypt-1.21-setup.tar.bz2"
    export GDRIVE_DOWNLOAD_URL="https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_linux"
    export VERACRYPT_CLI_BIN=`which veracrypt`
fi


# internal stuff =======================================================================================
function check_dependencies {
    STATUS=0
    if [ ! -e $VERACRYPT_CLI_BIN ]; then
        echo "Error Veracrypt is not installed"
        $STATUS=1
    fi
    if [ ! -e "$LOCAL_BIN_PATH/gdrive" ]; then
        echo "Error, gdrive client is not installed. Install/initialize it: install_gdrive"
        $STATUS=1
    fi
    # TODO check if gdrive is initialized properly
    # TODO check if vim is installed
    # TODO check if tmux is installed
    # TODO check if sudo is installed
    # TODO check if user has sudo permissions 
    STORM=`which storm`
    if [ ! -e "$STORM" ]; then
        echo "Warning Stormssh is not installed"
    fi

    RSYNC=`which rsync`
    if [ ! -e "$RSYNC" ]; then
        echo "Error rsync is not installed"
        $STATUS=1
    fi
    CURL=`which curl`
    if [ ! -e "$CURL" ]; then
        echo "Error, curl client is not installed"
        $STATUS=1
    fi
    echo "Status: $STATUS"
    return $STATUS
}


# install veracrypt client -----------------------------------------------------------------------------
function install_veracrypt_mac {
    brew cask install veracrypt
    if [ ! -e $VERACRYPT_CLI_BIN ]; then
        echo "install Veracrypt with homebrew as: brew cask install veracrypt"
        return -1
    fi
}

function install_veracrypt_linux {
    if [ -e $VERACRYPT_CLI_BIN ]; then 
        echo "installing veracrypt for linux"
        mkdir -p $LOCAL_BIN_PATH/veracrypt
        
        # download
        $(isLinux64 | isLinux32)  && curl -L https://launchpad.net/veracrypt/trunk/1.22/+download/veracrypt-1.22-setup.tar.bz2 -o /tmp/veracrypt-setup.tar.bz2
        isLinuxRaspberry && curl -L https://launchpad.net/veracrypt/trunk/1.21/+download/veracrypt-1.21-raspbian-setup.tar.bz2 -o /tmp/veracrypt-setup.tar.bz2

        # extract
        tar xvf /tmp/veracrypt-setup.tar.bz2 -C /tmp

        # install
        isLinux64 && /tmp/veracrypt-1.22-setup-console-x64
        isLinux32 && /tmp/veracrypt-1.22-setup-console-x86
        isLinuxRaspberry && /tmp/veracrypt-1.21-setup-console-armv7
        

        isLinux64 && tar xvf /tmp/veracrypt_1.22_console_amd64.tar.gz -C $LOCAL_BIN_PATH/veracrypt_app
        isLinux32 && tar xvf /tmp/veracrypt_1.22_console_i386.tar.gz -C $LOCAL_BIN_PATH/veracrypt_app
        isDocker && echo "Not ready for docker yet." && exit 0
        isLinuxRaspberry && tar xvf /tmp/veracrypt_1.21_console_armv7.tar.gz -C $LOCAL_BIN_PATH/veracrypt_app

        ln -s $LOCAL_BIN_PATH/veracrypt_app/usr/bin/veracrypt $LOCAL_BIN_PATH
    fi
}

# install google drive client ----------------------------------------------------------------------------
function install_gdrive_mac {
    echo "installing gdrive for mac"
    mkdir -p $LOCAL_BIN_PATH
    curl -L https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_darwin -o $LOCAL_BIN_PATH/gdrive
    chmod +x $LOCAL_BIN_PATH/gdrive
    mkdir -p $GDRIVE_LOCAL_PATH
    $LOCAL_BIN_PATH/gdrive init $GDRIVE_LOCAL_PATH
}

function install_gdrive_linux {
    echo "installing gdrive for linux"
    mkdir -p $LOCAL_BIN_PATH
    curl -L https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_linux -o $LOCAL_BIN_PATH/gdrive
    chmod +x $LOCAL_BIN_PATH/gdrive
    mkdir -p $GDRIVE_LOCAL_PATH
    $LOCAL_BIN_PATH/gdrive init $GDRIVE_LOCAL_PATH
}

function download_vault {
    $LOCAL_BIN_PATH/gdrive pull -no-prompt -force $GDRIVE_LOCAL_PATH/$VAULT_GDRIVE_PATH
}

function upload_vault {
    # make sure we force upload
    #touch $GDRIVE_LOCAL_PATH/$VAULT_GDRIVE_PATH
    $LOCAL_BIN_PATH/gdrive push -no-prompt -force $GDRIVE_LOCAL_PATH/$VAULT_GDRIVE_PATH
}

function mount_vault {
    mkdir -p $VAULT_LOCAL_MOUNTPATH
    SUDOCMD=""
    if [ "$(id -u)" != "0" ]; then
	    export SUDOCMD="sudo"
    fi
    $SUDOCMD $VERACRYPT_CLI_BIN $VAULT_LOCAL_PATH $VAULT_LOCAL_MOUNTPATH 
}

function umount_vault {
    SUDOCMD=""
    if [ "$(id -u)" != "0" ]; then
	    export SUDOCMD="sudo"
    fi
    $SUDOCMD $VERACRYPT_CLI_BIN -d $VAULT_LOCAL_MOUNTPATH 
}

#public functions ------------------------------------------------------------------------------------

function install_gdrive {
    if isOSX ; then
        install_gdrive_mac
    elif isLinux ; then
        install_gdrive_linux
    fi
}

function uninstall_gdrive {
#deautenticate
    cd $GDRIVE_LOCAL_PATH && $LOCAL_BIN_PATH/gdrive deinit
    rm -f $VAULT_LOCAL_PATH
}


function sync_local2remote_vault {
    if ! check_dependencies ; then return 1; fi;
    umount_vault 
    echo "Downloading most recent vault" &&\
    download_vault &&\
    mount_vault &&\
    echo "sync local to remote vault" &&\
    rsync -avh $HOME/.ssh $VAULT_LOCAL_MOUNTPATH && \
    echo "finished - umount" &&\
    umount_vault &&\
    echo "Uploading most recent vault" &&\
    upload_vault
}

function sync_remote2local_vault {
    if ! check_dependencies ; then return 1; fi;
    umount_vault 
    echo "Downloading most recent vault" &&\
    download_vault &&\
    mount_vault &&\
    echo "sync remote vault to local" &&\
    rsync -avh  $VAULT_LOCAL_MOUNTPATH/ $HOME && \
    umount_vault 
}