#!/bin/bash
# Created by Nicolae Ghimbovschi 2015
# https://github.com/xfreebird

function showActionMessage() { echo "⏳`tput setaf 12` $1 `tput op`"; }

function abort() { echo "!!! $@" >&2; exit 1; }

function disablePasswordlessSudo() {
  sudo bash -c "cp /etc/sudoers.orig /etc/sudoers"
}

function enablePasswordlessSudo() {
  USERNAME=$(whoami)

  [[ "$PASSWORD" == "" ]] && abort "Set PASSWORD env variable with the passowrd of the $USERNAME."

  trap disablePasswordlessSudo SIGHUP SIGINT SIGTERM EXIT
  echo "$PASSWORD" | sudo -S bash -c "cp /etc/sudoers /etc/sudoers.orig; echo '${USERNAME} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

  #fix permissions
  sudo chown -R "$(whoami)" /usr/local
}

function updateOSX() {
  sudo softwareupdate -i -a --verbose 
}

function ver() { 
  printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ') 
}

function updateXcodeBuildTools() {
  # https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
  softwareupdate -i "$PROD" --verbose
  rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
}

function updateXcode() {
  [[ "$APPLE_USERNAME" == "" ]] && abort "Set APPLE_USERNAME env variable with the email of an Apple Developer Account."
  [[ "$APPLE_PASSWORD" == "" ]] && abort "Set APPLE_PASSWORD env variable with the passowrd of an Apple Developer Account."

  export XCODE_INSTALL_USER="$APPLE_USERNAME"
  export XCODE_INSTALL_PASSWORD="$APPLE_PASSWORD"

  xcversion update

  #get the latest xcode version (non beta)
  xcode_latest_installed_version=$(xcversion installed | grep -v beta | tail -n 1 | cut -f1)

  #get the latest xcode version (non beta)
  xcode_version_install=$(xcversion list | grep -v beta  | tail -n 1 | cut -d" " -f1)

  [ x"$xcode_version_install" == x"" ] && return

  if [ $(ver $xcode_version_install) -gt $(ver "$xcode_latest_installed_version") ]; then
    xcversion install "$xcode_version_install"
    sudo xcodebuild -license accept
    updateXcodeBuildTools
  fi
}

function updateBrewPackages() {
  brew update
  brew upgrade
}

function updateRubyPackages() {
  ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | gem update xcode-install --no-rdoc --no-ri
}

function updateCasks() {
  brew update
  for file in $(brew cask list) ; do brew cask reinstall $file --force; done

  for java_home in $(/usr/libexec/java_home -V 2>&1 | uniq | grep -v Matching | grep "Java SE" | cut -f3 | sort)
  do
    ( sleep 1 && while [ 1 ]; do sleep 1; echo y; done ) | jenv add "$java_home"
  done
}


function updateAll() {
  enablePasswordlessSudo
  updateXcode
  updateOSX
  updateBrewPackages
  updateCasks
  updateRubyPackages
}

case "$1" in
  osx) enablePasswordlessSudo
       updateOSX
      ;;
  xcode) enablePasswordlessSudo
         updateRubyPackages
         updateXcode
         updateOSX
         ;;
  brew) updateBrewPackages
      ;;
  cask) enablePasswordlessSudo
        updateCasks
      ;;
  *) updateAll
  ;;
esac
