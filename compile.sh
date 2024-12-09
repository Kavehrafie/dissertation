#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print with color
print_status() {
    if [ $1 = "success" ]; then
        echo -e "${GREEN}$2${NC}"
    else
        echo -e "${RED}$2${NC}"
    fi
}

# Check if main.md exists
if [ ! -f main.md ]; then
    print_status "error" "Error: main.md not found!"
    exit 1
fi

# Check if obsidian-embeds.lua exists
if [ ! -f obsidian-embeds.lua ]; then
    print_status "error" "Error: obsidian-embeds.lua not found!"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p output

# Get current timestamp for backup
timestamp=$(date +"%Y%m%d_%H%M%S")

# Backup previous PDF if it exists
if [ -f output/dissertation.pdf ]; then
    mv output/dissertation.pdf "output/dissertation_backup_${timestamp}.pdf"
    print_status "success" "Created backup of previous PDF"
fi

print_status "success" "Starting compilation..."

# Run pandoc with all necessary options
pandoc main.md \
    --lua-filter=obsidian-embeds.lua \
    --pdf-engine=xelatex \
    --top-level-division=chapter \
    -o output/dissertation.pdf

# Check if compilation was successful
if [ $? -eq 0 ]; then
    print_status "success" "✓ Compilation successful! PDF created at output/dissertation.pdf"
else
    print_status "error" "✗ Compilation failed! Check the error messages above"
    exit 1
fi


