# Introduction

This documentation provides comprehensive information about the replication package for the paper "The Big Short (Interest): Closing the Loopholes in the Dividend-Withholding Tax" by Elisa Casi, Evelina Gavrilova, David Murphy, and Floris Zoutman.

## Paper Abstract

This paper studies how closing loopholes in dividend withholding taxation affects financial markets. We analyze a reform in Denmark that reduced opportunities for dividend tax arbitrage. Using a unique dataset on stock lending around ex-dividend dates, we show that before the reform, German, French, and US stocks exhibit high short interest around ex-dividend dates, while Danish stocks exhibit even higher short interest. We explain this pattern through a tax-avoidance mechanism. When Denmark strengthened enforcement to close this loophole, stock lending decreased for Danish stocks only. The reform increased dividend tax revenues by 75% without negative effects on stock returns, liquidity, or investment.

## Replication Package Overview

This replication package contains all the code necessary to reproduce the results in the paper. It is organized into the following components:

1. **Raw Data Processing**: Code for importing and processing the raw data from Compustat and Markit
2. **Data Transformation**: Code for transforming the data into the format needed for analysis
3. **Analysis**: Code for running the main analyses and producing tables and figures
4. **Output Generation**: Code for generating the final outputs presented in the paper

## Key Findings

The key findings that this replication package will reproduce include:

1. Higher stock lending activity around ex-dividend dates for Danish stocks before the reform
2. Reduction in stock lending for Danish stocks after the reform
3. Approximately 75% increase in dividend tax revenue following the reform
4. No negative effects on stock returns, liquidity, or investment

## Structure of this Documentation

This documentation is organized to guide users through the replication process:

- **Getting Started**: Installation instructions and workflow overview
- **Data**: Description of data sources, structure, and variables
- **Code Documentation**: Detailed documentation of the code files
- **Results**: Description of the outputs and their interpretation
- **Appendix**: Additional resources, troubleshooting, and references