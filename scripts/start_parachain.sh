#!/usr/bin/env bash

# this script runs the parachain-collator after fetching
# appropriate bootnode IDs

set -eu
set -o pipefail

DIRECTORY='./tmp'
if [ ! -d "$DIRECTORY" ]; then
	mkdir ./tmp
fi


gc="./target/release/parachain-collator"

if [ ! -x "$gc" ]; then
    echo "FATAL: no correct executables"
    exit 1
fi

# name the variable with the incoming args so it isn't overwritten later by function calls
gc_args=( "$@" )

alice_p2p="30666"
bob_p2p="30555"
alice_rpc="6633"
bob_rpc="5533"


get_id () {
    rpc="$1"
    curl \
        -H 'Content-Type: application/json' \
        --data '{"id":1,"jsonrpc":"2.0","method":"system_localPeerId"}' \
        "127.0.0.1:$rpc" |\
    jq -r '.result'
}

bootnode () {
    p2p="$1"
    rpc="$2"
    id=$(get_id "$rpc")
    if [ -z "$id" ]; then
        echo >&2 "failed to get id for $node"
        exit 1
    fi
    echo "/ip4/127.0.0.1/tcp/$p2p/p2p/$id"
}

gc_args+=("--base-path=./tmp/" 
    "--parachain-id=100" 
    "--validator"
    "--ws-port=9944" 
    "--rpc-port=9933" 
    "--port=30333" 
    "--out-peers=0" 
    "--in-peers=0"
    "--" 
    "--chain=./docker/chainspec/rococo_local.json" 
    "--execution=wasm"
    "--bootnodes=$(bootnode "$alice_p2p" "$alice_rpc")" 
    "--bootnodes=$(bootnode "$bob_p2p" "$bob_rpc")" 
    "--ws-port=9922"
    "--rpc-port=9911"
    "--port=30334"
    )

set -x
"$gc" "${gc_args[@]}" 
