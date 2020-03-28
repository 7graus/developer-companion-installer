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

if [[ ! -d "${HOME}"/developer-companion ]]; then
  git clone git@gitlab.com:7graus/developer-companion.git "${HOME}"/developer-companion
fi

bash "${HOME}"/developer-companion/install.sh