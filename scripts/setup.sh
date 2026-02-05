# Ensure we're working with the correct paths regardless of where script is called from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Installing dependencies..."
rokit install
wally install

# echo "Running zap script..."
# Run the zap.sh script using the absolute path from the script directory
# "$SCRIPT_DIR/zap.sh" --non-interactive

echo "Generating sourcemap and types..."
rojo sourcemap game.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
rojo sourcemap game.project.json --output sourcemap.json

echo "Installation complete."