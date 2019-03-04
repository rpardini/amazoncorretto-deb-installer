# Debian/Ubuntu installer packages for Amazon Corretto

# TL;DR

This repo produces Ubuntu (and Debian) packages which download and install Amazon Corretto.

- for Ubuntu: check out [ppa:rpardini/amazoncorretto](https://launchpad.net/~rpardini/+archive/ubuntu/amazoncorretto) 
  or see instructions below
- for Debian: there's an APT repo hosted here at Github Pages, see below for instructions.

# Info for final users

This is far from production ready!
Use these packages at your own risk.

## For Ubuntu:

```bash
# only use this on test/throwaway machines as of March/2019, until we get more testing done
sudo add-apt-repository --yes ppa:rpardini/amazoncorretto
sudo apt-get update
# install AdoptOpenJDK (full JDK) 8 with Hotspot and (via recommends) set it as the system default
# you can replace 8 with 11.
sudo apt-get install amazoncorretto-8-installer 
```

```bash
# also available are separate packages for some <version>-<JDK/JRE>-<JVM> combinations,
# to get a complete listing use:  
sudo apt-cache search amazoncorretto
```

## For Debian:

```bash
# update and install support for https:// sources if not already installed
[[ ! -f /usr/lib/apt/methods/https ]] && sudo apt-get update && sudo apt-get install apt-transport-https
# add my key to trusted APT keys 
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A66C5D02
# add the package repo to sources 
echo 'deb https://rpardini.github.io/amazoncorretto-deb-installer stable main' > /etc/apt/sources.list.d/rpardini-amazoncorretto.list 
# update from sources
sudo apt-get update 
# install a JDK, see above instructions for Ubuntu for other variants as well
sudo apt-get install amazoncorretto-8-installer
```

# Forked from

This was forked from [my original AdoptOpenJDK packages](https://github.com/rpardini/adoptopenjdk-deb-installer) -- see there for more info.

# Credits

* Amazon Corretto is Amazon's OpenJDK distro.
* [Alin Andrei/webupd8](https://launchpad.net/~webupd8team/+archive/ubuntu/java) for the original `oracle-jdk8-installer` from which I started this work
* Jesper Birkestrøm for providing [debsign_osx.sh](https://gist.github.com/birkestroem/ad4866ae7b823820bf51)
