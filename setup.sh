#!/bin/bash

# Function to check for errors and exit if any command fails
set -e

# Stop any existing LayerEdge and Merkle screen sessions
echo "Checking for and stopping any existing LayerEdge or Merkle sessions..."
if screen -list | grep -q "layeredge"; then
    screen -X -S layeredge quit
    echo "Previous LayerEdge session terminated."
else
    echo "No previous LayerEdge session found."
fi

if screen -list | grep -q "merkle"; then
    screen -X -S merkle quit
    echo "Previous Merkle session terminated."
else
    echo "No previous Merkle session found."
fi

echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git screen cargo

echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

echo "Installing RISC Zero..."
curl -L https://risczero.com/install | bash && rzup install
source /root/.bashrc

# Clean up any existing Go installation and caches
echo "Cleaning up any existing Go installation..."
sudo rm -rf /usr/local/go
rm -rf $HOME/go
rm -rf $HOME/.cache/go-build

echo "Installing Go..."
wget https://go.dev/dl/go1.23.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
source ~/.profile

# Verify Go installation
echo "Verifying Go version..."
/usr/local/go/bin/go version

# Ensure we're in the home directory before cloning
cd ~

echo "Cloning LayerEdge Light Node repository..."
if [ -d "light-node" ]; then
    echo "Directory 'light-node' already exists. Removing it to re-clone..."
    rm -rf light-node
fi
git clone https://github.com/Layer-Edge/light-node.git
cd light-node

# Display ASCII Art Banner
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

# Prompt for private key and validate input
while true; do
    echo
    read -rsp "Enter your Ethereum private key (hex characters, no '0x'): " PRIVATE_KEY
    echo

    # Trim whitespace (in case of accidental spaces)
    PRIVATE_KEY=$(echo -n "$PRIVATE_KEY" | tr -d '[:space:]')

    # Debugging Output: Show length of private key entered
    echo "Debug: Private key length entered: ${#PRIVATE_KEY}"

    if [[ -z "$PRIVATE_KEY" ]]; then
        echo "Error: Private key cannot be empty."
    elif ! [[ "$PRIVATE_KEY" =~ ^[0-9a-fA-F]+$ ]]; then
        echo "Error: Private key must be hexadecimal (0-9, a-f, A-F)."
    else
        echo "Private key validated and stored securely."
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

echo "Building and running the LayerEdge Light Node..."
/usr/local/go/bin/go build
./light-node &

echo "Starting the Merkle Service..."
cd risc0-merkle-service
cargo build && cargo run
