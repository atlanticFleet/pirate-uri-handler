#!/bin/bash -
#
# pirate-uri-handler
#
# 2024-05-13: warelock
#
# Prerequisites: jq pirate-cli yad
#
# This script will take a Pirate URI transaction request string as an argument 
# on the command line, prompt the user to make any desired changes, then 
# attempt to send it to Treasure Chest. This will only work if Treasure Chest 
# is in an unlocked state.
#
# For this to work, you have to comment out the "MimeType" line in the 
# "~/.local/share/applications/pirate-qt.desktop" file. You then need to have 
# a new desktop file for this script, which has the "MimeType" line from the 
# old desktop file.  You then need to update the desktop database to enable 
# the new desktop file as the handler for Pirate URIs:
#
# $ update-desktop-database ~/.local/share/applications
#
# You can see which desktop file handles Pirate URIs with this command:
#
# $ xdg-mime query default x-scheme-handler/pirate
#

# Capture the Pirate URI from the command line. Make sure the Pirate URI 
# either has no embedded blanks or is a quoted string.
uri="$1"

# Make sure these are not quoted
pirate_conf=~/.komodo/PIRATE/PIRATE.conf
      netrc=~/.komodo/PIRATE/.netrc

window_title="Pirate Chain URI Handler"

# Decode RFC 3986 formatted URIs (percent-encoded)
function urldecode() { 
  : "${*//+/ }"; 
  echo -e "${_//%/\\x}"; 
}

# Extract the components of the Pirate URI
   dest=$(urldecode "$uri" | sed -e 's/pirate://; s/\?.*//')
 amount=$(urldecode "$uri" | sed -e 's/.*\?amount=//; s/\&.*//')
message=$(urldecode "$uri" | sed -e 's/.*\?message=//; s/\&.*//')
  label=$(urldecode "$uri" | sed -e 's/.*\?label=//; s/\&.*//')

# Pull RPC connection and authentication parameters from Treasure
# Chest's local "PIRATE.conf" configuration file
    rpcbind=$(grep "^rpcbind="     "$pirate_conf" | awk -F= '{print $2}')
    rpcport=$(grep "^rpcport="     "$pirate_conf" | awk -F= '{print $2}')

# Pull all addresses with corresponding balances.
# We have to resort to using curl, because "pirate-cli z_getbalances"
# doesn't convert "true"/"false" strings to boolean values. This
# is required to get all balances, even from "watch only" addresses.
# We also format the address/balance list for use by yad form editable
# combo boxes. This will only return addresses with positive,
# non-zero balances.
addresses_with_balances=$( \
  curl -s --netrc-file $netrc \
    --data-binary '
      { 
        "jsonrpc": "1.0", 
        "id":"curltest", 
        "method": "z_getbalances", 
        "params": [true] 
      }' \
    -H 'content-type: text/plain;' http://$rpcbind:$rpcport/ | \
  jq -r '.result[] | "\(.address) (\(.balance))"' | \
  tr "\n" "|" \
)

# Main loop
#
# Keep retrying until the user either cancels out or the transaction goes
# through
#
until [ ]; do

  # Let the user edit the transaction details and approve for
  # submission to Treasure Chest
  response=$( \
    yad \
      --form \
      --center \
      --width=900 \
      --item-separator="\|" \
      --title="$window_title" \
      --text="Please confirm the payment request" \
      --field="Source":CBE \
      --field="Destination" \
      --field="Amount" \
      --field="Memo" \
        "$source|$addresses_with_balances" \
        "$dest" \
        "$amount" \
        "$message" \
  )

  # If the user cancels out, deciding not to submit the transaction
  # to Treasure Chest, exit out
  [ $? -ne 0 ] && exit

  # Extract the Pirate URI components from the user's input. We
  # ignore any additional balance text that might be present in
  # the "source" and "dest" fields.
   source=$(echo "$response" | awk -F\| '{print $1}' | awk '{print $1}')
     dest=$(echo "$response" | awk -F\| '{print $2}' | awk '{print $1}')
   amount=$(echo "$response" | awk -F\| '{print $3}')
  message=$(echo "$response" | awk -F\| '{print $4}')

  # If a memo was provided, encode it in hex so the "z_sendmany" command will 
  # accept it
  [ "$message" ] && \
    hex_encoded_message=", \"memo\": \"$(ascii2hex "$message")\""

  # Attempt to send the transaction to Treasure Chest. This requires the
  # Treasure Chest GUI to be in a user-unlocked state.
  pirate-cli \
    z_sendmany \
    "$source" \
    "\
      [
        {
          \"address\": \"$dest\", 
          \"amount\": $amount$hex_encoded_message
        }
      ] \
    " >/dev/null 2>&1

  # Detect whether or not an error occurred
  case $? in
    5)
      alert="ERROR: Source address not found in your wallet"
      sendmany_error="TRUE"
      ;;
    13)
      alert="ERROR: Please unlock Treasure Chest and try again"
      sendmany_error="TRUE"
      ;;
    *)
      alert="Transaction successfully sent to Treasure Chest"
      sendmany_error=""
      ;;
  esac

  # Let the user know the results
  echo "$alert" | \
  yad \
    --text-info \
    --center \
    --width=400 \
    --fontname=Ubuntu \
    --title="$window_title" \
    --wrap \
    --justify=center \
    --button=OK

  # If everything went OK, exit out
  [ -z "$sendmany_error" ] && exit

done
