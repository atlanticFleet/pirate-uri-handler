#!/bin/bash -
#
# pirate-uri-handler installation script
#
# 2024-05-13: warelock
#
# Prerequisites: jq pirate-cli yad
#
# This script will install the Pirate Chain "pirate-uri-handler.sh" utility
#

# Make sure these are not quoted
pirate_conf=~/.komodo/PIRATE/PIRATE.conf
      netrc=~/.komodo/PIRATE/.netrc

# Introduce ourselves to the user, tell them what we want to do, and nicely
# handle getting sudo root privileges.
echo ""
echo "ATTENTION: This script will attempt to install the Pirate Chain Treasure"
echo "           Chest \"pirate-uri-handler.sh\" utility. It integrates"
echo "           your web browser with your Pirate Chain Treasure Chest"
echo "           private cryptocurrency wallet software. It will require"
echo "           elevated, "sudo root" priveleges."
echo ""
echo "           If prompted, please enter the password for your non-root user"
echo "           account below."
echo ""
sudo -v
echo ""

# Install prerequisite packages
sudo apt update
sudo apt install -y jq yad

# Transfer Pirate URI handling authority away from Treasure Chest to
# "pirate-uri-handler.sh", instead
[ -e /usr/share/applications/pirate-qt.desktop ] && \
  sudo sed -i "s/^MimeType/#MimeType/" /usr/share/applications/pirate-qt.desktop
[ -e ~/.local/share/applications/pirate-qt.desktop ] && \
  sed -i "s/^MimeType/#MimeType/" ~/.local/share/applications/pirate-qt.desktop
cp pirate-uri-handler.desktop ~/.local/share/applications/
sudo update-desktop-database
update-desktop-database ~/.local/share/applications

# Install the "pirate-uri-handler.sh" utility
sudo cp pirate-uri-handler.sh /usr/local/bin/

# Extract RPC client authentication information into a form curl can securely
# use
touch $netrc
chmod 600 $netrc
echo "machine 127.0.0.1" > $netrc
egrep "rpcuser|rpcpassword" ~/.komodo/PIRATE/PIRATE.conf | sed -e 's/rpcuser=/  login /; s/rpcpassword=/  password /' >> $netrc

# See if the user installed "pirate-cli", telling them to do it if they
# haven't already
if [ -z "$(which pirate-cli)" ]; then
  echo ""
  echo ""
  echo "----------"
  echo ""
  echo "WARNING: Pirate Chain command line utility "pirate-cli" not detected."
  echo "         Please install it from the Treasure Chest respository on "
  echo "         Github."
fi

echo ""
echo "----------"
echo ""
echo "The \"pirate-uri-handler.sh\" utility has been successfully installed."
echo "You should now be able to click on Pirate URIs on any web page and"
echo "see a staged transaction pop up, so you can edit it, and optionally"
echo "submit it to Treasure Chest for processing."
echo ""
echo "In raw form, Pirate URIs look like this:"
echo ""
echo "pirate:zs14l5qpyh7vf94f3vwuqmgrfm9ja8692ps7ztzl5e9xk7u8et0jd99f8k326rqt2htk42kz4y6q4p?amount=0.00000001&message=AMZN%20GIFT&label=Rockin%20Prices%20Crypto"
echo ""
echo "Pirate URIs can be embedded into any web page where an HTML link would"
echo "go. This installation script can be safely re-run at any time."
echo ""
