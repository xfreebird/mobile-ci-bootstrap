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
  sudo softwareupdate -i -a -v 
}

function ver() { 
  printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ') 
}

function updateXcodeBuildTools() {
  # https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
  softwareupdate -i "$PROD" -v
  rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
}

function updateXcode() {
  [[ "$APPLE_USERNAME" == "" ]] && abort "Set APPLE_USERNAME env variable with the email of an Apple Developer Account."
  [[ "$APPLE_PASSWORD" == "" ]] && abort "Set APPLE_PASSWORD env variable with the passowrd of an Apple Developer Account."

  export XCODE_INSTALL_USER="$APPLE_USERNAME"
  export XCODE_INSTALL_PASSWORD="$APPLE_PASSWORD"

  xcode_version_installed=""
  #get the latest xcode version (non beta)
  for xcode_version in $(xcversion installed | grep -v beta | cut -f1)
  do
    xcode_version_installed=$xcode_version
  done

  xcversion update
  xcode_version_install=""
  #get the latest xcode version (non beta)
  for xcode_version in $(xcversion list | grep -v beta)
  do
    xcode_version_install=$xcode_version
  done

  [ x"$xcode_version_install" == x"" ] && return

  if [ $(ver $xcode_version_install) -gt $(ver "$xcode_version_installed") ]; then
    xcversion install "$xcode_version_install"
    sudo xcodebuild -license accept
    updateXcodeBuildTools
  fi
}

function updatePHPPackages() {
  sudo easy_install jira
}

function updateAndroidSDK() {
  packages=""
  for package in $(android list sdk -a --no-ui | \
    grep -v -e "Obsolete" -e "Sources" -e  "x86" -e  "Samples" \
    -e  "Documentation" -e  "MIPS" -e  "Android TV" \
    -e  "Glass" -e  "XML" -e  "URL" -e  "Packages available" \
    -e  "Fetch" -e  "Web Driver" -e "GPU Debugging" -e "Android Auto" | \
    cut -d'-' -f1)
  do
    packages=$(printf "${packages},${package}")
  done

  if [[ $packages != "" ]]; then
    ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk -a --no-ui --filter "$packages"
  fi
}

function updateBrewPackages() {

  current_android_sdk_version=$(brew list --versions | grep android-sdk | rev | cut -d' ' -f 1 | rev)
  brew update
  brew upgrade
  new_android_sdk_version=$(brew list --versions | grep android-sdk | rev | cut -d' ' -f 1 | rev)

  if [ x"$current_android_sdk_version" != x"$new_android_sdk_version" ]
  then
    updateAndroidSDK
  fi
}

function updateRubyPackages() {
  gem cleanup
  gem update -p
  
  # temporary fix for cocoapods 
  # https://github.com/CocoaPods/CocoaPods/issues/2908
  gem uninstall psych --all
  gem install psych -v 2.0.0
}

function updateNPMPackages() {
  npm install npm@latest -g
  npm update -g
}

function updateCasks() {
  brew update
  brew upgrade brew-cask
  brew cask update
  for file in $(brew cask list) ; do brew cask install $file --force; done

  for java_home in $(/usr/libexec/java_home -V 2>&1 | uniq | grep -v Matching | grep "Java SE" | cut -f3 | sort)
  do
    ( sleep 1 && while [ 1 ]; do sleep 1; echo y; done ) | jenv add "$java_home"
  done
}

function updateAll() {
  enablePasswordlessSudo
  updateXcode
  updateOSX
  updatePHPPackages
  updateBrewPackages
  updateCasks
  updateAndroidSDK
  updateRubyPackages
  updateNPMPackages
}

case "$1" in
  osx) enablePasswordlessSudo
       updateOSX
      ;;
  xcode) enablePasswordlessSudo
         updateXcode
         updateOSX
         ;;
  php) enablePasswordlessSudo
       updatePHPPackages
       ;;
  android) updateAndroidSDK
      ;;
  brew) updateBrewPackages
      ;;
  cask) enablePasswordlessSudo
        updateCasks
      ;;
  gem) updateRubyPackages
      ;;
  npm) updateNPMPackages
      ;;
  *) updateAll
  ;;
esac
