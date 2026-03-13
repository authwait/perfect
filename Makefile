.PHONY: build install uninstall clean proof all version self-actualize ci

VERSION := $(shell cat VERSION)
PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
BUILD_DIR := build

all: build

build: $(BUILD_DIR)/perfect

$(BUILD_DIR)/perfect: src/perfect.sh VERSION
	@mkdir -p $(BUILD_DIR)
	@echo "Building perfect $(VERSION)..."
	@sed 's/@@VERSION@@/$(VERSION)/g' src/perfect.sh > $(BUILD_DIR)/perfect
	@chmod +x $(BUILD_DIR)/perfect
	@echo "Built: $(BUILD_DIR)/perfect"

install: $(BUILD_DIR)/perfect
	@mkdir -p $(BINDIR)
	@cp $(BUILD_DIR)/perfect $(BINDIR)/perfect
	@echo "Installed: $(BINDIR)/perfect"

uninstall:
	@rm -f $(BINDIR)/perfect
	@echo "Uninstalled: $(BINDIR)/perfect"

version:
	@echo "$(VERSION)"

self-actualize: $(BUILD_DIR)/perfect
	@echo "Self-actualizing..."
	@$(BUILD_DIR)/perfect e2e .
	@echo "Self-actualization complete."

ci: build self-actualize proof
	@echo "All stages passed."

proof:
	@echo "Verifying formal proofs..."
	@cd proofs && ~/.elan/bin/lake build
	@echo "All proofs verified."

clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf .perfect/
	@cd proofs && ~/.elan/bin/lake clean 2>/dev/null || true
	@echo "Clean."
