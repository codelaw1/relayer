#!/bin/bash
# Go needs to be installed and a proper Go environment needs to be configured
git clone https://github.com/cosmos/relayer.git
# 官方文档 v2.0.0-rc3 太旧有出入
cd relayer && git checkout v2.2.0-rc3
echo "making rly need minutes..."
# make install
if command -v rly >/dev/null 2>&1; then
  echo 'relay install success'
else
  echo 'relay install failed'
  exist 8
fi 
# reuse channels already exist
curl https://raw.githubusercontent.com/codelaw1/relayer/main/examples/config_GOC.yaml >>~/.relayer/config/config.yaml

# create new relayer account
WALLET=$(rly keys add provider  | jq .address)
echo "relayer adddress: $WALLET"

# deposit for relayer account
# this may be faild due to facuet limit
curl https://provider-faucet.goc.earthball.xyz/request?address=$WALLET&chain=provider
curl http://sputnik-faucet.goc.earthball.xyz/request?address=$WALLET&chain=sputnik
# curl http://apollo-faucet.goc.earthball.xyz/request?address=$WALLET&chain=apollo

echo "waiting coins filling to relayer account "
sleep 30s
rly q balance provider
rly q balance sputnik

echo "relay starting..."
rly start -d 
