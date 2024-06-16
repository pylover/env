#! /usr/bin/env bash

ENV=`dirname "$(readlink -f "$BASH_SOURCE")"`
LN="ln -fs"

# Install some useful packages
sudo apt install curl git screen bmon python3-full


read -p "Do you want disable user-tracker, apport and some background tasks? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Platform: $OSTYPE"
    systemctl --user mask tracker-store.service tracker-miner-fs.service \
  	tracker-miner-rss.service tracker-extract.service \
  	tracker-miner-apps.service tracker-writeback.service
  
    sudo apt purge apport* whoopsie*
    sudo apt-mark hold tracker
    sudo apt-mark hold tracker-extract
    sudo apt-mark hold tracker-miner-fs
    sudo chmod -x /usr/libexec/tracker-miner-fs-3
    sudo chmod -x /usr/libexec/tracker-extract-3

    tracker3 reset --filesystem --rss # Clean all database
    tracker3 daemon --terminate

  elif [[ "$OSTYPE" == "freebsd"* ]]; then
    echo "Platform: I Love $OSTYPE"
  else
    echo "Operating system $OSTYPE is not supprted!"
  fi
fi

function linkfile {
	if [ -f $2 ]; then 
		read -p "Do you want to overwrite sym-link: '$2'? [N/y] " 
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			echo "Overwriting: $2"
		    # do dangerous stuff
		else
			return
		fi
	fi
	$LN $1 $2
}


read -p "Do you want to install Vim plugins? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  python3 -m venv ${HOME}/.vim/pyenv
fi




# bash
read -p "Do you want to update the .bash_aliases? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  linkfile "${ENV}/bash_aliases" "${HOME}/.bash_aliases"
fi

# inputrc
read -p "Do you want to update the .inputrc to enable VI editing mode? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo 'set editing-mode vi' > "${HOME}/.inputrc"
fi

# vim
read -p "Do you want to create .vimrc? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  linkfile "${ENV}/vimrc" "${HOME}/.vimrc"
fi

# default editor
read -p "Do you want to set vim as the default editor? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo 'export EDITOR=/usr/bin/vim' | sudo tee /etc/profile.d/editor.sh \
  > /dev/null
fi

# ssh
read -p "Do you want to update the SSH config? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  mkdir -p "${HOME}/.ssh/sshcontrolmasters"
  linkfile "${ENV}/sshconfig" "${HOME}/.ssh/config"
fi

# terminator
read -p "Do you want to update the Terminator config and theme? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  mkdir -p "${HOME}/.config/terminator"
  linkfile "${ENV}/terminatorconfig" "${HOME}/.config/terminator/config"
  linkfile "${ENV}/gtk.css" "${HOME}/.config/gtk-3.0/gtk.css"
fi

# WireGuard 
read -p "Do you want to install wireguard? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo apt install wireguard
  sudo ln -s "${ENV}/wgctl.sh" "/usr/local/bin/wgctl"
fi

# Rotation sensor is anoyying.
read -p "Do you want to remove the io-sensor-proxy package? [N/y] " 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo apt remove iio-sensor-proxy
  sudo systemctl stop iio-sensor-proxy.service 
  sudo systemctl disable iio-sensor-proxy.service 
else 
  read -p "Do you want to stop and disable the io-sensor-proxy package? [N/y] " 
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    sudo systemctl stop iio-sensor-proxy.service 
    sudo systemctl disable iio-sensor-proxy.service 
  fi
fi
