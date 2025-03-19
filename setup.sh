#!/bin/bash

# Exit on any error
set -e

# Install Go (1.18+ required, using 1.21.8 as an example)
echo "Installing Go..."
wget -q https://go.dev/dl/go1.21.8.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.21.8.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
rm go1.21.8.linux-amd64.tar.gz

# Install Rust (1.81.0+ required)
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Install RISC0 toolchain
echo "Installing RISC0 toolchain..."
curl -L https://risczero.com/install | bash
rzup install

# Clone the Layer Edge Light Node repository
echo "Cloning Layer Edge Light Node repository..."
git clone https://github.com/Layer-Edge/light-node.git ~/light-node

# Display ASCII art
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

# Prompt user for the private key
echo "Please enter your private key for the light node:"
read -s PRIVATE_KEY  # -s hides the input for security

# Create the .env file with the user-provided private key
echo "Setting up .env file..."
cat << EOF > ~/light-node/.env
GRPC_URL=34.31.74.109:9090
CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
ZK_PROVER_URL=http://127.0.0.1:3001
API_REQUEST_TIMEOUT=100
POINTS_API=http://127.0.0.1:8080
PRIVATE_KEY='$PRIVATE_KEY'
EOF

# Build and run risc0-merkle-service
echo "Building and running risc0-merkle-service..."
cd ~/light-node/risc0-merkle-service
cargo build
cargo run &

# Wait a few seconds to ensure risc0 server is up
sleep 5

# Build and run the light node
echo "Building and running the light node..."
cd ~/light-node
go build
./light-node &

echo "Setup complete! Both servers are running in the background."
echo "To monitor, use: ps aux | grep -E 'cargo|light-node'"
echo "To stop, kill the processes with: pkill -f 'cargo run' && pkill -f light-node"
