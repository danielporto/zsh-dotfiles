# check if storm/veracrypt/rsync/gdrive are installed (use a docker container? no. because we need a container with it)
# check if the vault is in synch
# download the vault and extract the content to .ssh
# synchronize the content with the vault (rsync)
# upload the vault

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

# if isOSX  ; then echo "Is osx"; else echo "is not osx"; fi;
# if isLinux ; then echo "Is linux"; else echo "is not linux"; fi;
# if isDocker ; then echo "Is docker"; else echo  "is not docker"; fi;


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