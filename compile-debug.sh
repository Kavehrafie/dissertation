# compile-debug.sh
#!/bin/bash

echo "=== Starting diagnostic compilation ==="

# First pass
echo "First LaTeX pass..."
pandoc main.md \
    --lua-filter=obsidian-embeds.lua \
    --pdf-engine=xelatex \
    --top-level-division=chapter \
    --number-sections \
    --verbose \
    --citeproc \
    -o output/dissertation.pdf 2> latex_errors.log

# Check for undefined references in the log
echo "Checking for undefined references..."
grep "undefined" latex_errors.log

echo "=== Diagnostic information ==="
echo "1. Checking main.md for chapter labels..."
grep "\\label{chap:" main.md || echo "No chapter labels found in main.md"

echo "2. Checking chapter files for references..."
find . -name "chapter*.md" -exec grep -l "\\ref{chap:" {} \;

echo "3. Full LaTeX error log has been saved to latex_errors.log"