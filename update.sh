#!/bin/bash

set -e

if [[ "${UID}" == "0" ]]; then
	echo "Don't run this as root!"
  exit 1
fi

if [[ $(uname) = "Darwin" ]]; then
	DC_OS="macos"
elif [[ $(lsb_release -is) = "Ubuntu" ]]; then
	DC_OS="ubuntu"
else
	echo "Failed: Not supported operating system"
	exit 1
fi

if [[ ${DC_OS} = "macos" ]]; then
	if [[ $(xcode-select -p 1> /dev/null; echo $?) != "0" ]]; then
		xcode-select --install
	fi
fi

if [[ ${DC_OS} = "ubuntu" ]]; then
  sudo apt-get update
fi

if [[ -z $(command -v brew) ]]; then
	yes | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	if [[ ${DC_OS} = "ubuntu" ]]; then
		sudo apt-get install build-essential linuxbrew-wrapper -y
		echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ${HOME}/.profile
		eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
	fi
else
  brew update
fi

if [[ -z $(command -v git) ]]; then
  brew install git
fi

if [[ ! -d "${HOME}/.ssh" ]]; then
  mkdir "${HOME}/.ssh"
fi

mkdir "${HOME}/.ssh/socket"
mkdir "${HOME}/backup-vagrant-dc"

if [[ ! -d "${HOME}"/developer-companion ]]; then
  git clone git@gitlab.com:7graus/developer-companion.git "${HOME}"/developer-companion
else
  mv "${HOME}"/developer-companion "${HOME}/backup-vagrant-dc/"
  git clone git@gitlab.com:7graus/developer-companion.git "${HOME}"/developer-companion
fi

if [[ ! -d "${HOME}"/Vagrant ]]; then
  git clone git@gitlab.com:7graus/operations/vagrant.git "${HOME}"/Vagrant
  ln -sf ~/Vagrant/external/.ssh/config ~/.ssh/config
else  
  mv "${HOME}"/Vagrant "${HOME}/backup-vagrant-dc/"
  git clone git@gitlab.com:7graus/operations/vagrant.git "${HOME}"/Vagrant
  ln -sf ~/Vagrant/external/.ssh/config ~/.ssh/config  
fi

if [[ ! -d "${HOME}"/Sites ]]; then
  mkdir "${HOME}"/Sites
fi

bash "${HOME}"/developer-companion/install.sh
