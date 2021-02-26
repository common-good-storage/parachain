#!/usr/bin/env bash

set -e

# This exports genesis state for default chain = local
./target/release/parachain-collator export-genesis-state --parachain-id=100 ./tmp/parachain_gs

# This exports initial runtime wasm for default chain = local
./target/release/parachain-collator export-genesis-wasm ./tmp/parachain_wasm

# Make sure all dependencies are installed
yarn install --cwd=./docker/register 
 
# Run the polkadotjs program to register a parachain
# TODO: we can also use polkadot-js-cli but this might be better if we do it all in docker 
# to avoid having to install it globally
node ./docker/register \
    127.0.0.1 6644 \
    ../../tmp/parachain_wasm \
    ../../tmp/parachain_gs \
    100


