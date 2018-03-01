#!/usr/bin/env sh
set -ex

# Graceful shutdown
trap 'pkill -TERM -P1; electrum daemon stop; exit 0' SIGTERM

# Let's start testnet to create directory for testnet config
if ${ELECTRUM_TESTNET}; then
    electrum ${ELECTRUM_TESTNET} daemon start
    electrum ${ELECTRUM_TESTNET} daemon stop
fi

# Set config
electrum ${ELECTRUM_TESTNET} setconfig rpcuser ${ELECTRUM_USER}
electrum ${ELECTRUM_TESTNET} setconfig rpcpassword ${ELECTRUM_PASSWORD}
electrum ${ELECTRUM_TESTNET} setconfig rpchost 0.0.0.0
electrum ${ELECTRUM_TESTNET} setconfig rpcport 7000

# XXX: Check load wallet or create

# Run application
electrum ${ELECTRUM_TESTNET} daemon start

# Wait forever
while true; do
  tail -f /dev/null & wait ${!}
done
