# Sphinx Documentation Guide

This guide explains how to build and use the Sphinx documentation for the replication package.

## Prerequisites

The Sphinx documentation requires Python 3.8 or higher and several Python packages. You can install the required packages using:

```bash
pip install -r docs/requirements.txt
```

## Building the Documentation

To build the documentation:

1. Navigate to the docs directory:
   ```bash
   cd docs
   ```

2. Build the HTML documentation:
   ```bash
   make html
   ```

3. The documentation will be generated in the `docs/_build/html` directory.

4. Open `docs/_build/html/index.html` in your web browser to view the documentation.

## Documentation Structure

The documentation is organized into the following sections:

1. **Getting Started**
   - Introduction to the paper and replication package
   - Installation instructions
   - Workflow overview

2. **Data**
   - Data sources and acquisition
   - Data structure and variables
   - Data catalog

3. **Code Documentation**
   - Detailed documentation of transformation code
   - Stata analysis code
   - R analysis code
   - Key functions and algorithms

4. **Results**
   - Description of output tables
   - Description of output figures
   - Interpretation of results

5. **Appendix**
   - Testing and validation
   - Troubleshooting
   - References

## Adding to the Documentation

To add new documentation:

1. Create Markdown (.md) or reStructuredText (.rst) files in the appropriate directory.
2. Add the new files to the table of contents (toctree) in `index.rst` or relevant section file.
3. Rebuild the documentation with `make html`.

## Documentation Tools

The documentation uses the following tools and extensions:

- **Sphinx**: The main documentation generation tool
- **MyST Parser**: For Markdown support
- **nbsphinx**: For Jupyter notebook integration
- **Read the Docs Theme**: For the documentation theme and styling

## Configuration

The documentation configuration is in `docs/conf.py`. Key settings include:

- Project information
- Extensions
- Theme configuration
- HTML output options

## Building Other Formats

Besides HTML, you can build the documentation in other formats:

- PDF: `make latexpdf`
- ePub: `make epub`
- Single HTML page: `make singlehtml`

## Troubleshooting

If you encounter issues building the documentation:

1. Make sure all required packages are installed
2. Check the console output for error messages
3. Ensure all referenced files exist
4. Verify that the reStructuredText or Markdown syntax is correct