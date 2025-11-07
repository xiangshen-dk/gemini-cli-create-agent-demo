#!/bin/bash

set -e  # Exit on error

INVENTORY_AGENT_DIR="servicenow_inventory_agent"

# Detect if running from git repo or via curl
if [ -d ".git" ]; then
    # Running locally from git repo
    BASE_DIR=$(pwd)
    echo "Running from local repository: $BASE_DIR"
else
    # Running via curl, need to download files
    INSTALL_DIR="$HOME/gemini-cli-create-agent-demo"
    REPO_RAW_URL="https://raw.githubusercontent.com/xiangshen-dk/gemini-cli-create-agent-demo/main"
    
    echo "Setting up gemini-cli-create-agent-demo in $INSTALL_DIR..."
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Download all necessary files
    echo "Downloading configuration and setup files..."
    FILES=(
        ".env"
        ".gitignore"
        "design-doc-ServiceNow-inventory-agent.md"
        "GEMINI.md"
        "logs.json"
        "README.md"
        "reset.sh"
    )
    
    for file in "${FILES[@]}"; do
        echo "  Downloading $file..."
        if ! curl -sf "$REPO_RAW_URL/$file" -o "$file"; then
            echo "Error: Failed to download $file"
            exit 1
        fi
    done
    
    # Make reset.sh executable
    chmod +x reset.sh
    
    # Move GEMINI.md to ~/.gemini directory
    echo "Setting up GEMINI.md..."
    mkdir -p ~/.gemini
    mv GEMINI.md ~/.gemini/
    echo "GEMINI.md moved to ~/.gemini/"
    
    BASE_DIR="$INSTALL_DIR"
    echo "Files downloaded successfully to $BASE_DIR"
fi

echo "The base directory is '$BASE_DIR'"

# Install Google ADK
echo ""
echo "Installing Google ADK..."
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 is not installed. Please install Python 3 and pip3 first."
    exit 1
fi

if pip3 install google-adk; then
    echo "Google ADK installed successfully"
else
    echo "Error: Failed to install Google ADK"
    exit 1
fi

# Check if the .env file exists
echo ""
if [ ! -f "$BASE_DIR/.env" ]; then
    echo "Error: Cannot find the .env file in '$BASE_DIR'. Add the .env file and rerun the init.sh"
    exit 1
fi

# Remove all of the files that were added
echo "Cleaning up files that were added..."
rm -rf "$BASE_DIR/$INVENTORY_AGENT_DIR"

# Export the path for adk
export PATH=$BASE_DIR:$PATH
echo "The PATH is: $PATH"

# Delete all the existing prompts
echo ""
read -p "Do you want to preload the prompt? **WARNING**: This will delete ALL your Gemini CLI prompt history. (y/n) " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Deleting the prompt history and preloading for the demo."
    rm -rf ~/.gemini/tmp/*
    gemini -y "hi"
    for FOLDER_ID in $(ls -F ~/.gemini/tmp | grep "/$" | grep -v "bin/" | tr -d /); do
        cp "$BASE_DIR/logs.json" ~/.gemini/tmp/$FOLDER_ID/logs.json
    done
    echo "Prompt history preloaded successfully"
else
    echo "Will not preload the prompts."
fi

cd gemini-cli-create-agent-demo

echo ""
echo "========================================="
echo "Setup completed successfully!"
echo "Installation directory: $BASE_DIR"
echo "========================================="
