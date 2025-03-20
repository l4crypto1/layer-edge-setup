#!/bin/bash

set -e

# Stop existing sessions
echo "Checking for and stopping existing sessions..."
for session in "layeredge" "merkle"; do
    if screen -list | grep -q "$session"; then
        screen -X -S "$session" quit
        echo "Previous $session session terminated."
    else
        echo "No previous $session session found."
    fi
done

echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git screen cargo

echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

echo "Installing RISC Zero..."
curl -L https://risczero.com/install | bash && rzup install
source /root/.bashrc

echo "Cleaning up existing Go installation..."
sudo rm -rf /usr/local/go
rm -rf $HOME/go $HOME/.cache/go-build

echo "Installing Go..."
wget https://go.dev/dl/go1.23.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
source ~/.profile

echo "Verifying Go version..."
/usr/local/go/bin/go version

cd ~
echo "Cloning LayerEdge Light Node repository..."
[ -d "light-node" ] && rm -rf light-node
git clone https://github.com/Layer-Edge/light-node.git || { echo "Git clone failed"; exit 1; }
cd light-node

# ASCII Art Banner
cat << 'EOF'

    ██╗     ██╗███╗   ██╗ ██████╗ ██╗  ██╗██████╗ ████████╗
    ██║     ██║████╗  ██║██╔═══██╗╚██╗██╔╝██╔══██╗╚══██╔══╝
    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ ██████╔╝   ██║
    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ ██╔══██╗   ██║
    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗██████╔╝   ██║
    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝    ╚═╝

== Follow me on X : @linoxbt ===
=== Layeredge CLI Testnet ====
EOF

# Private key input and validation
while true; do
    read -rsp "Enter your Ethereum private key (64 hex characters, no '0x'): " PRIVATE_KEY
    echo
    PRIVATE_KEY=$(echo -n "$PRIVATE_KEY" | tr -d '[:space:]')
    
    if [[ -z "$PRIVATE_KEY" ]]; then
        echo "Error: Private key cannot be empty."
    elif [[ ${#PRIVATE_KEY} -ne 64 ]]; then
        echo "Error: Private key must be exactly 64 characters long."
    elif ! [[ "$PRIVATE_KEY" =~ ^[0-9a-fA-F]{64}$ ]]; then
        echo "Error: Private key must be hexadecimal (0-9, a-f, A-F)."
    else
        echo "Private Key saved successfully."
        break
    fi
done

echo "Setting up environment variables..."
export GRPC_URL=34.31.74.109:9090
export CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
export ZK_PROVER_URL=http://127.0.0.1:3001
export API_REQUEST_TIMEOUT=100
export POINTS_API=light-node.layeredge.io
export PRIVATE_KEY=$PRIVATE_KEY

echo "Building and running LayerEdge Light Node..."
/usr/local/go/bin/go build
screen -dmS layeredge ./light-node

echo "Starting Merkle Service..."
cd risc0-merkle-service
cargo build && screen -dmS merkle cargo run

echo "Services started in screen sessions. Use 'screen -r layeredge' or 'screen -r merkle' to view logs."
