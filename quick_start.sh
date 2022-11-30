#!/bin/bash
# Go needs to be installed and a proper Go environment needs to be configured

git clone https://github.com/cosmos/relayer.git

# not v2.0.0-rc3 
cd relayer && git checkout v2.2.0-rc1

echo "making rly need minutes..."
make install
if command -v rly >/dev/null 2>&1; then
  echo 'relay install success'
else
  echo 'relay install failed'
  exist 8
fi 

# reuse channels already exist
rm -rf ~/.relayer/config
mkdir -p ~/.relayer/config
curl https://raw.githubusercontent.com/codelaw1/relayer/main/examples/config_GOC.yaml >>~/.relayer/config/config.yaml

# create new relayer account
WALLET=$(rly keys add provider default)

echo "relayer wallet should write down: $WALLET"
ADDR=$(echo $WALLET | jq -r .address)
SEC=$(echo $WALLET | jq -r .mnemonic)

rly keys restore sputnik default "$SEC"


# this may be faild due to facuet limit
echo "deposit prov for relayer account $ADDR"
curl "https://provider-faucet.goc.earthball.xyz/request?address=${ADDR}&chain=provider"
echo "deposit sput"
curl "http://sputnik-faucet.goc.earthball.xyz/request?address=${ADDR}&chain=sputnik"
# echo "deposit pol"
# curl "http://apollo-faucet.goc.earthball.xyz/request?address=${ADDR}&chain=apollo"
echo "deposit gopher"
curl http://gopher-faucet.goc.earthball.xyz/request?address=${ADDR}&chain=gopher
echo "deposit hero"
curl http://hero-faucet.goc.earthball.xyz/request?address=${ADDR}&chain=hero-1

echo "waiting coins filling to relayer account "
sleep 30s

rly q balance provider
rly q balance sputnik
rly q balance hero
rly q balance gopher

echo "relay starting..."
rly start -d 
