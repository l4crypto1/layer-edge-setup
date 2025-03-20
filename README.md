# LayerEdge Light Node Setup Script

# Step 1: Download and Set Up the Light Node
wget -qO- https://raw.githubusercontent.com/linoxbt/layer-edge-setup/main/setup.sh | bash
chmod +x ~/light-node/setup-light-node.sh

# Step 2: Create and Start the Merkle Service Script
cat <<EOF > ~/light-node/start-merkle.sh
#!/bin/bash
cd ~/light-node/risc0-merkle-service
cargo build && cargo run
EOF

chmod +x ~/light-node/start-merkle.sh
~/light-node/start-merkle.sh

# Step 3: Create and Start the LayerEdge Light Node Script
cat <<EOF > ~/light-node/start-light-node.sh
#!/bin/bash
cd ~/light-node
./light-node
EOF

chmod +x ~/light-node/start-light-node.sh
~/light-node/start-light-node.sh

# Step 4: (Optional) Check Points on Dashboard
echo "To check your points, run the following command, replacing YOUR_WALLET_ADDRESS with your actual address:"
echo "curl https://light-node.layeredge.io/api/cli-node/points/YOUR_WALLET_ADDRESS"
