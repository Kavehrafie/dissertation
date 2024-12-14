#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print with color
print_status() {
    case $1 in
        "success") echo -e "${GREEN}$2${NC}" ;;
        "error") echo -e "${RED}$2${NC}" ;;
        "warning") echo -e "${YELLOW}$2${NC}" ;;
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
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_status "error" "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Check for required files
check_required_files() {
    local required_files=("main.md" "obsidian-embeds.lua" "style.tex" "bibliography.bib")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=($file)
        fi
    done
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        print_status "error" "Missing required files: ${missing_files[*]}"
        exit 1
    fi
}

# Clean temporary files
clean_temp_files() {
    local temp_extensions=("aux" "log" "out" "toc" "bbl" "bcf" "blg" "run.xml")
    for ext in "${temp_extensions[@]}"; do
        rm -f output/*.$ext
    done
}

# Backup function
create_backup() {
    if [ -f output/dissertation.pdf ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        mv output/dissertation.pdf "output/dissertation_backup_${timestamp}.pdf"
        print_status "success" "Created backup of previous PDF"
    fi
}

# Main compilation function
compile_dissertation() {
    print_status "success" "Starting compilation..."
    
    # First pass with pandoc
    pandoc main.md \
        --lua-filter=obsidian-embeds-exp.lua \
        --pdf-engine=xelatex \
        --include-in-header=style.tex \
        --number-sections \
        --citeproc \
        -o output/dissertation.pdf
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        print_status "success" "✓ Compilation successful! PDF created at output/dissertation.pdf"
        clean_temp_files
    else
        print_status "error" "✗ Compilation failed! Check the error messages above"
        exit 1
    fi
}

# Main execution
main() {
    # Create output directory
    mkdir -p output
    
    # Run checks
    check_dependencies
    check_required_files
    
    # Create backup
    create_backup
    
    # Compile
    compile_dissertation
}

# Execute main function
main
