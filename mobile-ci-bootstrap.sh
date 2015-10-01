#!/bin/bash
# Created by Nicolae Ghimbovschi 2015
# https://github.com/xfreebird

function showActionMessage() { echo "⏳`tput setaf 12` $1 `tput op`"; }

function showMessage() {
	showActionMessage "$1"
	osascript -e "display notification \"$1\" with title \"Installer\""
}

function abort() { echo "!!! $@" >&2; exit 1; }

USERNAME=$(whoami)

[ "$USERNAME" = "root" ] && abort "Run as yourself, not root."
groups | grep -q admin || abort "Add $USERNAME to the admin group."

showActionMessage "Enabling Temporary passwordless sudo for '$USERNAME'"
echo "$PASSWORD" | sudo -S bash -c "cp /etc/sudoers /etc/sudoers.orig; echo '${USERNAME} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

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

showActionMessage "Fixing permission issues for calabash"
sudo security authorizationdb write system.privilege.taskport allow

showActionMessage "Injecting environment variables"
echo "export ANDROID_HOME=/usr/local/opt/android/sdk" >> ~/.profile
echo "export NDK_HOME=/usr/local/opt/android/ndk" >> ~/.profile
echo "export GOPATH=/usr/local/opt/go/libexec" >> ~/.profile
echo "export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home" >> ~/.profile
echo "export FINDBUGS_HOME=/usr/local/Cellar/findbugs/3.0.1/libexec" >> ~/.profile
echo "export SONAR_RUNNER_HOME=/usr/local/Cellar/sonar-runner/2.4/libexec" >> ~/.profile
echo "export M2_HOME=/usr/local/Cellar/maven30/3.0.5/libexec" >> ~/.profile
echo "export M2=/usr/local/Cellar/maven30/3.0.5/libexec/bin" >> ~/.profile
echo "export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:\$ANDROID_HOME/bin:\$PATH:\$GOPATH:\$GOPATH/bin" >> ~/.profile
source ~/.profile

showActionMessage "Creating CI folder at '/opt/ci/jenkins'"
sudo mkdir -p "/opt/ci/jenkins"
sudo chown -R "$(whoami)" "/opt/ci"

showActionMessage "Updating the operating system"
sudo softwareupdate -i -a -v 

showActionMessage "Installing xcode command line tools."
# https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh
sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
sudo softwareupdate -i "$PROD" -v
sudo rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

showActionMessage "Installing JDK 7"
curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-macosx-x64.dmg
hdiutil mount -nobrowse jdk-7u79-macosx-x64.dmg
sudo installer -pkg /Volumes/JDK\ 7\ Update\ 79/JDK\ 7\ Update\ 79.pkg  -target /
hdiutil unmount /Volumes/JDK\ 7\ Update\ 79
rm -f jdk-7u79-macosx-x64.dmg

showActionMessage "Installing brew"
echo "" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew tap caskroom/cask
brew tap homebrew/versions
brew tap xfreebird/utils
brew tap facebook/fb
brew install caskroom/cask/brew-cask

showActionMessage "Updating all gems"
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sudo gem update -p

showActionMessage "Installing maven, ant and gradle"
brew install maven30 ant
brew install gradle

showActionMessage "Installing Android SDK"
brew install android-sdk

showActionMessage "Installing Android NDK"
brew install android-ndk

showActionMessage "Installing helper tools"
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sudo gem install ocunit2junit nomad-cli cocoapods xcpretty xcode-install slather cloc
brew install lcov gcovr ios-sim sonar-runner findbugs
brew install splunk-mobile-upload nexus-upload bamboo-agent-utility kcpassword
brew install machine-info-service refresh-ios-profiles crashlytics-upload-ipa customsshd
brew install node go
brew cask install oclint
go get github.com/aktau/github-release
sudo easy_install jira

showActionMessage "Installing fastlane tools"
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sudo gem install fastlane deliver snapshot frameit pem sigh produce cert codes spaceship pilot gym

showActionMessage "Installing Calabash for Android and iOS"
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sudo gem install calabash-cucumber calabash-android

showActionMessage "Installing custom SSHD agent"
if [ ! -f sshd_rsa_key.pub ]; then
	showActionMessage "Generating custom SSHD agent SSH key pair."
	showActionMessage "Make sure that you save these generated keys."
	ssh-keygen -t rsa -f sshd_rsa_key -P ""
fi
customsshd install sshd_rsa_key.pub

showActionMessage "Installing Websocketd info service"
info-service-helper install

showActionMessage "Enabling autologin"
enable_autologin "$USERNAME" "$PASSWORD"

showActionMessage "Installing the latest Xcode:"
export XCODE_INSTALL_USER="$APPLE_USERNAME"
export XCODE_INSTALL_PASSWORD="$APPLE_PASSWORD"
xcode-install update
xcode_version_install="7.1"
#get the latest xcode version (non beta)
for xcode_version in $(xcode-install list | grep -v beta)
do
	xcode_version_install=$xcode_version
done

showActionMessage "Xcode $xcode_version:"
xcode-install install "$xcode_version_install"
sudo xcodebuild -license accept

showActionMessage "Installing Appium"
npm install -g appium
npm install -g wd
npm install -g npm-check-updates

showActionMessage "Installing Cordova"
npm install -g cordova

showActionMessage "Installing Phonegap"
npm install -g phonegap

showActionMessage "Installing Carthage"
brew install carthage

showActionMessage "Installing xctool"
brew install xctool

showActionMessage "Installing iosbuilder.sh"
brew install iosbuilder

showActionMessage "Installing swiftlint"
brew install swiftlint

showActionMessage "Revoking passwordless sudo for '$USERNAME'"
sudo -S bash -c "cp /etc/sudoers.orig /etc/sudoers"

showActionMessage "Installing additional Android SDK components"
packages="1"
for package in $(android list sdk --all | grep -v Obsolete | grep -v Sources | grep -v "Intel x86 Emulator" | grep -v Samples | grep -v Documentation | grep -v MIPS | grep -v "Android TV" | grep -v "Glass" | grep -v "XML" | grep -v "URL" | grep -v "Packages available" | grep -v "Fetch" | grep -v "Web Driver" | cut -d'-' -f1)
do
	 if [ $package != "1" ]; then
   	packages=$(printf "${packages},${package}")
   fi
done
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --all --no-ui --filter "$packages"
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --all --no-ui --filter platform-tools

showMessage "🔧 Install iOS signing certificates to 🔐 iosbuilder.keychain"
showMessage "🔧 Install iOS provisioning profiles using the refresh-ios-profiles command."

open "http://localhost"
showMessage "Build machine is ready ! 🔧 Now connect a Jenkins agent to this machine with '$USERNAME' at port 50111 and 🔑 sshd_rsa_key using workspace /opt/ci/jenkins 🚀"


