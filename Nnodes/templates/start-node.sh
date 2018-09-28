#!/bin/bash

#
# This is used at Container start up to run the constellation and geth nodes
#

set -u
set -e

### Configuration Options
TMCONF=/qdata/tessera-config.json

GETH_ARGS="--datadir /qdata/dd --raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --nodiscover --unlock 0 --password /qdata/passwords.txt"

if [ ! -d /qdata/dd/geth/chaindata ]; then
  echo "[*] Mining Genesis block"
  /usr/local/bin/geth --datadir /qdata/dd init /qdata/genesis.json
fi
echo "[*] Starting Tessera node"
nohup java -jar /usr/local/bin/tessera.jar -configfile $TMCONF >> /qdata/logs/tessera.log 2>&1 &
sleep 2
echo "Waiting until all Tessera nodes are running..."
DOWN=true
k=10
while ${DOWN}; do
    sleep 1
    DOWN=false
    if [ ! -S "/qdata/tessera/tm.ipc" ]; then
        echo "Node is not yet listening on tm.ipc"
        DOWN=true
    fi

    set +e
    result=$(curl -XGET --no-buffer --unix-socket /qdata/tessera/tm.ipc http://localhost:9000/upcheck | tail -n 1)
    set -e
    if [ ! "${result}" == "I'm up!" ]; then
        echo "Node is not yet listening on http"
        DOWN=true
    fi

    k=$((k - 1))
    if [ ${k} -le 0 ]; then
        echo "Tessera is taking a long time to start.  Look at the Tessera logs in qdata/logs/ for help diagnosing the problem."
    fi
    echo "Waiting until all Tessera nodes are running..."

    sleep 5
done

echo "All Tessera nodes started"


sleep 2

echo "[*] Starting node"
PRIVATE_CONFIG=/qdata/tessera/tm.ipc nohup /usr/local/bin/geth $GETH_ARGS 2>>/qdata/logs/geth.log


