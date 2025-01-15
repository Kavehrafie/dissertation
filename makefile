# Variables
PANDOC = pandoc
MAIN = main.md
OUTPUT_DIR = output
PDF_OUTPUT = $(OUTPUT_DIR)/dissertation.pdf
DOCX_OUTPUT = $(OUTPUT_DIR)/dissertation.docx
WORD_TEMPLATE= templates/template.docx
LATEX_TEMPLATE = templates/style.tex
BIB_FILE = bibliography.bib
CSL_FILE = templates/chicago-note-bibliography.csl

# images
IMAGES_DIR := figures
OPTIMIZED_DIR := optimized_images
MAX_WIDTH := 980
MAX_HEIGHT := 640

$(OPTIMIZED_DIR):
	mkdir -p $(OPTIMIZED_DIR)


# Filter paths
OBSIDIAN_FILTER = filters/obsidian-embeds.lua
FIGREF_FILTER = pandoc-figref.lua

# All source files
SOURCES = $(wildcard *.md chapters/**.md)

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Main PDF target with dependencies
$(PDF_OUTPUT): $(SOURCES) $(LATEX_TEMPLATE) $(BIB_FILE) $(CSL_FILE) | $(OUTPUT_DIR)
	$(PANDOC) $(MAIN) \
		--from markdown+raw_tex \
		--to pdf \
		--lua-filter=$(OBSIDIAN_FILTER) \
		--filter pandoc-crossref \
		-M linkReferences=true \
		--number-sections \
		-M link-citations=true \
		--top-level-division=chapter \
		--citeproc \
		--pdf-engine=xelatex \
		--include-in-header=$(LATEX_TEMPLATE) \
		-o $(PDF_OUTPUT)

$(DOCX_OUTPUT): $(SOURCES) $(LATEX_TEMPLATE) $(BIB_FILE) $(CSL_FILE) | $(OUTPUT_DIR)
	$(PANDOC) $(MAIN) \
		--lua-filter=$(OBSIDIAN_FILTER) \
		--filter pandoc-crossref \
		-M linkReferences=true \
		--number-sections \
		-M link-citations=true \
		--top-level-division=chapter \
		--citeproc \
		--reference-doc=$(WORD_TEMPLATE) \
		--pdf-engine=xelatex \
		--include-in-header=$(LATEX_TEMPLATE) \
		-o $(DOCX_OUTPUT)


$(OPTIMIZED_DIR)/%.png: $(IMAGES_DIR)/%.png | $(OPTIMIZED_DIR)
	@if [ ! -f "$@" ] || [ "$<" -nt "$@" ]; then \
		echo "Optimizing $<"; \
		magick "$<" -resize $(MAX_WIDTH)x$(MAX_HEIGHT)\> -strip -define png:compression-level=9 "$@" && \
		pngquant --quality=65-80 --strip --force --output "$@" "$@"; \
	fi

$(OPTIMIZED_DIR)/%.jpg: $(IMAGES_DIR)/%.jpg | $(OPTIMIZED_DIR)
	@if [ ! -f "$@" ] || [ "$<" -nt "$@" ]; then \
		echo "Optimizing $<"; \
		magick "$<" -resize $(MAX_WIDTH)x$(MAX_HEIGHT)\> -quality 80 -strip "$@"; \
	fi

PNG_FILES := $(wildcard $(IMAGES_DIR)/*.png)
JPG_FILES := $(wildcard $(IMAGES_DIR)/*.jpg)
OPTIMIZED_PNG := $(patsubst $(IMAGES_DIR)/%.png,$(OPTIMIZED_DIR)/%.png,$(PNG_FILES))
OPTIMIZED_JPG := $(patsubst $(IMAGES_DIR)/%.jpg,$(OPTIMIZED_DIR)/%.jpg,$(JPG_FILES))

optimize_images: $(OPTIMIZED_PNG) $(OPTIMIZED_JPG)

# View target that depends on pdf
view: $(PDF_OUTPUT)
	xdg-open $(PDF_OUTPUT)

.DEFAULT_GOAL := pdf
pdf: $(PDF_OUTPUT)

word: $(DOCX_OUTPUT)

clean:
	rm -rf $(OUTPUT_DIR)

.DEFAULT_GOAL := all
all: clean pdf view

.PHONY: pdf word clean view all optimize_images
