#!/bin/bash

# Configuration
CONFIG=(
    DEBUG=true
    OUTPUT_DIR="output"
    CHAPTERS_DIR="chapters"
    FIGURES_DIR="figures"
    TEMP_DIR=".temp"
)

# Color definitions
declare -A COLORS=(
    ["success"]='\033[0;32m'
    ["error"]='\033[0;31m'
    ["warning"]='\033[1;33m'
    ["info"]='\033[0;34m'
    ["reset"]='\033[0m'
)

# Required dependencies
DEPENDENCIES=(
    "pandoc"
    "xelatex"
    "biber"
)

# Required files
REQUIRED_FILES=(
    "main.md"
    "obsidian-embeds.lua"
    "style.tex"
    "bibliography.bib"
)

# Logging functions
log() {
    local level=$1
    local message=$2
    local color=${COLORS[$level]}
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${color}[${timestamp}] ${message}${COLORS[reset]}"
    
    if [[ ${CONFIG[DEBUG]} == true ]]; then
        echo "[${timestamp}] ${level}: ${message}" >> compile.log
    fi
}

# Check for required commands
check_dependencies() {
    log "info" "Checking dependencies..."
    local missing_deps=()
    
    for cmd in "${DEPENDENCIES[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log "error" "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    log "success" "All dependencies found"
}

# Verify required files exist
check_required_files() {
    log "info" "Checking required files..."
    local missing_files=()
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        log "error" "Missing required files: ${missing_files[*]}"
        exit 1
    fi
    
    log "success" "All required files found"
}

# Clean temporary files
clean_temp_files() {
    local temp_extensions=(
        "aux"
        "log"
        "out"
        "toc"
        "bbl"
        "bcf"
        "blg"
        "run.xml"
    )
    
    log "info" "Cleaning temporary files..."
    
    for ext in "${temp_extensions[@]}"; do
        find "${CONFIG[OUTPUT_DIR]}" -name "*.$ext" -type f -delete
    done
    
    if [ -d "${CONFIG[TEMP_DIR]}" ]; then
        rm -rf "${CONFIG[TEMP_DIR]}"
    fi
    
    log "success" "Temporary files cleaned"
}

# Create backup of existing PDF
create_backup() {
    local pdf_path="${CONFIG[OUTPUT_DIR]}/dissertation.pdf"
    
    if [ -f "$pdf_path" ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup_path="${CONFIG[OUTPUT_DIR]}/dissertation_backup_${timestamp}.pdf"
        
        mv "$pdf_path" "$backup_path"
        log "success" "Created backup at: $backup_path"
    fi
}

# Prepare directory structure
prepare_directories() {
    log "info" "Preparing directory structure..."
    
    mkdir -p "${CONFIG[OUTPUT_DIR]}" "${CONFIG[TEMP_DIR]}"
    
    # Ensure figures directory exists and is accessible
    if [ ! -d "${CONFIG[FIGURES_DIR]}" ]; then
        log "warning" "Figures directory not found, creating..."
        mkdir -p "${CONFIG[FIGURES_DIR]}"
    fi
}

# Main compilation function
compile_dissertation() {
    log "info" "Starting compilation process..."
    
    # First pass - generate PDF
    pandoc main.md \
        --lua-filter=obsidian-embeds-exp.lua \
        --pdf-engine=xelatex \
        --include-in-header=style.tex \
        --number-sections \
        --citeproc \
        -o "${CONFIG[OUTPUT_DIR]}/dissertation.pdf" \
        2>&1 | tee "${CONFIG[TEMP_DIR]}/pandoc.log"
    
    local exit_code=${PIPESTATUS[0]}
    
    if [ $exit_code -eq 0 ]; then
        log "success" "✓ Compilation successful! PDF created at ${CONFIG[OUTPUT_DIR]}/dissertation.pdf"
        clean_temp_files
    else
        log "error" "✗ Compilation failed! Check ${CONFIG[TEMP_DIR]}/pandoc.log for details"
        exit 1
    fi
}

# Main execution function
main() {
    # Start logging
    if [[ ${CONFIG[DEBUG]} == true ]]; then
        exec 1> >(tee -a compile.log)
        exec 2> >(tee -a compile.log >&2)
    fi
    
    log "info" "Starting compilation script..."
    
    # Run preliminary checks
    check_dependencies
    check_required_files
    prepare_directories
    create_backup
    
    # Main compilation
    compile_dissertation
    
    log "success" "Compilation process completed successfully"
}

# Execute main function
main "$@"