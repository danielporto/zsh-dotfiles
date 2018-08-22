# check if storm/veracrypt/rsync/gdrive are installed (use a docker container? no. because we need a container with it)
# check if the vault is in synch
# download the vault and extract the content to .ssh
# synchronize the content with the vault (rsync)
# upload the vault

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


GDRIVE_LOCAL_PATH="$HOME/.gdrive"
VAULT_GDRIVE_PATH=/Chaveiro/sshvault
VAULT_LOCAL_PATH=$GDRIVE_LOCAL_PATH/Chaveiro/sshvault
VAULT_LOCAL_MOUNTPATH=$HOME/.sshvault

LOCAL_BIN_PATH="$HOME/.local"
GDRIVE_CLI_BIN="gdrive"
GDRIVE_DOWNLOAD_URL=""
    
if [ "$isOSX" = true ] ; then
    export GDRIVE_DOWNLOAD_URL="https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_darwin"
    export VERACRYPT_CLI_BIN="/Applications/VeraCrypt.app/Contents/MacOS/VeraCrypt"
fi
if [ "$isLinux" = true ] ; then
    export GDRIVE_DOWNLOAD_URL="https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_linux"
    export VERACRYPT_HOME_PATH="$LOCAL_BIN_PATH/veracrypt_app"
    export VERACRYPT_CLI_BIN="$LOCAL_BIN_PATH/veracrypt"

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
function install_vault {
    if [ "$isLinux" = true ] ; then
        install_veracrypt_linux;
    elif [ "$isOSX" = true ] ; then
        install_veracrypt_mac;
    else
        echo "Unsupported system. sorry" 
    fi
    echo "Veracrypt vault installed"

}


function install_veracrypt_mac {
    brew cask install veracrypt
    if [ ! -e $VERACRYPT_CLI_BIN ]; then
        echo "install Veracrypt with homebrew as: brew cask install veracrypt"
        return -1
    fi
}

function install_veracrypt_linux {
    echo "About to install in linux: $VERACRYPT_CLI_BIN"
    if [ "$isRaspberry" = true ]; then echo "is rapberry!"; else echo "not raspberry"; fi;
    if [ ! -e "$VERACRYPT_CLI_BIN" ]; then 
        echo "installing veracrypt for linux"
        mkdir -p $VERACRYPT_HOME_PATH
        # download
        if [ "$isLinux64" = true ] || [ "$isLinux32" = true ]; then curl -L https://launchpad.net/veracrypt/trunk/1.22/+download/veracrypt-1.22-setup.tar.bz2 -o /tmp/veracrypt-setup.tar.bz2; fi;
        if [ "$isRaspberry" = true ]; then  curl -L https://launchpad.net/veracrypt/trunk/1.21/+download/veracrypt-1.21-raspbian-setup.tar.bz2 -o /tmp/veracrypt-setup.tar.bz2; fi; 

        # extract
        tar xvf /tmp/veracrypt-setup.tar.bz2 -C /tmp

        # install
        if [ "$isLinux64" = true ]; then  /tmp/veracrypt-1.22-setup-console-x64; fi; 
        if [ "$isLinux32" = true ]; then /tmp/veracrypt-1.22-setup-console-x86; fi; 
        if [ "$isRaspberry" = true ]; then /tmp/veracrypt-1.21-setup-console-armv7; fi; 
        

        if [ "$isLinux64" = true ]; then tar xvf /tmp/veracrypt_1.22_console_amd64.tar.gz -C $VERACRYPT_HOME_PATH; fi; 
        if [ "$isLinux32" = true ]; then tar xvf /tmp/veracrypt_1.22_console_i386.tar.gz -C $VERACRYPT_HOME_PATH; fi; 
        if [ "$isDocker" = true ]; then echo "Not ready for docker yet." && exit 0; fi; 
        if [ "$isRaspberry" = true ]; then tar xvf /tmp/veracrypt_1.21_console_armv7.tar.gz -C $VERACRYPT_HOME_PATH; fi; 

        ln -s $VERACRYPT_HOME_PATH/usr/bin/veracrypt $LOCAL_BIN_PATH
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
    if [ "$isLinux64" = true ]; then curl -L https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_linux -o $LOCAL_BIN_PATH/gdrive ; fi;
    if [ "$isLinux32" = true ]; then echo "System not supported yet" ; fi;
    if [ "$isRaspberry" = true ]; then curl -L https://github.com/odeke-em/drive/releases/download/v0.3.9/drive_armv7 -o $LOCAL_BIN_PATH/gdrive ; fi;
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
    $LOCAL_BIN_PATH/gdrive push -ignore-checksum=false -no-prompt -force $GDRIVE_LOCAL_PATH/$VAULT_GDRIVE_PATH
}

