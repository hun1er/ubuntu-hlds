#!/bin/bash
set -eu

# Accept the Steam license agreement
echo steam steam/question select "I AGREE" | debconf-set-selections
echo steam steam/license note '' | debconf-set-selections

# Install SteamCMD
apt-get install -y steamcmd

# Create symbolic links to the SteamCMD executable
ln -s /usr/games/steamcmd /usr/bin/steamcmd
ln -s /usr/games/steamcmd /usr/local/bin/steamcmd

# Update SteamCMD and verify latest version
steamcmd +quit

# Fix missing directories and libraries
mkdir -p "$HOME/.steam"
ln -s "$HOME/.local/share/Steam/steamcmd/linux32" "$HOME/.steam/sdk32"
ln -s "$HOME/.local/share/Steam/steamcmd/linux64" "$HOME/.steam/sdk64"
