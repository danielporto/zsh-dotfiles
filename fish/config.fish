if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end
#bass source ~/.profile
#. ~/.config/fish/functions/loadbass.fish
loadbass

set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
