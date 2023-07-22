#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or use sudo"
  exit
fi

# Check if gnome-extensions is installed
if ! command -v gnome-extensions &> /dev/null
then
    echo "gnome-extensions could not be found, installing..."
    apt-get update
    apt-get install -y gnome-extensions
fi

echo "Enter 'i' for installation or 'r' for removing/reversing changes"
read choice

if [ "$choice" = "i" ]; then
    # Download ubuntu keyring package
    wget http://archive.ubuntu.com/ubuntu/pool/main/u/ubuntu-keyring/ubuntu-keyring_2021.03.26_all.deb

    # Install ubuntu keyring package
    dpkg -i ubuntu-keyring_2021.03.26_all.deb

    # Backup current sources.list
    cp /etc/apt/sources.list /etc/apt/sources.list.bak

    # Add Ubuntu 22.04 repositories to sources.list
    echo "deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse" >> /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list
    echo "deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

    # Update package list
    apt-get update

    # Install libindicator7 library
    apt-get install -y libindicator7

    # Restore original sources.list
    mv /etc/apt/sources.list.bak /etc/apt/sources.list

    # Update package list
    apt-get update

    # Download latest release of Dash to Dock
    wget $(curl -s https://api.github.com/repos/micheleg/dash-to-dock/releases/latest | grep 'browser_' | cut -d\" -f4)

    # Unzip the extension to the correct directory
    unzip dash-to-dock@micxgx.gmail.com.zip -d ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/

    # Enable the extension
    gnome-extensions enable dash-to-dock@micxgx.gmail.com

    # Print a message to reload the shell
    echo "Please reload the shell using 'Alt+F2 r Enter' to apply changes."
elif [ "$choice" = "r" ]; then
    # Disable the extension
    gnome-extensions disable dash-to-dock@micxgx.gmail.com

    # Remove the extension files
    rm -rf ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/

    # Print a message to reload the shell
    echo "Please reload the shell using 'Alt+F2 r Enter' to apply changes."
else
    echo "Invalid choice"
fi
