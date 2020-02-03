source $HOME/.profile

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

eval "$(jenv init -)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Volumes/data/Users/dporto/.sdkman"
[[ -s "/Volumes/data/Users/dporto/.sdkman/bin/sdkman-init.sh" ]] && source "/Volumes/data/Users/dporto/.sdkman/bin/sdkman-init.sh"
