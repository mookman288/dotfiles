#! /usr/bin/env bash

#   Black        0;30     Dark Gray     1;30
#   Blue         0;34     Light Blue    1;34
#   Green        0;32     Light Green   1;32
#   Cyan         0;36     Light Cyan    1;36
#   Red          0;31     Light Red     1;31
#   Purple       0;35     Light Purple  1;35
#   Brown/Orange 0;33     Yellow        1;33
#   Light Gray   0;37     White         1;37


blue='\x1B[1;33m'
NC='\x1B[0m' # No Color

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
	sudo apt-get install libavcodec-extra zsh bzip2 unzip mariadb-server php php-common php-curl php-dev php-gd php-imap php-mcrypt php-json php-mysql libwww-perl perl imagemagick php-imagick lua apache2 libapache2-mod-php nodejs backintime-qt4
	wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
	git clone https://github.com/romkatv/powerlevel10k.git "${HOME}/.oh-my-zsh/themes/powerlevel10k"
	selection="restore"
fi

declare -a files=("donf-settings" "gemrc" "gitconfig" "gitignore" "npmignore" "packages" "profile" "vimrc" "zshrc")

if [ "$selection" == "backup" ];
then
	echo -e "${blue}This will overwrite your hosted dotfiles!${NC}"

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

		echo "${blue}Process complete.${NC}".
	else
		exit 1
	fi
else
	echo -e "${blue}This will overwrite your existing dotfiles!{$NC}"

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

		echo "${blue}Process complete. Please log out and log back in and then run p10k configure.${NC}"
	else
		exit 1
	fi
fi

