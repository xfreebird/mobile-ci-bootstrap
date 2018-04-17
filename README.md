# mobile-ci-bootstrap
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

Automatically downloads, installs and configures all needed software for a headless mobile CI box on OS X.


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

At the end script execution you will have:

* **iOS** and **Android** ready build machine
* User writeable ```/opt/ci/jenkins``` folder for a [Jenkins agent](https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds).
 

# Why ?

To save time, since it doesn't require any user interaction.

# What do you get ?

## Android
* [`Android SDK`](https://developer.android.com/sdk/index.html)
* [`Android NDK`](https://developer.android.com/ndk/index.html)

## iOS
* [`Xcode`](https://developer.apple.com/xcode/download/) 
* [`Carthage`](https://github.com/Carthage/Carthage)
* Code quality tools: [`oclint`](http://oclint.org) [`swiftlint`](https://github.com/realm/SwiftLint) [`lizard`](https://github.com/terryyin/lizard)

## Core

* [`brew`](http://brew.sh) to install various tools without sudo
* [`rbenv`](https://github.com/sstephenson/rbenv) to manage ruby versions sudoless 
* [`bundler`](http://bundler.io) to manage installed ruby gems sudoless
* [`xcode-install`](https://github.com/KrauseFx/xcode-install) to install various versions of xcode
* [`jenv`](https://github.com/gcuisinier/jenv) to manage installed java versions
* [`nvm`](https://github.com/creationix/nvm) to manage node versions sudoless. usefull for cordova, phonegap, ionic, react native
* [`latest jdk`](http://www.oracle.com/technetwork/java/javase/downloads/)
* [`latest git`](https://git-scm.com)


# Build machine management

## Apple Developer Certificates

Never install code siging ceritificates in the login keychain. This will halt the codesiging process run by xcodebuild from ssh session. If you have any private key + certificate for app code signing installed in the login keychain, please remove them.

## Gradle

For CI jobs always use project's [gradle wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html), because different projects use different versions of gradle.

## Automated update/upgrade

To update installed software you can use the ```mobile-ci-update``` utility. By default it will update the ```OSX```, ```Xcode```,  ```Brew packages```

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

* ```osx``` - Updates the OSX. It will not upgrade the OS for major releases (e.g. 10.11 -> 10.12) ⚠️ Requires env variables ```PASSWORD```, ```APPLE_USERNAME```, ```APPLE_PASSWORD```
* ```xcode``` - Installs the latest Xcode. ⚠️ Requires env variables ```PASSWORD```, ```APPLE_USERNAME```, ```APPLE_PASSWORD```
* ```brew``` - Updates installed brew packages (e.g. swiftlint, rbenv)
* ```cask``` - Updates installed Brew casks (e.g. java, oclint)

## Manual update/upgrade management

In case you prefer upgrading the software manually.

### Android SDK

Please use [Google's official documentation](https://developer.android.com/studio/command-line/sdkmanager.html#install_packages) on how to manage the android sdk packages.

### Xcode 

All installed Xcodes are following the ```Xcode-<version>.app``` naming convention. 
The ```/Applications/Xcode.app``` is a symbolic link to the current default Xcode.

To install a new version of Xcode use ```xcode-install```:

```shell
export XCODE_INSTALL_USER="apple.developer@gmail.com"
XCODE_INSTALL_PASSWORD="secret"
xcversion install 9.3
sudo xcodebuild -license accept
```

⚠️ Don't install Xcode from App Store, as it will make harder to switch between Xcode versions.

### Brew and Cask packages

Update all packages:

```shell
brew update
brew upgrade
```

⚠️ Warning: If ```android-sdk``` is updated, please ensure that you have all required packages with the new version.


### Gem packages

* ⚠️ Use only [`bundler`](http://bundler.io) to manage gem versions.
* ⚠️ Don't use ```sudo``` when updating/installing gem packages, because ruby is managed by [`rbenv`](https://github.com/sstephenson/rbenv).

Don't rely on gem versions installed on the machine, alwas manage with [`bundler`](http://bundler.io)


### Node.js versions and packages

Node versions are managed with [`nvm`](https://github.com/creationix/nvm)
npm comes with the installed node version.

⚠️ Each CI job should prepare its Node and npm dependencies, they should not rely on versions installed on the build machine.

For example, if the project need node.js 9 and cordova npm package, then it would execute:

```shell
nvm install 9
npm install -g cordova 
```


### PHP packages

PHP packages are managed with [`easy_install`](http://setuptools.readthedocs.io/en/latest/easy_install.html)

To update a package, run:

```shell
sudo easy_install --upgrade <package_name>
```

### Java enviroment

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
jenv global 10
```

To change shell session default java version:
```shell
jenv shell 10
```


