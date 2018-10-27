#!/bin/bash
# Created by Nicolae Ghimbovschi 2015
# https://github.com/xfreebird

function showActionMessage() { echo "⏳`tput setaf 12` $1 `tput op`"; }

function showMessage() {
  showActionMessage "$1"
  osascript -e "display notification \"$1\" with title \"Installer\""
}

function abort() { echo "!!! $@" >&2; exit 1; }

function cleanUp() {
  showActionMessage "Revoking passwordless sudo for '$USERNAME'"
  sudo -S bash -c "cp /etc/sudoers.orig /etc/sudoers"
}

function ver() { 
  printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ') 
}

function updateXcodeBuildTools() {
  showActionMessage "Installing Xcode command line tools."
  # https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  OSXVERSION=$(sw_vers -productVersion | cut -d'.' -f1 -f2)
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | grep "$OSXVERSION" | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
  softwareupdate -i "$PROD" --verbose
  rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
}

USERNAME=$(whoami)

[ "$USERNAME" = "root" ] && abort "Run as yourself, not root."
groups | grep -q admin || abort "Add $USERNAME to the admin group."

[[ "$PASSWORD" == "" ]] && abort "Set PASSWORD env variable with the password of the $USERNAME."
[[ "$APPLE_USERNAME" == "" ]] && abort "Set APPLE_USERNAME env variable with the email of an Apple Developer Account."
[[ "$APPLE_PASSWORD" == "" ]] && abort "Set APPLE_PASSWORD env variable with the passowrd of an Apple Developer Account."

#==========================================================
#==== Enable passwordless sudo
#==== Very important to have this running without the need
#==== of user input
#==========================================================
showActionMessage "Enabling Temporary passwordless sudo for '$USERNAME'"
echo "$PASSWORD" | sudo -S bash -c "cp /etc/sudoers /etc/sudoers.orig; echo '${USERNAME} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

#==========================================================
#==== Call cleanUp if the script is stopped, finishes or 
#==== is terminated
#==========================================================
trap cleanUp SIGHUP SIGINT SIGTERM EXIT

#==========================================================
#==== OSX configurations
#==== - Enable Remote Management (VNC)
#==== - Enable Remote Login (SSH)
#==== - Enable Developer Mode
#==== - Disable Sleep Mode
#==== - Disable Screensaver
#==== - Disable Gatekeeper
#==== - Fix permissions issues for Calabash
#==== - Set Global env variables in ~/.profile
#==========================================================
showActionMessage "Enabling Remote Management"
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers -clientopts -setreqperm -reqperm yes

showActionMessage "Enabling Remote Login"
sudo dscl . change /Groups/com.apple.access_ssh RecordName com.apple.access_ssh com.apple.access_ssh-disabled
sudo systemsetup -setremotelogin on

showActionMessage "Enabling Developer Mode"
sudo /usr/sbin/DevToolsSecurity --enable
sudo /usr/sbin/dseditgroup -o edit -t group -a staff _developer

showActionMessage "Disabling Sleep Mode"
sudo pmset sleep 0

showActionMessage "Disabling Screensaver"
defaults -currentHost write com.apple.screensaver idleTime -int 0

showActionMessage "Disabling Gatekeeper"
sudo spctl --master-disable

showActionMessage "Automatic Restart on System Freeze"
sudo systemsetup -setrestartfreeze on

showActionMessage "Fixing permission issues for calabash"
sudo security authorizationdb write system.privilege.taskport allow

showActionMessage "Installing Apple WWDRCA certificate"
curl -O -L http://developer.apple.com/certificationauthority/AppleWWDRCA.cer
security import AppleWWDRCA.cer  -k ~/Library/Keychains/login.keychain -P "" -A

