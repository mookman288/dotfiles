#! /usr/bin/env bash

if [ -z "$1" ];
then
	read -r -p "Is this a fresh install, backup, or restore? [install/backup/restore] " selection
else
	selection=$1
fi

if [ -z "$selection" ];
then
	exit 1
fi

if [ "$selection" == "install" ];
then
	curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
	sudo add-apt-repository ppa:bit-team/stable
	sudo apt-get update && apt-get upgrade
	sudo apt-get install libavcodec-extra zsh bzip2 unzip mariadb-server php php-common php-curl php-dev php-gd php-imap php-json php-mysql libwww-perl perl imagemagick php-imagick lua5.2 apache2 libapache2-mod-php nodejs backintime-qt4
	wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
	git clone https://github.com/romkatv/powerlevel10k.git "${HOME}/.oh-my-zsh/themes/powerlevel10k"
	selection="restore"
fi

declare -a files=("dconf-settings" "gemrc" "gitconfig" "gitignore" "npmignore" "profile" "vimrc" "zshrc")

if [ "$selection" == "backup" ];
then
	echo -e "This will overwrite your hosted dotfiles!"

	read -r -p "Are you sure? [Y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]];
	then
		dconf dump / > "${HOME}/.dconf-settings"

		for i in "${files[@]}"
		do
			cp "${HOME}/.${i}" "./files/${i}"
		done

		git add *
		git commit -m "Automatic backup of configuration."
		git push origin master

		echo "Process complete.".
	else
		exit 1
	fi
else
	echo -e "This will overwrite your existing dotfiles!{$NC}"

	read -r -p "Are you sure? [Y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]];
	then
		for i in "${files[@]}"
		do
			cp "./files/${i}" "${HOME}/.${i}"
		done

		ln -s "${HOME}/.profile" "${HOME}/.zprofile"
		
		read -r -p "Do you want to import dconf settings? [Y/N] " response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]];
		then
			dconf load / < dconf-settings.ini
		fi

		read -r -p "Do you want to change to zsh? [Y/N] " response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]];
		then
			chsh -s /usr/bin/zsh
		fi

		echo "Process complete. Please log out and log back in and then run p10k configure."
	else
		exit 1
	fi
fi

