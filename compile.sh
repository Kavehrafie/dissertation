#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print with color
print_status() {
    case $1 in
        "success") echo -e "${GREEN}$2${NC}" ;;
        "error") echo -e "${RED}$2${NC}" ;;
        "info") echo -e "${BLUE}$2${NC}" ;;
    esac
}

# Check for required commands
check_dependencies() {
    local missing_deps=()
    for cmd in pandoc xelatex biber; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=($cmd)
        fi
    done
    
    # Check for ImageMagick
    if command -v magick &> /dev/null; then
        IMAGEMAGICK_CMD="magick"
    elif command -v convert &> /dev/null; then
        IMAGEMAGICK_CMD="convert"
    else
        missing_deps+=("ImageMagick")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_status "error" "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Clean filename
clean_filename() {
    local filename="$1"
    # Replace spaces and special characters with underscore
    echo "$filename" | sed -e 's/[^A-Za-z0-9._-]/_/g'
}

# Optimize images
optimize_images() {
    mkdir -p optimized_images
    
    # Find all images, excluding .trash directory
    find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
        -not -path "./optimized_images/*" \
        -not -path "./.trash/*" \
        -not -path "*/\.*" \
        -print0 | while IFS= read -r -d '' img; do
        
        # Clean the filename
        filename=$(clean_filename "$(basename "$img")")
        dirname=$(dirname "$img")
        # target_dir="optimized_images/${dirname#./}"
        target_dir="optimized_images"
        target_file="$target_dir/$filename"
        
        if [ ! -f "$target_file" ]; then
            mkdir -p "$target_dir"
            print_status "info" "Optimizing: $img -> $target_file"
            $IMAGEMAGICK_CMD "$img" -resize "2000x2000>" -quality 85 -strip "$target_file"
            
            # Create symbolic link with original name if it was changed
            if [ "$(basename "$img")" != "$filename" ]; then
                ln -sf "$filename" "$target_dir/$(basename "$img")"
            fi
        fi
    done
}


# Compile dissertation
compile_dissertation() {
    print_status "info" "Compiling dissertation..."
    
    pandoc main.md \
        --lua-filter=obsidian-embeds.lua \
        --pdf-engine=xelatex \
        --include-in-header=style.tex \
        --number-sections \
        --citeproc \
        -o output/dissertation.pdf
    
    if [ $? -eq 0 ]; then
        print_status "success" "Compilation successful! PDF created at output/dissertation.pdf"
        # Clean temporary files
        rm -f output/*.{aux,log,out,toc,bbl,bcf,blg,run.xml}
        # Remove markdown backups
        find . -name "*.md.bak" -delete
    else
        print_status "error" "Compilation failed!"
        # Restore markdown backups
        find . -name "*.md.bak" -exec bash -c 'mv "$1" "${1%.bak}"' _ {} \;
        exit 1
    fi
}

# Restore markdown files from backup if script is interrupted
cleanup() {
    print_status "info" "Cleaning up..."
    find . -name "*.md.bak" -exec bash -c 'mv "$1" "${1%.bak}"' _ {} \;
}

trap cleanup EXIT

# Main execution
main() {
    mkdir -p output
    check_dependencies
    optimize_images
    
    compile_dissertation
}

main