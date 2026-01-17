#!/bin/bash
# Package OneStopShop addon for release
# Usage: ./package.sh [version]
# Example: ./package.sh 1.0.0

set -e

ADDON_NAME="OneStopShop"
VERSION="${1:-$(grep '## Version:' "$ADDON_NAME/$ADDON_NAME.toc" | sed 's/## Version: //')}"
OUTPUT_DIR="releases"
ZIP_NAME="${ADDON_NAME}-${VERSION}.zip"

echo "Packaging $ADDON_NAME v$VERSION..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Clean any previous build
rm -f "$OUTPUT_DIR/$ZIP_NAME"

# Create zip with addon folder at root
# Excludes: .git, .gitignore, dev files, etc.
zip -r "$OUTPUT_DIR/$ZIP_NAME" "$ADDON_NAME" \
    -x "*.git*" \
    -x "*.DS_Store" \
    -x "*Thumbs.db" \
    -x "*.md" \
    -x "*.sh"

echo "Created: $OUTPUT_DIR/$ZIP_NAME"
echo ""
echo "Contents:"
unzip -l "$OUTPUT_DIR/$ZIP_NAME"
