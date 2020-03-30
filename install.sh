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
	yes | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

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

if [[ ! -f "${HOME}/.ssh/id_rsa" ]]; then
  ssh-keygen -t rsa -b 4096 -f "${HOME}/.ssh/id_rsa" -N '' > /dev/null 2>&1

  echo ""
  echo "!!! Insert the following public ssh key in you Gitlab account [https://gitlab.com/profile/keys] !!!"

  echo ""
  cat "${HOME}/.ssh/id_rsa.pub"
  echo ""

  read -n 1 -s -r -p "Press any key to continue"
fi

if [[ ! -d "${HOME}"/developer-companion ]]; then
  git clone git@gitlab.com:7graus/developer-companion.git "${HOME}"/developer-companion
else
  git -C "${HOME}"/developer-companion pull
fi

bash "${HOME}"/developer-companion/install.sh