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

# Simplified private key input without validation
echo "Please enter your Ethereum private key (64 hex characters, no '0x'):"
read -s PRIVATE_KEY
echo
PRIVATE_KEY=$(echo -n "$PRIVATE_KEY" | tr -d '[:space:]')
echo "Private Key saved successfully."

echo "Setting up environment variables..."
echo "export GRPC_URL=grpc.testnet.layeredge.io:9090" >> ~/.bashrc
echo "export CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709" >> ~/.bashrc
echo "export ZK_PROVER_URL=http://127.0.0.1:3001" >> ~/.bashrc
echo "export API_REQUEST_TIMEOUT=100" >> ~/.bashrc
echo "export POINTS_API=https://light-node.layeredge.io" >> ~/.bashrc
echo "export PRIVATE_KEY=$PRIVATE_KEY" >> ~/.bashrc
source ~/.bashrc

# Build the Light Node (without running it)
echo "Building the LayerEdge Light Node..."
/usr/local/go/bin/go build

echo "Setup complete! See separate commands to make executable and start services."
