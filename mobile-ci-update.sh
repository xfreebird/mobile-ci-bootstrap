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
}

function updateOSX() {
  sudo softwareupdate -i -a -v 
}

function ver() { 
  printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ') 
}

function updateXcode() {
  [[ "$APPLE_USERNAME" == "" ]] && abort "Set APPLE_USERNAME env variable with the email of an Apple Developer Account."
  [[ "$APPLE_PASSWORD" == "" ]] && abort "Set APPLE_PASSWORD env variable with the passowrd of an Apple Developer Account."

  export XCODE_INSTALL_USER="$APPLE_USERNAME"
  export XCODE_INSTALL_PASSWORD="$APPLE_PASSWORD"

  xcode_version_installed=""
  #get the latest xcode version (non beta)
  for xcode_version in $(xcode-install installed | grep -v beta | cut -f1)
  do
    xcode_version_installed=$xcode_version
  done

  xcode-install update
  xcode_version_install=""
  #get the latest xcode version (non beta)
  for xcode_version in $(xcode-install list | grep -v beta)
  do
    xcode_version_install=$xcode_version
  done

  [ x"$xcode_version_install" == x"" ] && return

  if [ $(ver $xcode_version_install) -gt $(ver "$xcode_version_installed") ]; then
    xcode-install install "$xcode_version_install"
    sudo xcodebuild -license accept
  fi
}

function updatePHPPackages() {
  sudo easy_install jira
}

function updateAndroidSDK() {
  packages=""
  for package in $(android list sdk --no-ui | \
    grep -v -e "Obsolete" -e "Sources" -e  "x86" -e  "Samples" \
    -e  "Documentation" -e  "MIPS" -e  "Android TV" \
    -e  "Glass" -e  "XML" -e  "URL" -e  "Packages available" \
    -e  "Fetch" -e  "Web Driver" | \
    cut -d'-' -f1)
  do
    packages=$(printf "${packages},${package}")
  done

  if [[ $packages != "" ]]; then
    ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter "$packages"
  fi
}

function updateBrewPackages() {
  brew update
  brew upgrade
}

function updateRubyPackages() {
  gem update -p
  
  # temporary fix for cocoapods 
  # https://github.com/CocoaPods/CocoaPods/issues/2908
  gem uninstall psych
  gem install psych -v 2.0.0
}

function updateNPMPackages() {
  npm update -g
}

function updateAll() {
  enablePasswordlessSudo
  updateOSX
  updateXcode
  updatePHPPackages
  updateBrewPackages
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
        updateAndroidSDK
      ;;
  gem) updateRubyPackages
      ;;
  npm) updateNPMPackages
      ;;
  *) updateAll
  ;;
esac
