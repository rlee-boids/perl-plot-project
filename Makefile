# Perl Makefile for Plot::Generator project
# Supports local development + Podman adapter builds

# Perl interpreter (Podman adapter can override this)
PERL        := perl
PROVE       := prove
CARTON      := carton

# Directories
LIB_DIR     := lib
BIN_DIR     := bin
TEST_DIR    := t
DATA_DIR    := data

# Default target
.PHONY: all
all: build test

# --------------------------------------------------------
# Install dependencies using Carton (Perl's dep manager)
# --------------------------------------------------------
.PHONY: install
install:
	@if [ -f cpanfile ]; then \
		echo "Installing dependencies via Carton..."; \
		$(CARTON) install; \
	else \
		echo "No cpanfile found. Skipping dependency install."; \
	fi

# --------------------------------------------------------
# Build (noop for Perl, but kept for consistency)
# --------------------------------------------------------
.PHONY: build
build: install
	@echo "Build step complete (Perl project)."

# --------------------------------------------------------
# Run unit tests (t/*.t)
# --------------------------------------------------------
.PHONY: test
test:
	@if [ -d $(TEST_DIR) ]; then \
		echo "Running Perl unit tests..."; \
		$(PROVE) -I$(LIB_DIR) $(TEST_DIR); \
	else \
		echo "No test directory found. Skipping.

