# LayerEdge Light Node Setup Guide

This guide provides step-by-step instructions to set up and run a LayerEdge Light Node, including making scripts executable, starting the Merkle Service, and checking points on the dashboard.

## Prerequisites
- A terminal with Bash support.
- Ensure `wget`, `curl`, and `cargo` (Rust's package manager) are installed on your system.
- A wallet address for checking points (optional).

## Step 1: Download and Set Up the Light Node
wget -qO- https://raw.githubusercontent.com/linoxbt/layer-edge-setup/main/setup.sh | bash
chmod +x ~/light-node/setup-light-node.sh

Explanation: Run the first command in your terminal to download and execute the setup script. The second command modifies the script's permissions to make it executable. Replace `setup-light-node.sh` with the actual name of your script if it differs.

## Step 2: Start the Merkle Service
#!/bin/bash
cd ~/light-node/risc0-merkle-service
cargo build && cargo run

chmod +x ~/light-node/start-merkle.sh
~/light-node/start-merkle.sh

Explanation: Save the first block (starting with `#!/bin/bash`) as `start-merkle.sh` in the `~/light-node/` directory. Then run the `chmod` command to make it executable, followed by the final command to run it in a separate terminal. This script builds and runs the Merkle Service.

## Step 3: Build and Run the LayerEdge Light Node
#!/bin/bash
cd ~/light-node
./light-node

chmod +x ~/light-node/start-light-node.sh
~/light-node/start-light-node.sh

Explanation: Save the first block (starting with `#!/bin/bash`) as `start-light-node.sh` in the `~/light-node/` directory. Then run the `chmod` command to make it executable, followed by the final command to run it in a separate terminal after the Merkle Service is initialized.

## Step 4: (Optional) Check Points on Dashboard
curl https://light-node.layeredge.io/api/cli-node/points/YOUR_WALLET_ADDRESS

Explanation: Run this command in a terminal, replacing `YOUR_WALLET_ADDRESS` with your actual wallet address, to check your points via the LayerEdge API.

## Notes
- Ensure all scripts are saved with the `.sh` extension and are located in the correct directories.
- Run the Merkle Service and Light Node in separate terminals to keep both processes active.
- If you encounter permission issues, double-check the file paths and permissions.
