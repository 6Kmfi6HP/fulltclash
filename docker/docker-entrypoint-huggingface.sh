#!/bin/bash

echo "extracting env..."
env
echo "Starting FullTclash..."

# Create config if it doesn't exist
if [[ ! -f /app/resources/config.yaml ]]; then
cat > /app/resources/config.yaml <<EOF
admin:
  - ${admin}
bot:
 api_id: ${api_id}
 api_hash: ${api_hash}
 bot_token: ${bot_token}
EOF

if [ ! -z "${s5_proxy}" ]; then
sed -i '/bot:/a\ proxy: '"${s5_proxy}" /app/resources/config.yaml
fi
if [ ! -z "${http_proxy}" ]; then
  echo "proxy: ${http_proxy}" >> /app/resources/config.yaml
fi
fi

# Function to cleanup background processes
cleanup() {
    echo "Cleaning up..."
    kill $(jobs -p)
    exit 0
}

# Trap SIGTERM and SIGINT
trap cleanup SIGTERM SIGINT

# Start Python HTTP server in background with nohup
nohup python -m http.server 7860 > /app/logs/http_server.log 2>&1 &

# Start the main application
python main.py

# Keep the script running to handle signals
wait