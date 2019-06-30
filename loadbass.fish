function loadbass
  set -l CURR_DIR $PWD
  cd ~
  bass . .profile
  cd $CURR_DIR
end
