# Pirate URI Handler

## Overview

The Pirate Chain privacy cryptocurrency's full node wallet software called "Treasure Chest" is currently unable to process Pirate URIs directly. This utility lets you click on a Pirate URI link on any web page, stages the transaction for you to edit, where you can then optionally submit it to Treasure Chest.

Here is an example Pirate URI link in raw form and in link form:

```
pirate:zs14l5qpyh7vf94f3vwuqmgrfm9ja8692ps7ztzl5e9xk7u8et0jd99f8k326rqt2htk42kz4y6q4p?amount=0.00000001&message=AMZN%20GIFT&label=Rockin%20Prices%20Crypto
```

- [Sample Pirate URI Link](pirate:zs14l5qpyh7vf94f3vwuqmgrfm9ja8692ps7ztzl5e9xk7u8et0jd99f8k326rqt2htk42kz4y6q4p?amount=0.00000001&message=AMZN%20GIFT&label=Rockin%20Prices%20Crypto")

## Authors

- warelock

## Prerequisites

- Linux OS
- Additional Linux software
-   jq: Processes JSON output provided via RPC from Treasure Chest
-   yad: Makes GUI popup dialog boxes available to Bash scripts
- Pirate Chain Treasure Chest GUI
- Pirate Chain Treasure Chest CLI (command line RPC client)

## Testing

This software was tested with the following software:

- Ubutnu 22.04 LTS
- Firefox web browser
- Pirate Chain Treasure Chest v5.8.1

NOTE: Expected changes in the next release of Treasure Chest with respect to how it handles RPC commands may break this utility. Check back here after the next release of Treasure Chest to see if this utility has been updated to compensate.

Other operating systems like MacOS and Windows are not supported by this utility, but may be supported either by other Pirate URI handler software or by Treasure Chest itself.

## Installation

### Clone the respository

```
git clone https://github.com/atlanticFleet/pirate-uri-handler.git
```

### Install the handler, including any dependencies

```
bash install.sh
```

## Usage

Click on any Pirate URI link to start the process. You should see a dialog box pop up, letting you customize the transaction details. Make any changes you need to and click the "OK" button to send the transaction to your local Pirate Chain Treasure Chest wallet software. You should then see new transactions show up in your Treasure Chest "Transactions" tab.
