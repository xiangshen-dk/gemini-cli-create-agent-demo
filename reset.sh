#!/bin/bash

INVENTORY_AGENT_DIR="servicenow-inventory-agent"
CLI_WORKSPACE_REPO_DIR="gemini-cli-workspace"

# Get the absolute path of the gemini-cli-demos directory
BASE_DIR=$(pwd)
echo "The base is '$BASE_DIR'"

# Remove all of the files that were added.
echo "Cleaning up files that were added"
rm -rf servicenow_inventory_agent

# Delete the token for the workspace mcp so that it can trigger the auth again.
# Commenting out for now because this is still in flux with the workspace extension in flux.
# rm -rf $BASE_DIR/$CLI_WORKSPACE_REPO_DIR/workspace-mcp-server/token.json

# Delete all the existing prompts
read -p "Do you want to delete the prompt history? **WARNING**: This will delete ALL your Gemini CLI prompt history. (y/n) " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Deleting the prompt history and preloading for the demo."
    rm -rf ~/.gemini/tmp/*
    for FOLDER_ID in $(ls -F ~/.gemini/tmp | grep "/$" | grep -v "bin/" | tr -d /); do
        cp $BASE_DIR/logs.json ~/.gemini/tmp/$FOLDER_ID/logs.json
    done
else
    echo "Will not preload the prompts."
fi