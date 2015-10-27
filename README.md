# mobile-ci-bootstrap
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

Automatically downloads, installs and configures all needed software for a headless mobile CI box on OS X 

# Requirements

* A fresh installed OS X 10.10+ 
* User with admin rights
* Apple developer account (for Xcode)
* Internet connection

# How to use ?

On your CI box login with the created user and execute:

```shell
export PASSWORD="osx_user_password"
export APPLE_USERNAME="apple.developer@mail.com"
export APPLE_PASSWORD="secret"
bash <(curl -s https://raw.githubusercontent.com/xfreebird/mobile-ci-bootstrap/master/mobile-ci-bootstrap.sh)
```

At the end you will have:

* complete **Android** and **iOS** 📱 build machine
* **SSH key pair** ```sshd_rsa_key``` and ```sshd_rsa_key.pub``` for the **build machine** *public key* and **CI agents** *private key*
* [User UI session SSH daemon](https://github.com/xfreebird/customsshd) running at port **50111** to connect the **CI agents** to the **build machine** using the *private key* and *username*
* [Build machine info page](https://github.com/xfreebird/osx-build-machine-info-service) at [http://localhost](http://localhost)
* User writeable ```/opt/ci/jenkins``` folder for a [Jenkins agent](https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds).

If you want to use your own generated SSH key pair, before running the command place the ```sshd_rsa_key.pub``` file in the same folder were you are going to execute the command.
 

# Why ?

**To save time, since it doesn't require any user interaction.**

# What do you get ?

OS X optimised to run headless CI with various useful installed tools.

## Android
* [`Android SDK`](https://developer.android.com/sdk/index.html) [`Android  NDK`](https://developer.android.com/ndk/index.html)
* [`Gradle`](http://gradle.org) [`Maven 3.0.x`](https://maven.apache.org) [`Ant`](http://ant.apache.org) [`findbugs`](http://findbugs.sourceforge.net)

## iOS
* [`Xcode`](https://developer.apple.com/xcode/download/) [`xctool`](https://github.com/facebook/xctool) [`Cocoapods`](http://cocoapods.org) [`Carthage`](https://github.com/Carthage/Carthage)
* [Fastlane](https://fastlane.tools) bundle: [`fastlane`](https://github.com/KrauseFx/fastlane) [`deliver`](https://github.com/KrauseFx/deliver) [`snapshot`](https://github.com/KrauseFx/snapshot) [`frameit`](https://github.com/fastlane/frameit) [`pem`](https://github.com/fastlane/PEM) [`sigh`](https://github.com/KrauseFx/sigh) [`produce`](https://github.com/fastlane/produce) [`cert`](https://github.com/fastlane/cert) [`codes`](https://github.com/fastlane/codes) [`spaceship`](https://github.com/fastlane/spaceship) [`pilot`](https://github.com/fastlane/pilot) [`gym`](https://github.com/fastlane/gym)
* [nomad-cli](http://nomad-cli.com) bundle: [`ios`](https://github.com/nomad/Cupertino) [`apn`](https://github.com/nomad/Houston) [`pk`](https://github.com/nomad/Dubai) [`iap`](https://github.com/nomad/Venice) [`ipa`](https://github.com/nomad/Shenzhen)
* Code quality tools: [`oclint`](http://oclint.org) [`lcov`](http://ltp.sourceforge.net/coverage/lcov.php) [`gcovr`](http://gcovr.com) [`slather`](https://github.com/venmo/slather) [`cloc`](http://cloc.sourceforge.net) [`swiftlint`](https://github.com/realm/SwiftLint)
* XCTest utilities: [`ocunit2junit`](https://github.com/ciryon/OCUnit2JUnit)  [`xcpretty`](https://github.com/supermarin/xcpretty) 
* Simulator utility: [`ios-sim`](https://github.com/phonegap/ios-sim)
* Other utilities: [`splunk-mobile-upload`](https://github.com/xfreebird/splunk-mobile-upload) [`nexus-upload`](https://github.com/xfreebird/nexus-upload) [`crashlytics-upload-ipa`](https://github.com/xfreebird/crashlytics-upload-ipa) [`iosbuilder`](https://github.com/xfreebird/iosbuilder)

## UI Automation

* [`Appium`](http://appium.io) [`Calabash`](http://calaba.sh)

## Web based frameworks

* [`Phonegap`](http://phonegap.com) [`Cordova`](http://cordova.apache.org)

## Other tools
* [`brew`](http://brew.sh) [`rbenv`](https://github.com/sstephenson/rbenv) [`jenv`](https://github.com/gcuisinier/jenv) [`Go`](https://golang.org) [`Node.js`](https://nodejs.org/en/) 
* [`JDK 7`](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html) [`JDK 8`](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
* [`Sonar runner`](https://github.com/SonarSource/sonar-runner)
* [`xcode-install`](https://github.com/neonichu/xcode-install) [`customsshd`](https://github.com/xfreebird/customsshd) 
* [`GitHub Release tool`](github.com/aktau/github-release)
* [`Build machine info page service`](https://github.com/xfreebird/osx-build-machine-info-service) 
* [`Provisioning Profiles Management utility`](https://github.com/xfreebird/refresh-ios-profiles) 
* [`Bamboo Agent Installer helper`](https://github.com/xfreebird/bamboo-agent-utility)


# Build machine management

View all information about installed packages, certificates and profiles from the build machine by browsing the build machine IP or name in browser [http://build-machine-name](http://build-machine-name)

## iOS provsioning profiles

Update all provisioning profiles:

```shell
export APPLE_USERNAME="myapple@gmail.com"
export APPLE_PASSWORD="supersecret"
refresh-ios-profiles "Team name1, Team name 2, Other team name"
```

✅ You could create a Jenkins job that runs this script on the slave (build machine) on demand or regularly 

## iOS signing certificates

Use ```iosbuilder.keychain``` to install certificates. It has a blank password (e.g. no passowrd). You don't have to expose the system's user password in order to unlock the keychain on the build machine. 

Install additional singing certificate:

```shell
security unlock-keychain -p '' ~/Library/Keychains/iosbuilder.keychain
security import /path/to/Certificate.p12 -k ~/Library/Keychains/iosbuilder.keychain -P '' -A
```

✅ You could create a Jenkins job that runs this script on the slave (build machine) on demand to install the certificate. 

## Java enviroment

The Java environment is controlled by ```jenv```.

To get current java versions:
```shell
jenv version
```

To list installed java versions:
```shell
jenv versions
```

To change default java version:
```shell
jenv global 1.8
```

To change shell session default java version:
```shell
jenv shell 1.8
```

## Updating the build machine

To update installed software you can use the ```mobile-ci-update``` utility. By default it will update the ```OSX```, ```Xcode```, ```Android SDK Componets```, ```Ruby packages```, ```Brew packages```, ```NPM packages```, ```PHP packages```.

```shell
export PASSWORD="osx_user_password"
export APPLE_USERNAME="apple.developer@mail.com"
export APPLE_PASSWORD="secret"
mobile-ci-update
```

Or if you need to update specific component:

```bash
export PASSWORD="osx_user_password"
export APPLE_USERNAME="apple.developer@mail.com"
export APPLE_PASSWORD="secret"
mobile-ci-update xcode
```

Available options are:
* ```osx``` - Updates the OSX. ⚠️ Requires env variables ```PASSWORD```, ```APPLE_USERNAME```, ```APPLE_PASSWORD```
* ```xcode``` - Installs the latest Xcode. ⚠️ Requires env variables ```PASSWORD```, ```APPLE_USERNAME```, ```APPLE_PASSWORD```
* ```android``` - Updates installed Android SDK
* ```brew``` - Updates installed brew packages
* ```gem``` - Updates installed Ruby gems
* ```cask``` - Updates installed Brew casks (e.g. java, java7, oclint)
* ```npm``` - Updates installed npm packages
* ```php``` - Updates installed php packages. ⚠️ Requires env variables ```PASSWORD```, ```APPLE_USERNAME```, ```APPLE_PASSWORD```

## Upgrading manually

In case you prefer upgrading the software manually.

### Android SDK

Install all updates:

```shell
packages=""
for package in $(android list sdk --no-ui | \
	grep -v -e "Obsolete" -e "Sources" -e  "x86" -e  "Samples" \
	-e  "Documentation" -e  "MIPS" -e  "Android TV" \
	-e  "Glass" -e  "XML" -e  "URL" -e  "Packages available" \
	-e  "Fetch" -e  "Web Driver" | \
	cut -d'-' -f1)
do
	 if [ $package != "1" ]; then
   	packages=$(printf "${packages},${package}")
   fi
done

( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --filter "$packages"
```
### Xcode 

All installed Xcodes are following the ```Xcode-<version>.app``` naming convention. 
The ```/Applications/Xcode.app``` is a symbolic link to the current default Xcode.

To install a new version of Xcode use ```xcode-install```:

```shell
export XCODE_INSTALL_USER="apple.developer@gmail.com"
XCODE_INSTALL_PASSWORD="secret"
xcode-install install 7.1
sudo xcodebuild -license accept
```

### Brew packages

Update all packages:

```shell
brew update
brew upgrade
```

⚠️ Warning: If ```android-sdk``` was updated also run the steps from the ```Android SDK```.

### Brew Cask packages

Update all packages:

```shell
  brew update
  brew upgrade brew-cask
  brew cask update
```

### Gem packages

⚠️ Don't use ```sudo``` when updating Ruby packages, because we are using [`rbenv`](https://github.com/sstephenson/rbenv).
Update all packages:

```shell
gem update -p
```

⚠️ Temporary [fix for cocoapods](https://github.com/CocoaPods/CocoaPods/issues/2908)

```shell
gem uninstall psych --all
gem install psych -v 2.0.0
```

### Npm packages

Update all packages:

```shell
npm update -g
```


### PHP packages

Update package:

```shell
sudo easy_install <package_name>
```


