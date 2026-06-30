#!/bin/bash

INVENTORY_AGENT_DIR="servicenow-inventory-agent"

# Remove all of the files that were added.
echo "Cleaning up files that were added"
rm -rf servicenow_inventory_agent

# Delete all the existing prompts
read -p "Do you want to delete the prompt history? **WARNING**: This will delete ALL your Antigravity CLI prompt history. (y/n) " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Deleting the prompt history and preloading for the demo."
    rm -rf ~/.gemini/antigravity-ide/brain/*
else
    echo "Will not preload the prompts."
fi