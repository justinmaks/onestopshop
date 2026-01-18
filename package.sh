#!/bin/bash
# Package OneStopShop addon for release
# Usage: ./package.sh [version]
# Example: ./package.sh 1.0.0
#
# Creates separate packages for each WoW flavor:
#   - OneStopShop-1.0.0.zip (universal - all TOCs included)
#   - OneStopShop-1.0.0-classic.zip (Classic Era / Vanilla)
#   - OneStopShop-1.0.0-tbc.zip (TBC Anniversary)
#   - OneStopShop-1.0.0-cata.zip (Cataclysm Classic)

set -e

ADDON_NAME="OneStopShop"
VERSION="${1:-$(grep '## Version:' "$ADDON_NAME/$ADDON_NAME.toc" | sed 's/## Version: //')}"
OUTPUT_DIR="releases"

echo "Packaging $ADDON_NAME v$VERSION..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Clean any previous builds
rm -f "$OUTPUT_DIR"/*.zip

# Common excludes
EXCLUDES="-x *.git* -x *.DS_Store -x *Thumbs.db"

# ====================
# Universal package (all TOC files)
# ====================
ZIP_UNIVERSAL="${ADDON_NAME}-${VERSION}.zip"
echo "Creating universal package: $ZIP_UNIVERSAL"
zip -r "$OUTPUT_DIR/$ZIP_UNIVERSAL" "$ADDON_NAME" $EXCLUDES
echo "  Created: $OUTPUT_DIR/$ZIP_UNIVERSAL"

# ====================
# Classic Era (Vanilla) package
# ====================
ZIP_CLASSIC="${ADDON_NAME}-${VERSION}-classic.zip"
echo "Creating Classic Era package: $ZIP_CLASSIC"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cp -r "$ADDON_NAME" "$TEMP_DIR/"

# Remove other flavor TOCs, keep Vanilla and main
rm -f "$TEMP_DIR/$ADDON_NAME/${ADDON_NAME}_TBC.toc"
rm -f "$TEMP_DIR/$ADDON_NAME/${ADDON_NAME}_Cata.toc"

# Create zip
(cd "$TEMP_DIR" && zip -r "$ZIP_CLASSIC" "$ADDON_NAME" $EXCLUDES)
mv "$TEMP_DIR/$ZIP_CLASSIC" "$OUTPUT_DIR/"
rm -rf "$TEMP_DIR"
echo "  Created: $OUTPUT_DIR/$ZIP_CLASSIC"

# ====================
# TBC Anniversary package
# ====================
ZIP_TBC="${ADDON_NAME}-${VERSION}-tbc.zip"
echo "Creating TBC Anniversary package: $ZIP_TBC"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cp -r "$ADDON_NAME" "$TEMP_DIR/"

# Remove other flavor TOCs, keep TBC and main
rm -f "$TEMP_DIR/$ADDON_NAME/${ADDON_NAME}_Vanilla.toc"
rm -f "$TEMP_DIR/$ADDON_NAME/${ADDON_NAME}_Cata.toc"

# Create zip
(cd "$TEMP_DIR" && zip -r "$ZIP_TBC" "$ADDON_NAME" $EXCLUDES)
mv "$TEMP_DIR/$ZIP_TBC" "$OUTPUT_DIR/"
rm -rf "$TEMP_DIR"
echo "  Created: $OUTPUT_DIR/$ZIP_TBC"

# ====================
# Cataclysm Classic package
# ====================
ZIP_CATA="${ADDON_NAME}-${VERSION}-cata.zip"
echo "Creating Cataclysm Classic package: $ZIP_CATA"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cp -r "$ADDON_NAME" "$TEMP_DIR/"

# Remove other flavor TOCs, keep Cata and main
rm -f "$TEMP_DIR/$ADDON_NAME/${ADDON_NAME}_Vanilla.toc"
rm -f "$TEMP_DIR/$ADDON_NAME/${ADDON_NAME}_TBC.toc"

# Create zip
(cd "$TEMP_DIR" && zip -r "$ZIP_CATA" "$ADDON_NAME" $EXCLUDES)
mv "$TEMP_DIR/$ZIP_CATA" "$OUTPUT_DIR/"
rm -rf "$TEMP_DIR"
echo "  Created: $OUTPUT_DIR/$ZIP_CATA"

# ====================
# Summary
# ====================
echo ""
echo "Packages created in $OUTPUT_DIR/:"
ls -la "$OUTPUT_DIR"/*.zip