showActionMessage "Injecting environment variables"
echo 'export LC_ALL=en_US.UTF-8' > ~/.profile
echo 'export ANDROID_SDK_ROOT=/usr/local/share/android-sdk' >> ~/.profile
echo 'export ANDROID_NDK_HOME=/usr/local/share/android-ndk' >> ~/.profile
echo 'export ANDROID_HOME=$ANDROID_SDK_ROOT' >> ~/.profile
echo 'export NDK_HOME=$ANDROID_NDK_HOME' >> ~/.profile
echo 'export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:$ANDROID_HOME/bin:$PATH' >> ~/.profile
echo 'export JENV_ROOT=/usr/local/var/jenv' >> ~/.profile
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.profile
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.profile
echo 'if which jenv > /dev/null; then eval "$(jenv init -)"; fi' >> ~/.profile

mkdir ~/.nvm
source ~/.profile

# make Jenkins slave load .profile env variables
[[ -f ~/.bashrc ]] && mv ~/.bashrc ~/.bashrc.old
ln -s ~/.profile ~/.bashrc

#==========================================================
#==== CI folder
#==== - Create user writeable folder in /opt/ci
#==== - Create the jenkins folder in /opt/ci
#==========================================================
showActionMessage "Creating CI folder at '/opt/ci/jenkins'"
sudo mkdir -p "/opt/ci/jenkins"
sudo chown -R "$(whoami)" "/opt/ci"

#==========================================================
#==== Update OSX
#==========================================================
showActionMessage "Updating the operating system"
sudo softwareupdate -i -a --verbose

#==========================================================
#==== Install Xcode command line tools
#==== Required by Brew and Ruby Gems
#==========================================================
updateXcodeBuildTools

#==========================================================
#==== Install Brew and taps
#==========================================================
showActionMessage "Installing brew"
echo "" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew tap caskroom/cask
brew tap caskroom/versions

brew tap oclint/formulae
brew tap xfreebird/utils

brew update
brew upgrade

#==========================================================
#==== Install Alternative Ruby Environment
#==== User writeable, no need for sudo
#==========================================================
showActionMessage "Installing rbenv 2.3.7"
brew install rbenv ruby-build
eval "$(rbenv init -)"
rbenv install 2.3.7
rbenv global 2.3.7

#==========================================================
#==== Reload the shell environment
#==========================================================
source ~/.profile

#==========================================================
#==== Install bundler and xcode-install
#==========================================================
showActionMessage "Installing bundler and xcode-install"
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | gem install bundler xcode-install --no-rdoc --no-ri 

#==========================================================
#==== Reload the shell environment
#==========================================================
source ~/.profile

#==========================================================
#==== Install the latest available Xcode from
#==== http://developer.apple.com/downloads
#==== We don't use the AppStore Xcode
#==========================================================
showActionMessage "Installing the latest Xcode:"
export XCODE_INSTALL_USER="$APPLE_USERNAME"
export XCODE_INSTALL_PASSWORD="$APPLE_PASSWORD"

xcversion update

#get the latest xcode version (non beta)
xcode_latest_installed_version=$(xcversion installed | grep -v beta | tail -n 1 | cut -f1)

#get the latest xcode version (non beta)
xcode_version_install=$(xcversion list | grep -v beta  | tail -n 1 | cut -d" " -f1)

if [ x"$xcode_version_install" != x"" ]; then
  if [ $(ver "$xcode_version_install") -gt $(ver "$xcode_latest_installed_version") ];
  then
    showActionMessage "Xcode $xcode_version:"
    xcversion install "$xcode_version_install"
    sudo xcodebuild -license accept
    updateXcodeBuildTools
  fi
fi

showActionMessage "Installing Java"
brew cask install caskroom/versions/java8

showActionMessage "Installing Android SDK and NDK"
brew cask install android-sdk
brew cask install android-ndk

brew install kcpassword mobile-ci-update 
brew install git nvm swiftlint oclint

showActionMessage "Installing carthage"
brew install carthage

echo '. "/usr/local/opt/nvm/nvm.sh"' >> ~/.profile
source ~/.profile

showActionMessage "Installing latest version of node.js"
nvm install node

#showActionMessage "Installing Lizard code static code analysis"
#sudo easy_install lizard

showActionMessage "Enabling autologin"
enable_autologin "$USERNAME" "$PASSWORD"

showMessage "Build machine is ready ! 🔧 Now connect a Jenkins agent to this machine with '$USERNAME' at port 22 using workspace /opt/ci/jenkins 🚀"
