#/bin/bash

/bitcoin/bin/bitcoind -testnet &
counterparty-server --testnet start &
sleep inf
