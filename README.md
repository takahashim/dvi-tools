# DVI Tools

A Ruby-based command-line tool (`dvit`) for analyzing and comparing TeX DVI (Device Independent) files. Perfect for checking how much LaTeX document build results differ between environments.

[![Ruby](https://img.shields.io/badge/ruby-3.4+-red.svg)](https://www.ruby-lang.org/)
[![RSpec](https://img.shields.io/badge/tested%20with-rspec-green.svg)](https://rspec.info/)
[![RuboCop](https://img.shields.io/badge/code%20style-rubocop-brightgreen.svg)](https://rubocop.org/)

## Features

- **DVI File Parsing**: Complete binary DVI file parsing with full opcode support
- **Layout Analysis**: Compare page layouts, dimensions, and positioning
- **Content Comparison**: Analyze text content, special commands, and rules
- **Font Analysis**: Compare font usage, definitions, and character positioning
- **Flexible Output**: JSON and human-readable formats with detailed reporting
- **Multi-format Support**: Handle complex LaTeX documents with graphics, math, and multi-column layouts

## Installation

### Prerequisites

- Ruby 3.4 or higher
- Bundler gem

### From RubyGems (Recommended)

```bash
gem install dvi-tools
```

After installation, the `dvit` command will be available globally:

```bash
dvit --help
dvit parse document.dvi
dvit diff old.dvi new.dvi
```

### From Source

```bash
# Clone the repository
git clone https://github.com/takahashim/dvi-tools.git
cd dvi-tools

# Install dependencies
bundle install

# Build and install the gem locally
gem build dvi-tools.gemspec
gem install ./dvi-tools-*.gem

# Or use Bundler's rake task
bundle exec rake install
```

### Development Setup

```bash
# Clone the repository
git clone https://github.com/takahashim/dvi-tools.git
cd dvi-tools

# Install dependencies including development dependencies
bundle install

# Run tests to verify setup
bundle exec rspec
```

## Usage

### Basic Commands

#### Parse DVI Files

```bash
# Basic parsing
dvit parse examples/simple.dvi

# Detailed output
dvit parse examples/complex.dvi --format=detailed

# JSON output for programmatic use
dvit parse examples/simple.dvi --format=json
```

#### Compare DVI Files

```bash
# Basic comparison
dvit diff examples/simple.dvi examples/complex.dvi

# Detailed comparison (shows all differences without truncation)
dvit diff --detailed examples/simple.dvi examples/math-heavy.dvi

# Layout-only comparison
dvit diff --layout-only examples/simple.dvi examples/layout-test.dvi

# Content-only comparison
dvit diff --content-only examples/sample.dvi examples/multilingual.dvi
```

#### Analyze Specific Aspects

```bash
# Font usage analysis
dvit analyze fonts examples/math-heavy.dvi

# Layout structure analysis
dvit analyze layout examples/layout-test.dvi

# Content extraction
dvit analyze content examples/complex.dvi

# Character positioning
dvit analyze positions examples/simple.dvi

# Text extraction
dvit analyze text examples/multilingual.dvi
```

## Example Output

### Basic Parsing
```
DVI File Analysis: examples/simple.dvi
=====================================

File Information:
- Format: DVI
- Comment: TeX output 2025.06.26:2153
- Total pages: 1
- File size: 316 bytes

Page Structure:
- Page 1: 39 characters, 1 fonts

Font Information:
- Font 1: cmr10 (used 39 times)

Special Commands: 1
Rules: 0
```

### Detailed Comparison
```
DVI Files Comparison Report
========================================

Layout Comparison:
------------------
Page count: 1 (unchanged)
Position differences: 2847
  + Added at index 0: char T at (1559345, -1255158)
  + Added at index 1: char h at (1891074, -1255158)
  ...
Dimensions: unchanged

Content Comparison:
-------------------
Character count changed: 39 → 2109 (+2070)
Special commands: 1 → 2 (+1)
Rules: 0 → 50 (+50)
Pages with text differences: 1

Font Comparison:
----------------
Font usage changed: 1 → 15 fonts
Common fonts: 1
Added fonts:
  + Font 2: used 156 times
  + Font 3: used 89 times
  ...

Summary:
--------
Layout differences: 2847
Content differences: 2070
Font differences: 14
Total differences detected: 4931
Files have differences.
```

## Test Data

The `examples/` directory contains comprehensive test files:

| Document | Size | Pages | Characters | Fonts | Features |
|----------|------|-------|------------|-------|----------|
| simple.dvi | 316B | 1 | 39 | 1 | Basic text |
| sample.dvi | 1.7KB | 1 | 273 | 11 | Sections, lists, math |
| complex.dvi | 11KB | 1 | 75 | 4 | TikZ graphics, tables |
| math-heavy.dvi | 11KB | 5 | 2,109 | 15 | Advanced mathematics |
| multilingual.dvi | 1.7KB | 1 | - | - | International characters |
| layout-test.dvi | 17KB | 5 | 7,938 | 20 | Multi-column layouts |

### Generating Test Files

```bash
cd examples/
latex simple.tex
latex complex.tex
latex complex.tex  # Second run for cross-references
latex math-heavy.tex
latex multilingual.tex
latex layout-test.tex
```

## Development

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with coverage
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/dvi_tools/parser_spec.rb
```

### Code Style

```bash
# Check code style
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

### Project Structure

```
dvi-tools/
├── lib/
│   └── dvi_tools/
│       ├── analyzer.rb       # DVI content analysis
│       ├── cli.rb           # Thor-based command interface
│       ├── diff_engine.rb   # File comparison logic
│       ├── parser.rb        # Core DVI parser
│       └── reporter.rb      # Output formatting
├── exe/
│   └── dvit                # Executable script
├── spec/                   # RSpec tests
├── examples/               # Test DVI files and LaTeX sources
└── docs/                   # Documentation
```

## Technical Details

### DVI Format Support

- **Complete opcode coverage**: All DVI commands including fonts, positioning, rules, and specials
- **Binary parsing**: Efficient handling of DVI binary format
- **Font definitions**: Full support for font loading and character metrics
- **Page structure**: Accurate page boundary and content extraction

### Comparison Algorithms

- **Layout comparison**: Position differences, dimension changes, page count variations
- **Content comparison**: Character count, special commands, rules, text differences
- **Font comparison**: Usage statistics, added/removed fonts, changed usage patterns

### Output Formats

- **Human-readable**: Structured reports with summaries and detailed breakdowns
- **JSON**: Machine-readable format for integration with other tools
- **Detailed mode**: Complete output without truncation for thorough analysis

## Use Cases

- **Build environment validation**: Ensure consistent LaTeX output across different systems
- **Document change tracking**: Identify what changed between document versions
- **Typography analysis**: Analyze font usage and layout characteristics
- **Quality assurance**: Validate document generation pipelines
- **Research**: Study LaTeX/TeX document structure and formatting

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`bundle exec rspec`)
6. Check code style (`bundle exec rubocop`)
7. Commit your changes (`git commit -am 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for analyzing TeX DVI format as specified in the DVI standard
- Inspired by the need for reliable LaTeX build comparison tools
- Thanks to the Ruby community for excellent testing and development tools
