# Variables
PANDOC = pandoc
MAIN = main.md
OUTPUT_DIR = output
PDF_OUTPUT = $(OUTPUT_DIR)/dissertation.pdf
LATEX_TEMPLATE = templates/style.tex
BIB_FILE = bibliography.bib
CSL_FILE = templates/chicago-note-bibliography.csl

# Filter paths
OBSIDIAN_FILTER = obsidian-embeds.lua
FIGREF_FILTER = pandoc-figref.lua

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Main PDF target
$(PDF_OUTPUT): $(MAIN) $(OUTPUT_DIR) $(BIB_FILE) $(CSL_FILE)
	$(PANDOC) $(MAIN) \
		--lua-filter=$(OBSIDIAN_FILTER) \
		--lua-filter=$(FIGREF_FILTER) \
		--filter=pandoc-crossref  \
		-M link-citations=true \
		--number-sections \
		--top-level-division=chapter \
		--citeproc \
		--pdf-engine=xelatex \
		--include-in-header=$(LATEX_TEMPLATE) \
		-o $(PDF_OUTPUT)

# Default target
.DEFAULT_GOAL := pdf
pdf: $(PDF_OUTPUT)

# Clean build files
clean:
	rm -rf $(OUTPUT_DIR)

# Watch for changes and rebuild (requires inotifywait on Fedora)
watch:
	while true; do \
		make pdf; \
		inotifywait -e modify -r . -e create; \
	done

# Add phony targets
.PHONY: pdf clean watch
