# LayerEdge Light Node Setup Script

# Step 1: Download and Set Up the Light Node
```bash
wget -qO- https://raw.githubusercontent.com/linoxbt/layer-edge-setup/main/setup.sh | bash
```
```bash
chmod +x ~/light-node/setup-light-node.sh
```
Step 2: Start the Merkle Service

```bash
#!/bin/bash
cd ~/light-node/risc0-merkle-service
cargo build && cargo run
```
```bash
bash
chmod +x ~/light-node/start-merkle.sh
```
```bash
~/light-node/start-merkle.sh
```
Step 3: Build and Run the LayerEdge Light Node

```bash
#!/bin/bash
cd ~/light-node
./light-node
```
```bash
chmod +x ~/light-node/start-light-node.sh
```
```bash
~/light-node/start-light-node.sh
```
Step 4: (Optional) Check Points on Dashboard
```bash
curl https://light-node.layeredge.io/api/cli-node/points/YOUR_WALLET_ADDRESS
```
Explanation: Run this command in a terminal, replacing YOUR_WALLET_ADDRESS with your actual wallet address, to check your points via the LayerEdge API.


