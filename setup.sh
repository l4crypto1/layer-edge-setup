#!/bin/bash

# Exit on error
set -e

# Stop existing LayerEdge and Merkle screen sessions safely
echo "Checking for and stopping any existing LayerEdge or Merkle sessions..."
screen -ls | grep -q "layeredge" && screen -X -S layeredge quit && echo "Previous LayerEdge session terminated."
screen -ls | grep -q "merkle" && screen -X -S merkle quit && echo "Previous Merkle session terminated."

echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git screen cargo wget

echo "Installing Rust..."
if ! command -v rustc &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

echo "Installing RISC Zero..."
if ! command -v rzup &>/dev/null; then
    curl -L https://risczero.com/install | bash && rzup install
    source $HOME/.cargo/env
fi

# Clean up existing Go installation
echo "Cleaning up any existing Go installation..."
[ -d "/usr/local/go" ] && sudo rm -rf /usr/local/go
[ -d "$HOME/go" ] && rm -rf $HOME/go
[ -d "$HOME/.cache/go-build" ] && rm -rf $HOME/.cache/go-build

echo "Installing Go..."
GO_VERSION="1.23.1"
wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"
export PATH=$PATH:/usr/local/go/bin

# Verify Go installation
echo "Go version installed: $(go version)"

# Clone LayerEdge Light Node
cd ~
echo "Cloning LayerEdge Light Node repository..."
[ -d "light-node" ] && rm -rf light-node
git clone https://github.com/Layer-Edge/light-node.git
cd light-node

# Display banner
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
    read -s -p "Enter your Ethereum private key (64 hex characters, no '0x'): " PRIVATE_KEY
    echo

    if [[ -z "$PRIVATE_KEY" ]]; then
        echo "Error: Private key cannot be empty."
    elif [[ ${#PRIVATE_KEY} -ne 64 ]]; then
        echo "Error: Private key must be exactly 64 characters long (yours is ${#PRIVATE_KEY} characters)."
    elif ! [[ "$PRIVATE_KEY" =~ ^[0-9a-fA-F]{64}$ ]]; then
        echo "Error: Private key must be hexadecimal (0-9, a-f, A-F)."
    else
        echo "Private key validated and stored securely."
        break
    fi
done

# Set environment variables
export GRPC_URL="34.31.74.109:9090"
export CONTRACT_ADDR="cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709"
export ZK_PROVER_URL="http://127.0.0.1:3001"
export API_REQUEST_TIMEOUT="100"
export POINTS_API="light-node.layeredge.io"
export PRIVATE_KEY="$PRIVATE_KEY"

echo "Building and running the LayerEdge Light Node..."
/usr/local/go/bin/go build -o light-node
screen -dmS layeredge ./light-node

echo "Starting the Merkle Service..."
cd risc0-merkle-service
cargo build --release
screen -dmS merkle cargo run --release

echo "LayerEdge and Merkle services are now running in background screen sessions."
echo "Use 'screen -r layeredge' or 'screen -r merkle' to view logs."
