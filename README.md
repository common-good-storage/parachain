# Common Good Storage Parachain 

The pallets from the [pallets](https://github.com/common-good-storage/parachain) repo is integrated here and the assumed file structure is

```
polkadot/ (only required for using local polkadot binary)
common-good/
    |
    |----pallets/
    |
    |----parachain/ (current dir)
```

Currently we can run the Relay Chain with docker images / local binary. The instructions below assumes we will run the parachain with local binary. 
___

## Running with Relay Chain Docker Images

`docker` and `docker-compose` is required to run relay testnet - rococo_local 

1. Set up Relay Chain

```sh
# To bring up the network
docker-compose -f docker/docker-compose-rococo-local-relay.yml up 

# To bring up the network in detached mode 
docker-compose -f docker/docker-compose-rococo-local-relay.yml up -d 
```

2. Set up the parachain 

```sh
# Build in common-good/parachain
cargo build --release

# Run in common-good/network
# This writes the data to tmp/
./scripts/start_parachain.sh
```

At this point the Relay Chain client in the parachain should sync with the Relay Chain and Parachain will not be able to produce blocks yet

```
[Parachain] 💤 Idle (0 peers), best: #0 (0xc670…fb88), finalized #0 (0xc670…fb88), ⬇ 0 ⬆ 0
[Relaychain] ✨ Imported #88 (0x4d28…50b6)

```

3. Register parachain

```sh
# Run in common-good/network
./scripts/register_parachain.sh
```
At this point, the parachain should start to produce and finalise blocks. This may take couple of blocks after the extrinsic has been included in a finalised block.

_Example block production:_

```
[Parachain] ✨ Imported #1 (0x3601…2402)
```

_Example blocks finalised:_

```
[Parachain] 💤 Idle (0 peers), best: #4 (0xadcc…a74d), finalized #3 (0x8cd9…6582), ⬇ 0 ⬆ 0
```

4. Clean up

Make sure you clean up `common-good/parachain/tmp/` 

```sh
# To bring down the network 
docker-compose -f docker-compose-rococo-local-relay.yaml down 

# To bring down the network and clear chaindata
docker-compose -f docker-compose-rococo-local-relay.yaml down -v 
```
____

## Running with Relay Chain local binaries
1. Set up relay chain 
```sh
# Polkadot Rococo v1 branch (tested on 8daf974142)

# Build  
cargo build --release --features real-overseer

# Run
# This writes the chain data to alice_data and bob_data
./target/release/polkadot --chain ../common-good/network/chainspec/rococo_local.json -d alice_data --validator --alice --port 30666 --ws-port 6644 --rpc-port 6633
./target/release/polkadot --chain ../common-good/network/chainspec/rococo_local.json -d bob_data --validator --bob --port 30555 --ws-port 5544 --rpc-port 5533
```

2. Same as step 2 above

3. Same as step 3 above

4. Clean up 
Make sure you clean up `common-good/parachain/tmp/` if purging relay chain (i.e. clean up `polkadot/alice_data` and `polkadot/bob_data`)

