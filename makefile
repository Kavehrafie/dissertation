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
		-M link-citations=true \
		--number-sections \
		--top-level-division=chapter \
		--citeproc \
		--pdf-engine=xelatex \
		--include-in-header=$(LATEX_TEMPLATE) \
		-o $(PDF_OUTPUT)

# Default target
pdf: $(PDF_OUTPUT)

# Clean build files
clean:
	rm -rf $(OUTPUT_DIR)

.PHONY: pdf clean

