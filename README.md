# LayerEdge Light Node Setup Guide
This guide provides step-by-step instructions to set up and run a LayerEdge Light Node, including making scripts executable, starting the Merkle Service, and checking points on the dashboard.

## Prerequisites
- A terminal with Bash support.
- Ensure `wget`, `curl`, and `cargo` (Rust's package manager) are installed on your system.
- A wallet address for checking points (optional).

## Step 1: Download and Set Up the Light Node
```bash
wget -qO- https://raw.githubusercontent.com/linoxbt/layer-edge-setup/main/setup.sh | bash
chmod +x ~/light-node/setup-light-node.sh

Step 2: Start the Merkle Service

```bash


#!/bin/bash
cd ~/light-node/risc0-merkle-service
cargo build && cargo run

```bash

chmod +x ~/light-node/start-merkle.sh
~/light-node/start-merkle.sh




Save the first block as start-merkle.sh in the ~/light-node/ directory. Then run the second block in your terminal: the first line makes it executable, and the second starts it in a separate terminal. This builds and runs the Merkle Service.



Step 3: Build and Run the LayerEdge Light Node

```bash


#!/bin/bash
cd ~/light-node
./light-node




```bash


chmod +x ~/light-node/start-light-node.sh
~/light-node/start-light-node.sh

Step 4: (Optional) Check Points on Dashboard


```bash


curl https://light-node.layeredge.io/api/cli-node/points/YOUR_WALLET_ADDRESS



Explanation: Run this command in a terminal, replacing YOUR_WALLET_ADDRESS with your actual wallet address, to check your points via the LayerEdge API.






