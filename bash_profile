source $HOME/.profile

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Volumes/data/Users/dan/.sdkman"
[[ -s "/Volumes/data/Users/dan/.sdkman/bin/sdkman-init.sh" ]] && source "/Volumes/data/Users/dan/.sdkman/bin/sdkman-init.sh"

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

