#!/bin/bash
# install.sh - Install dependencies and set up initial structure
# Can be called from parent directory: scripts/install.sh
# Or from within scripts directory: ./install.sh

# Ensure we're working with the correct paths regardless of where script is called from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to the root directory to ensure all commands run from there
cd "$ROOT_DIR"

echo "Installing dependencies..."
rokit install
wally install

echo "Setting up directory structure..."
# Creating the Meta folder if it doesn't exist
mkdir -p places/game/src/Meta

# Creating the initial Version file ONLY if it doesn't already exist
VERSION_FILE="places/game/src/Meta/VERSION.model.json"
if [ ! -f "$VERSION_FILE" ]; then
    echo "Creating initial VERSION file..."
    echo '{
    "ClassName": "StringValue",
    "Properties": {
        "Value": "local"
    }
}' > "$VERSION_FILE"
else
    echo "VERSION file already exists, skipping creation."
fi

# Install git post-merge hook
echo "Setting up git post-merge hook..."
HOOKS_DIR="$ROOT_DIR/.git/hooks"
POST_MERGE_HOOK="$HOOKS_DIR/post-merge"

# Ensure hooks directory exists
mkdir -p "$HOOKS_DIR"

# Create the hook file
cat > "$POST_MERGE_HOOK" << 'EOF'
#!/bin/bash

# Git post-merge hook - runs after git pull operations complete

# Get the repository root directory
REPO_ROOT="$(git rev-parse --show-toplevel)"

echo "Post-pull hook: Running setup script..."

# Check if scripts/setup.sh exists and is executable
if [ -x "$REPO_ROOT/scripts/setup.sh" ]; then
    # Change to repository root directory and run the setup script
    cd "$REPO_ROOT" && ./scripts/setup.sh
    
    # Check if setup script ran successfully
    if [ $? -eq 0 ]; then
        echo "Post-pull setup completed successfully."
    else
        echo "Post-pull setup encountered an error. You may need to run scripts/setup.sh manually."
        exit 1
    fi
else
    echo "Error: scripts/setup.sh not found or not executable."
    echo "Make sure the file exists and has execute permissions (chmod +x scripts/setup.sh)."
    exit 1
fi
EOF

# Make the hook executable
chmod +x "$POST_MERGE_HOOK"
echo "Git hook installed successfully."

# Setting up the project by running setup.sh
echo "Running setup script..."
"$SCRIPT_DIR/setup.sh"

echo "Installation complete."