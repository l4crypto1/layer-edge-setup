# layer-edge-setup
LayerEdge CLI script - for Mobile and PC
# Layer Edge Light Node Setup
This script sets up the Layer Edge Light Node with `risc0-merkle-service` and the Go-based `light-node`, including dependencies, your private key prompt, and automatic startup.

## Run the Setup

Choose one of the commands below to fetch and execute the script. Enter your private key when prompted.

### Using `wget`
<pre><code>wget -qO- https://raw.githubusercontent.com/linoxbt/layer-edge-setup/main/setup.sh | bash</code></pre>

### Using `curl`
<pre><code>curl -sL https://raw.githubusercontent.com/linoxbt/layer-edge-setup/main/setup.sh | bash</code></pre>

## Monitoring and Stopping
- Check running processes: `ps aux | grep -E 'cargo|light-node'`
- Stop the servers: `pkill -f 'cargo run' && pkill -f light-node'`

Follow me on X: [@linoxbt](https://x.com/linoxbt)
