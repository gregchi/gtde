#!/bin/bash

# Check if the script is run as user with root privileges using sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run with sudo privileges."
  echo "If your user is not in the sudoers file, you can add it with:"
  echo "echo '<your-username> ALL=(ALL:ALL) ALL' | sudo tee -a /etc/sudoers"
  echo "Replace <your-username> with your actual username."
  echo "After this, please log out and log back in to apply the changes."
  exit
fi

# Get the username of the user who launched the sudo command
original_user=$(who am i | awk '{print $1}')

# Group all actions requiring sudo privileges
echo "Performing actions requiring sudo privileges..."

# Update package list
apt-get update

# Check if curl is installed, if not, install it
if ! command -v curl &> /dev/null
then
    echo "curl could not be found, installing it now..."
    apt-get install curl -y
fi

# Check if dbus-x11 is installed, if not, install it
if ! command -v dbus-x11 &> /dev/null
then
    echo "dbus-x11 could not be found, installing it now..."
    apt-get install dbus-x11 -y
fi

# Check if gnome-extensions is installed
if ! command -v gnome-extensions &> /dev/null
then
    echo "gnome-extensions could not be found, installing..."
    apt-get install -y gnome-extensions
fi

# Check if gnome-extensions-extra is installed
if ! command -v gnome-shell-extensions-extra &> /dev/null
then
    echo "gnome-shell-extensions-extra could not be found, installing..."
    apt-get install -y gnome-shell-extensions-extra
fi

# Check if unzip is installed, if not, install it
if ! command -v unzip &> /dev/null
then
    echo "unzip could not be found, installing it now..."
    apt-get install unzip -y
fi

echo "Enter 'i' for installation or 'r' for removing/reversing changes"
read choice

if [ "$choice" = "i" ]; then
    # Add Ubuntu 22.04 repositories to a separate sources.list file
    echo "deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list.d/focal.list
    echo "deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list.d/focal.list
    echo "deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list.d/focal.list
    echo "deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list.d/focal.list

    # Update package list
    apt-get update

    # Install libindicator7 library
    apt-get install -y libindicator7

    # Remove the separate sources.list file
    rm /etc/apt/sources.list.d/focal.list

    # Update package list
    apt-get update

    # Run the rest of the script as the original user
    echo "Performing actions not requiring sudo privileges..."
    sudo -u $original_user bash << EOF

    # Create target folder for the extension
    mkdir -p ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/
    
    # Download latest release of Dash to Dock
    wget $(curl -s https://api.github.com/repos/micheleg/dash-to-dock/releases/latest | grep 'browser_' | cut -d\" -f4)

    # Unzip the extension to the correct directory
    unzip dash-to-dock@micxgx.gmail.com.zip -d ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/

    # Enable the extension
    gnome-extensions enable dash-to-dock@micxgx.gmail.com

    # Print a message to reload the shell
    echo "Please reload the shell using 'Alt+F2 r Enter' to apply changes."

EOF
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
