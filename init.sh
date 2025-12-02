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

# Update Gemini CLI to latest version
echo ""
echo "Updating Gemini CLI to latest version..."
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install Node.js and npm first."
    exit 1
fi

if npm install -g @google/gemini-cli@latest; then
    echo "Gemini CLI updated successfully"
else
    echo "Error: Failed to update Gemini CLI"
    exit 1
fi

# Check if the .env file exists
echo ""
if [ ! -f "$BASE_DIR/.env" ]; then
    echo "Error: Cannot find the .env file in '$BASE_DIR'. Add the .env file and rerun the init.sh"
    exit 1
fi

# Update GOOGLE_CLOUD_PROJECT in .env file
echo ""
echo "Configuring GOOGLE_CLOUD_PROJECT..."
if [ -n "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "Using GOOGLE_CLOUD_PROJECT from environment: $GOOGLE_CLOUD_PROJECT"
    PROJECT_ID="$GOOGLE_CLOUD_PROJECT"
else
    echo "GOOGLE_CLOUD_PROJECT environment variable is not set."
    read -p "Please enter your Google Cloud Project ID: " PROJECT_ID
    if [ -z "$PROJECT_ID" ]; then
        echo "Error: Project ID cannot be empty."
        exit 1
    fi
fi

# Update the .env file with the project ID
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^GOOGLE_CLOUD_PROJECT=.*/GOOGLE_CLOUD_PROJECT=$PROJECT_ID/" "$BASE_DIR/.env"
else
    # Linux
    sed -i "s/^GOOGLE_CLOUD_PROJECT=.*/GOOGLE_CLOUD_PROJECT=$PROJECT_ID/" "$BASE_DIR/.env"
fi
echo "GOOGLE_CLOUD_PROJECT updated in .env file."

# Grant Secret Manager access to Vertex AI Service Agents
echo ""
echo "Granting Secret Manager access to Vertex AI Service Agents..."

# Get the project number from the project ID
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")

if [ -z "$PROJECT_NUMBER" ]; then
    echo "Error: Failed to get project number for project $PROJECT_ID"
    exit 1
fi

# Construct the Vertex AI Reasoning Engine Service Agent email
RE_SERVICE_AGENT="service-${PROJECT_NUMBER}@gcp-sa-aiplatform-re.iam.gserviceaccount.com"

echo "Adding Secret Manager Secret Accessor role to $RE_SERVICE_AGENT..."
if gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$RE_SERVICE_AGENT" \
    --role="roles/secretmanager.secretAccessor" \
    --quiet; then
    echo "Secret Manager access granted to Reasoning Engine Service Agent"
else
    echo "Error: Failed to grant Secret Manager access to Reasoning Engine Service Agent"
    exit 1
fi

# Construct the Vertex AI Service Agent email
AI_SERVICE_AGENT="service-${PROJECT_NUMBER}@gcp-sa-aiplatform.iam.gserviceaccount.com"

echo "Adding Secret Manager Secret Accessor role to $AI_SERVICE_AGENT..."
if gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$AI_SERVICE_AGENT" \
    --role="roles/secretmanager.secretAccessor" \
    --quiet; then
    echo "Secret Manager access granted to Vertex AI Service Agent"
else
    echo "Error: Failed to grant Secret Manager access to Vertex AI Service Agent"
    exit 1
fi

echo "Secret Manager access granted successfully to all Vertex AI Service Agents"

# Remove all of the files that were added
echo "Cleaning up files that were added..."
rm -rf "$BASE_DIR/$INVENTORY_AGENT_DIR"

# Export the path for adk
export PATH=$BASE_DIR:$PATH
echo "The PATH is: $PATH"

# Delete all the existing prompts
echo ""
echo "Deleting the prompt history and preloading for the demo."
rm -rf ~/.gemini/tmp/*
echo "Prompt history deleted."

echo ""
echo "========================================="
echo "Setup completed successfully!"
echo "Installation directory: $BASE_DIR"
echo "========================================="