function mount_vault {
    mkdir -p $VAULT_LOCAL_MOUNTPATH
    SUDOCMD=""
    if [ "$(id -u)" != "0" ] && [ "$isOSX" = true ]; then
	    export SUDOCMD="sudo"
    fi

    $SUDOCMD $VERACRYPT_CLI_BIN -m=nokernelcrypto  $VAULT_LOCAL_PATH $VAULT_LOCAL_MOUNTPATH
}

function umount_vault {
    SUDOCMD=""
    if [ "$(id -u)" != "0" ] && [ "$isOSX" = true ]; then
	    export SUDOCMD="sudo"
    fi
    $SUDOCMD $VERACRYPT_CLI_BIN -d $VAULT_LOCAL_MOUNTPATH 
}

#public functions ------------------------------------------------------------------------------------

function install_gdrive {
    if [ "$isOSX" = true ] ; then
        install_gdrive_mac
    elif [ "$isLinux" = true ] ; then
        install_gdrive_linux
    fi
}

function uninstall_gdrive {
#deautenticate
    cd $GDRIVE_LOCAL_PATH && $LOCAL_BIN_PATH/gdrive deinit
    rm -f $VAULT_LOCAL_PATH
}


function credentials-upload {
    if ! check_dependencies ; then return 1; fi;
    echo "#--------------------------------------------------------------------"
    echo "# Make sure the vault is not mounted."
    umount_vault 
    echo "#--------------------------------------------------------------------" &&\
    echo "Downloading most recent vault" &&\
    download_vault &&\
    echo "#--------------------------------------------------------------------" &&\
    echo "Mount most recent vault." &&\  
    mount_vault &&\
    echo "sync local to remote vault" &&\
    rsync -avh $HOME/.ssh $VAULT_LOCAL_MOUNTPATH && \
    echo "#--------------------------------------------------------------------" &&\
    echo "finished - umount" &&\
    umount_vault &&\
    echo "#--------------------------------------------------------------------" &&\
    echo "Uploading most recent vault" &&\
    upload_vault
}

function credentials-download {
    if ! check_dependencies ; then return 1; fi;
    echo "#--------------------------------------------------------------------"
    echo "# Make sure the vault is not mounted."
    umount_vault 
    echo "#--------------------------------------------------------------------" &&\
    echo "Downloading most recent vault" &&\
    download_vault &&\
    echo "#--------------------------------------------------------------------" &&\
    echo "Mount most recent vault." &&\
    mount_vault &&\
    echo "#--------------------------------------------------------------------" &&\
    echo "sync vault to local" &&\
    rsync -avh  $VAULT_LOCAL_MOUNTPATH/ $HOME && \
    echo "#--------------------------------------------------------------------" &&\
    echo "Close vault." &&\
    umount_vault &&\
    echo "#--------------------------------------------------------------------" &&\
    echo "Fix permissions of ssh dir." &&\
    chmod -R 740 $HOME/.ssh


}

function credentials-mount-ro {
    mkdir -p $VAULT_LOCAL_MOUNTPATH
    SUDOCMD=""
    if [ "$(id -u)" != "0" ] && [ "$isOSX" = true ]; then
	    export SUDOCMD="sudo"
    fi

    # test if the vault is downloaded
    # test if the vault is mounted

    $SUDOCMD $VERACRYPT_CLI_BIN -m=nokernelcrypto,ro  $VAULT_LOCAL_PATH $VAULT_LOCAL_MOUNTPATH

}

function credentials-clean {
    echo "#--------------------------------------------------------------------"
    echo "# Make sure the vault is not mounted."
    umount_vault 

    echo "#--------------------------------------------------------------------" &&\
    echo "backup authorized keys." 
    cp $HOME/.ssh/authorized_keys /tmp

    echo "#--------------------------------------------------------------------" &&\
    echo "backup known hosts."
    cp $HOME/.ssh/known_hosts /tmp
    
    echo "#--------------------------------------------------------------------" &&\
    echo "Cleanup .ssh." 
    # remove everything else.
    rm -rf $HOME/.ssh/*

    echo "#--------------------------------------------------------------------" &&\
    echo "Restore known hosts and authorized keys." 
    mv /tmp/authorized_keys $HOME/.ssh
    mv /tmp/known_hosts $HOME/.ssh
}


function credentials-load-agent {
    echo "#--------------------------------------------------------------------"
    echo "# loading keys into ssh agent"
    for f in $(ls ~/.ssh/*.pub | rev | cut -c 5- | rev | cut -d "." -f 2 ); do 
        echo "Loading ~/.$f..."
        ssh-add -t 10 ~/.$f; 
    done;

    # dir=$(pwd)
    # cd ~/.ssh
    # for f in $(ls *.pub | rev | cut -c 5- | rev ); do 
    #     echo "Loading $f..."
    #     ssh-add -t 10 $f; 
    # done;
    # cd $dir


}

function credentials-copy-config-to {
    if -z $1; then
        echo "SSH host not specified. Aborting"
        return
    fi
    scp ~/.ssh/config $1:~/.ssh
}
