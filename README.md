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
* Latest [`Android SDK`](https://developer.android.com/sdk/index.html) and [`NDK`](https://developer.android.com/ndk/index.html) with build tools, emulators etc.
* [`Gradle`](http://gradle.org)
* [`Maven 3.0.x`](https://maven.apache.org)
* [`Ant`](http://ant.apache.org)
* [`findbugs`](http://findbugs.sourceforge.net)

## iOS
* Latest [Xcode](https://developer.apple.com/xcode/download/)
* [`xctool`](https://github.com/facebook/xctool)
* [`fastlane`](https://github.com/KrauseFx/fastlane) bundle [`fastlane`](https://github.com/KrauseFx/fastlane) [`deliver`](https://github.com/KrauseFx/deliver) [`snapshot`](https://github.com/KrauseFx/snapshot) [`frameit`](https://github.com/fastlane/frameit) [`pem](https://github.com/fastlane/PEM) [`sigh`](https://github.com/KrauseFx/sigh) [produce](https://github.com/fastlane/produce) [`cert`](https://github.com/fastlane/cert) [`codes`](https://github.com/fastlane/codes) [`spaceship`](https://github.com/fastlane/spaceship) [`pilot`](https://github.com/fastlane/pilot) [`gym`](https://github.com/fastlane/gym)
* [`nomad-cli`](http://nomad-cli.com) bundle [`ios`](https://github.com/nomad/Cupertino) [`apn`](https://github.com/nomad/Houston) [`pk`](https://github.com/nomad/Dubai) [`iap`](https://github.com/nomad/Venice) [`ipa`](https://github.com/nomad/Shenzhen)
* Dependency management tools [`Cocoapods`](http://cocoapods.org) and [`Carthage`](https://github.com/Carthage/Carthage)
* Code quality tools [`oclint`](http://oclint.org) [`lcov`](http://ltp.sourceforge.net/coverage/lcov.php) [`gcovr`](http://gcovr.com) [`slather`](https://github.com/venmo/slather) [`cloc`](http://cloc.sourceforge.net) [`swiftlint`](https://github.com/realm/SwiftLint)
* Simulator utility [`ios-sim`](https://github.com/phonegap/ios-sim)
* Other utilities [`splunk-mobile-upload`](https://github.com/xfreebird/splunk-mobile-upload) [`nexus-upload`](https://github.com/xfreebird/nexus-upload) [`crashlytics-upload-ipa`](https://github.com/xfreebird/crashlytics-upload-ipa) [`iosbuilder`](https://github.com/xfreebird/iosbuilder) [`ocunit2junit`](https://github.com/ciryon/OCUnit2JUnit)  [`xcpretty`](https://github.com/supermarin/xcpretty) [`slather`](https://github.com/venmo/slather)

## UI Automation

* [`Appium`](http://appium.io)
* [`Calabash`](http://calaba.sh)

## Web based frameworks

* [`Phonegap`](http://phonegap.com)
* [`Cordova`](http://cordova.apache.org)

## Other tools
* [`brew`](http://brew.sh)
* [`customsshd`](https://github.com/xfreebird/customsshd) A custom ssh daemon running in user UI session 
* [`Sonar runner`](https://github.com/SonarSource/sonar-runner)
* [`xcode-install`](https://github.com/neonichu/xcode-install)
* [`Node.js`](https://nodejs.org/en/)
* [`Go`](https://golang.org)
* [`JDK 7`](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)
* [`JDK 8`](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
* [`GitHub Release tool`](github.com/aktau/github-release)
* [`Build machine info page service`](https://github.com/xfreebird/osx-build-machine-info-service)
* [`Provisioning Profiles Management utility`](https://github.com/xfreebird/refresh-ios-profiles)
* [`Bamboo Agent Installer helper`](https://github.com/xfreebird/bamboo-agent-utility)


# Build machine management

View all information about installed packages, certificates and profiles from the build machine by browsing the build machine IP or name in browser [http://build-machine-name](http://build-machine-name)

## Android SDK

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

## iOS provsioning profiles

Update all provisioning profiles:

```shell
export APPLE_USERNAME="myapple@gmail.com"
export APPLE_PASSWORD="supersecret"
refresh-ios-profiles "Team name1, Team name 2, Other team name"
```

⚠️ Warning: This command will fail if there are no profiles in the account (Developer or Distribution)

✅ You could create a Jenkins job that runs this script on the slave (build machine) on demand or regularly 

## iOS signing Certificates

Use ```iosbuilder.keychain``` to install certificates. It has a blank password (e.g. no passowrd). You don't have to expose the system's user password in order to unlock the keychain on the build machine. 

Install additional singing certificate:

```shell
security unlock-keychain -p '' ~/Library/Keychains/iosbuilder.keychain
security import /path/to/Certificate.p12 -k ~/Library/Keychains/iosbuilder.keychain -P '' -A
```

✅ You could create a Jenkins job that runs this script on the slave (build machine) on demand to install the certificate. 

## Xcode 

All installed Xcodes are following the ```Xcode-<version>.app``` naming convention. 
The ```/Applications/Xcode.app``` is a symbolic link to the current default Xcode.

To install a new version of Xcode use ```xcode-install```:

```shell
xcode-install install 7.1
sudo xcodebuild -license accept
```

## Brew packages

Update all packages:

```shell
brew update
brew upgrade
```

⚠️ Warning: If ```android-sdk``` was updated also run the steps from the ```Android SDK```.

## Gem packages

Update all packages:

```shell
gem update -p
```

## Npm packages

Update all packages:

```shell
npm update -g
```


## PHP packages

Update package:

```shell
sudo easy_install <package_name>
```


