# Simple Makefile for Perl Plot Project

# Name of the generated output file
OUTPUT = output.png

# Default target
all: $(OUTPUT)

# How to build the PNG
$(OUTPUT): plot.pl
	@echo "Running plot script..."
	@perl plot.pl
	@echo "Done."

# Remove generated files
clean:
	@echo "Cleaning..."
	@rm -f $(OUTPUT)
	@echo "Clean complete."

.PHONY: all clean
