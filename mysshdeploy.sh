# check if storm/veracrypt/rsync/python are installed (use a docker container? no. because we need a container with it)
# check if the vault is in synch
# download the vault and extract the content to .ssh
# synchronize the content with the vault (rsync)
# upload the vault

isOSX="[[ $OSTYPE == *darwin* ]]"
isLinux="[[ $OSTYPE == *linux* ]]"
isDocker="" 
if [[ $isLinux == True ]] ; then
    if [[ ! $(cat /proc/1/sched | head -n 1 | grep init) ]]; then 
        isDocker=True
    else 
        isDocker=False
    fi
fi

GDRIVE_LOCAL_PATH="$HOME/.gdrive"
VAULT_GDRIVE_PATH=/Chaveiro/sshvault
VAULT_LOCAL_PATH=$GDRIVE_LOCAL_PATH/Chaveiro/sshvault
VAULT_LOCAL_MOUNTPATH=$HOME/.sshvault

LOCAL_BIN_PATH="$HOME/.local"
GDRIVE_CLI_BIN="gdrive"
GDRIVE_DOWNLOAD_URL=""
VERACRYPT_CLI_PATH=""
VERACRYPT_CLI_BIN=""


if [ isOSX ]; then
    VERACRYPT_DOWNLOAD_URL="" #none, installed via homebrew
    GDRIVE_DOWNLOAD_URL="https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_darwin"
    VERACRYPT_CLI_BIN="/Applications/VeraCrypt.app/Contents/MacOS/VeraCrypt"
elif [ isLinux ]; then
    VERACRYPT_DOWNLOAD_URL="https://launchpad.net/veracrypt/trunk/1.21/+download/veracrypt-1.21-setup.tar.bz2"
    GDRIVE_DOWNLOAD_URL="https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_linux"
    VERACRYPT_CLI_BIN=`which veracrypt`
fi

# internal stuff =======================================================================================
function check_dependencies {
    if [ ! -e $VERACRYPT_CLI_BIN ]; then
        echo "Error Veracrypt is not installed"
        return -1
    fi
    if [ ! -e "$LOCAL_BIN_PATH/gdrive" ]; then
        echo "Error, gdrive client is not installed"
        return -1
    fi
    RSYNC=`which rsync`
    if [ ! -e "$RSYNC" ]; then
        echo "Error rsync is not installed"
        return -1
    fi
    CURL=`which curl`
    if [ ! -e "$CURL" ]; then
        echo "Error, curl client is not installed"
        return -1
    fi
    return 1
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
    if [ -f $VERACRYPT_CLI_BIN ]; then 
        echo "Install veracrypt for your distro and make sure it is available in the PATH"
        return -1
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
    $VERACRYPT_CLI_BIN $VAULT_LOCAL_PATH $VAULT_LOCAL_MOUNTPATH 
}

function umount_vault {
    $VERACRYPT_CLI_BIN -d $VAULT_LOCAL_MOUNTPATH 
}

#public functions ------------------------------------------------------------------------------------

function install_gdrive {
    if [ -n $isOSX ]; then
        install_gdrive_mac
    elif [ -n $isLinux ]; then
        install_gdrive_linux
    fi
}

function uninstall_gdrive {
#deautenticate
    cd $GDRIVE_LOCAL_PATH && $LOCAL_BIN_PATH/gdrive deinit
    rm -f $VAULT_LOCAL_PATH
}


function sync_local2remote_vault {
    if [ check_dependencies < 0 ]; then return 0; fi;
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
    if [ check_dependencies < 0 ]; then return 0; fi;
    echo "Downloading most recent vault" &&\
    download_vault &&\
    mount_vault &&\
    echo "sync remote vault to local" &&\
    rsync -avh  $VAULT_LOCAL_MOUNTPATH $HOME/.ssh && \
    umount_vault 
}