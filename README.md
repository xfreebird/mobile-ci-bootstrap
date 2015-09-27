# mobile-ci-bootstrap
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
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xfreebird/mobile-ci-bootstrap/master/mobile-ci-bootstrap.sh)"
```

At the end you will have:

* complete **Android** and **iOS** build machine
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
* Latest [Android SDK](https://developer.android.com/sdk/index.html) and [NDK](https://developer.android.com/ndk/index.html) with build tools, emulators etc.
* [Gradle](http://gradle.org)
* [Maven](https://maven.apache.org)
* [Ant](http://ant.apache.org)
* [findbugs](http://findbugs.sourceforge.net)

## iOS
* Latest [Xcode](https://developer.apple.com/xcode/download/)
* [xctool](https://github.com/facebook/xctool)
* [fastlane](https://github.com/KrauseFx/fastlane) bundle ***[fastlane]() [deliver](https://github.com/KrauseFx/deliver) [snapshot](https://github.com/KrauseFx/snapshot) [frameit](https://github.com/fastlane/frameit) [pem](https://github.com/fastlane/PEM) [sigh](https://github.com/KrauseFx/sigh) [produce](https://github.com/fastlane/produce) [cert](https://github.com/fastlane/cert) [codes](https://github.com/fastlane/codes) [spaceship](https://github.com/fastlane/spaceship) [pilot](https://github.com/fastlane/pilot) [gym](https://github.com/fastlane/gym)***
* [nomad-cli](http://nomad-cli.com) bundle ***[ios](https://github.com/nomad/Cupertino) [apn](https://github.com/nomad/Houston) [pk](https://github.com/nomad/Dubai) [iap](https://github.com/nomad/Venice) [ipa](https://github.com/nomad/Shenzhen)***
* [cocoapods](http://cocoapods.org)
* [carthage](https://github.com/Carthage/Carthage)
* Code quality tools ***[oclint](http://oclint.org) [lcov](http://ltp.sourceforge.net/coverage/lcov.php) [gcovr](http://gcovr.com) [slather](https://github.com/venmo/slather)***
* Simulator utility ***[ios-sim](https://github.com/phonegap/ios-sim)***
* Other utilities ***[splunk-mobile-upload](https://github.com/xfreebird/splunk-mobile-upload) [nexus-upload](https://github.com/xfreebird/nexus-upload) [crashlytics-upload-ipa](https://github.com/xfreebird/crashlytics-upload-ipa) [iosbuilder](https://github.com/xfreebird/iosbuilder) [ocunit2junit]()  [xcpretty]() [slather]()***

## UI Automation

* [Appium](http://appium.io)
* [Calabash](http://calaba.sh)

## Web based frameworks

* [Phonegap](http://phonegap.com)
* [Cordova](http://cordova.apache.org)

## Other tools
* [brew](http://brew.sh)
* [customsshd](https://github.com/xfreebird/customsshd) A custom ssh daemon running in user UI session 
* [Sonar runner](https://github.com/SonarSource/sonar-runner)
* [xcode-install](https://github.com/neonichu/xcode-install)
* [Node.js](https://nodejs.org/en/)
* [Go](https://golang.org)
* [JDK 7](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)
* [GitHub Release tool](github.com/aktau/github-release)
* [Build machine info page service](https://github.com/xfreebird/osx-build-machine-info-service)
* [Provisioning Profiles Management utility](https://github.com/xfreebird/refresh-ios-profiles)
* [Bamboo Agent Installer helper](https://github.com/xfreebird/bamboo-agent-utility)


# Build machine management

## Android SDK  

## iOS provsioning profiles

## iOS signing Certificates

## Xcode 

## Brew packages

## Gem packages

## Npm packages

## PHP packages

