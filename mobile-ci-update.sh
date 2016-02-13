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

function updatePHPPackages() {
  sudo easy_install --upgrade pip
  sudo easy_install --upgrade jira
  sudo easy_install --upgrade lizard
}

function updateAndroidSDK() {
  packages=""
  for package in $(android list sdk --no-ui | \
    grep -v -e "Obsolete" -e "Sources" -e  "x86" -e  "Samples" \
    -e  "Documentation" -e  "MIPS" -e  "Android TV" \
    -e  "Glass" -e  "XML" -e  "URL" -e  "Packages available" \
    -e  "Fetch" -e  "Web Driver"  -e "GPU Debugging" -e "Android Auto" | \
    cut -d'-' -f1)
  do
    packages=$(printf "${packages},${package}")
  done

  if [[ $packages != "" ]]; then
    ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter "$packages"
  fi

  packages=""
  for package in $(android list sdk --no-ui -a | grep -v "Obsolete" | grep -e "Build-tools" -e "Platform-tools" | \
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
  curren_sonar_runner_version=$(brew list --versions | grep sonar-runner | rev | cut -d' ' -f 1 | rev)
  curren_appledoc_version=$(brew list --versions | grep appledoc | rev | cut -d' ' -f 1 | rev)

  brew update
  brew upgrade

  # new packages
  brew install ios-webkit-debug-proxy buck graphicsmagick imagemagick appledoc tailor

  new_android_sdk_version=$(brew list --versions | grep android-sdk | rev | cut -d' ' -f 1 | rev)
  new_sonar_runner_version=$(brew list --versions | grep sonar-runner | rev | cut -d' ' -f 1 | rev)
  new_appledoc_version=$(brew list --versions | grep appledoc | rev | cut -d' ' -f 1 | rev)

  if [ x"$current_android_sdk_version" != x"$new_android_sdk_version" ]
  then
    updateAndroidSDK
  fi

  if [ x"$curren_sonar_runner_version" != x"$new_sonar_runner_version" ]
  then
    updateSonarRunnerPath "$curren_sonar_runner_version" "$new_sonar_runner_version"
  fi

  if [ x"$curren_appledoc_version" != x"$new_appledoc_version" ]
  then
    updateAppledocSymLinks
  fi
}

function updateRubyPackages() {
  ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | gem cleanup
  ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | gem update -p
  
  # new packages
  ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | gem install jazzy

  # temporary fix for cocoapods 
  # https://github.com/CocoaPods/CocoaPods/issues/2908
  ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | gem uninstall psych --all
  gem install psych -v 2.0.0
}

function updateNPMPackages() {
  npm install npm@latest -g

  rm -f /usr/local/bin/npm-check-updates
  npm install -g npm-check-updates

  npm update -g
  npm uninstall -g phonegap
  npm install -g phonegap
  npm outdated -g  | grep -v Package | grep -v phonegap | awk '{print $1}' | xargs -I% npm install -g %@latest --save
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

function updateGoPackages() {
  go get github.com/aktau/github-release
}

function updateAppledocSymLinks() {
  APPLEDOCVERSION=$(appledoc --version | cut -d' ' -f3)

  rm -fr ~/.appledoc ~/Library/Application\ Support/appledoc
  ln -s /usr/local/Cellar/appledoc/${APPLEDOCVERSION}/Templates ~/Library/Application\ Support/appledoc
  ln -s /usr/local/Cellar/appledoc/${APPLEDOCVERSION}/Templates ~/.appledoc
}

function updateSonarRunnerPath() {
  cat ~/.profile  | sed 's|sonar-runner/$1|sonar-runner/$2|g' > ~/.profile.tmp
  mv ~/.profile.tmp ~/.profile
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
  updateGoPackages
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
  go) updateNPMPackages
      ;;
  *) updateAll
  ;;
esac
