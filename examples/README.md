# Example DVI Files

This directory contains comprehensive LaTeX test files and their generated DVI files for testing and demonstrating the dvi-tools parser capabilities.

## Test Document Categories

### Basic Documents
- **`simple.tex`** → `simple.dvi` (316 bytes)
  - Minimal LaTeX document with basic text
  - Single page, minimal fonts and structure
  - Perfect for basic parser testing

- **`sample.tex`** → `sample.dvi` (1,736 bytes)
  - Intermediate complexity with sections, lists, and formatting
  - Multiple fonts, mathematical expressions
  - Good for feature testing

### Complex Test Documents

- **`complex.tex`** → `complex.dvi` (11,028 bytes)
  - Comprehensive document structure with tables of contents
  - Multiple sections, mathematical equations, tables
  - TikZ graphics, code listings, bibliography
  - Tests: 75 characters, 4 fonts, 37 special commands
  - **Features**: Complex layout, graphics, cross-references

- **`math-heavy.tex`** → `math-heavy.dvi` (11,028 bytes, 5 pages)
  - Advanced mathematical notation and theorems
  - Complex fractions, matrices, integrals, proofs
  - AMS mathematics packages extensively used
  - Tests: 2,109 characters, 15 fonts, 50 rules
  - **Features**: Heavy mathematical typesetting, multiple font families

- **`multilingual.tex`** → `multilingual.dvi` (1,680 bytes)
  - International characters and accents
  - Multiple languages (French, German, Spanish, Italian)
  - Special symbols, currency marks, quotation styles
  - Tests: Complex character encoding, accent combinations
  - **Features**: Unicode support, international typography

- **`layout-test.tex`** → `layout-test.dvi` (17,380 bytes, 5 pages)
  - Advanced layout testing with two-column format
  - Multi-column environments, floating elements
  - Complex positioning, wrapped text, overlays
  - Tests: 7,938 characters, 20 fonts, 53 rules
  - **Features**: Complex page layout, column management

## Generating DVI Files

### Prerequisites
- LaTeX distribution (TeX Live, MiKTeX, etc.)
- Required packages: amsmath, amsfonts, tikz, multicol, etc.

### Generation Commands

```bash
cd examples/

# Basic documents
latex simple.tex
latex sample.tex

# Complex documents (may require multiple runs)
latex complex.tex
latex complex.tex  # Second run for cross-references

latex math-heavy.tex
latex multilingual.tex  
latex layout-test.tex
```

### Handling Compilation Errors

Some documents may produce warnings or require missing packages:

```bash
# If packages are missing, install them:
# - On TeX Live: tlmgr install <package>
# - On MiKTeX: use MiKTeX Package Manager

# For documents with errors, the DVI is still generated 
# and can be used for parser testing
```

## Testing with dvi-tools

### Basic Usage Examples

```bash
# From the project root directory:
ruby -I lib -r bundler/setup exe/dvit <command> examples/<file>.dvi
```

### Parsing Tests

```bash
# Simple document analysis
ruby -I lib exe/dvit parse examples/simple.dvi

# Complex document with detailed output
ruby -I lib exe/dvit parse examples/complex.dvi --format=detailed

# Mathematical document analysis
ruby -I lib exe/dvit parse examples/math-heavy.dvi

# JSON output for programmatic use
ruby -I lib exe/dvit parse examples/simple.dvi --format=json
```

### Comparison Tests

```bash
# Basic vs complex document comparison
ruby -I lib exe/dvit diff examples/simple.dvi examples/complex.dvi

# Detailed comparison report
ruby -I lib exe/dvit diff --detailed examples/simple.dvi examples/math-heavy.dvi

# Layout-focused comparison
ruby -I lib exe/dvit diff --layout-only examples/simple.dvi examples/layout-test.dvi

# Content-only comparison
ruby -I lib exe/dvit diff --content-only examples/sample.dvi examples/multilingual.dvi
```

### Detailed Analysis

```bash
# Font usage analysis
ruby -I lib exe/dvit analyze fonts examples/math-heavy.dvi

# Layout structure analysis  
ruby -I lib exe/dvit analyze layout examples/layout-test.dvi

# Content extraction
ruby -I lib exe/dvit analyze content examples/complex.dvi

# Character position analysis
ruby -I lib exe/dvit analyze positions examples/simple.dvi

# Text extraction
ruby -I lib exe/dvit analyze text examples/multilingual.dvi
```

## Parser Testing Scenarios

### Stress Testing
- **`math-heavy.dvi`**: Tests mathematical symbol parsing and complex font handling
- **`layout-test.dvi`**: Tests multi-column layouts and complex positioning
- **`complex.dvi`**: Tests graphics commands and special environments

### Feature Coverage
- **Font Handling**: Various font sizes, families, and mathematical symbols
- **Positioning**: Complex character placement and line breaking
- **Special Commands**: TikZ graphics, color changes, hyperlinks
- **Page Layout**: Single/multi-column, headers/footers, page breaks

### Comparison Testing
Use different document pairs to test various comparison scenarios:
- Simple → Complex: Major structural differences
- Math → Layout: Different complexity types  
- Multilingual → Simple: Character encoding differences

## File Sizes and Complexity

| Document | Size | Pages | Characters | Fonts | Special Commands | Rules |
|----------|------|-------|------------|-------|------------------|-------|
| simple | 316B | 1 | 39 | 1 | 1 | 0 |
| sample | 1.7KB | 1 | 273 | 11 | 1 | 16 |
| complex | 11KB | 1 | 75 | 4 | 37 | 0 |
| math-heavy | 11KB | 5 | 2,109 | 15 | 2 | 50 |
| multilingual | 1.7KB | 1 | - | - | - | - |
| layout-test | 17KB | 5 | 7,938 | 20 | 3 | 53 |

## Troubleshooting

### Common Issues

1. **Missing LaTeX packages**: Install required packages for your TeX distribution
2. **Compilation errors**: Check `.log` files for specific error messages
3. **Character encoding**: Ensure proper UTF-8 support for multilingual documents
4. **Memory issues**: Large documents may require increased TeX memory settings

### Useful Commands

```bash
# Check LaTeX installation
latex --version

# View compilation log
cat examples/document.log

# Check generated DVI file info
file examples/document.dvi

# Hexdump for low-level analysis
hexdump -C examples/simple.dvi | head -20
```

This comprehensive test suite provides extensive coverage for validating DVI parsing capabilities across different document types, complexities, and LaTeX features.
