# R Analysis Code

This section documents the R code used for data analysis in the replication package.

## Overview

The R code is primarily used for the synthetic difference-in-differences analysis of the effect of the reform on dividend withholding tax revenues. This analysis produces Figure 10 and Table 5 in the paper.

## Main Script

### File: `Figure10_Table5_T.R`

This script performs a synthetic difference-in-differences analysis on tax revenue data to estimate the effect of the Danish reform.

### Purpose

The script estimates the causal effect of the Danish reform on dividend withholding tax revenue using a synthetic control approach.

### Usage

```bash
cd 3_analysis_code
Rscript Figure10_Table5_T.R
```

### Dependencies

The script uses the following R packages:
- `synthdid`: For synthetic difference-in-differences estimation
- `ggplot2`: For plotting
- `haven`: For reading Stata files
- `gginnards`: For modifying ggplot objects
- `stargazer`: For generating LaTeX tables

## Script Structure

### 1. Configuration and Setup

```r
# Load configuration
source("config.R")

# Set seed for reproducibility
set.seed(48476352)

# Define base year (pre-treatment)
base_year <- 2014
```

### 2. Data Loading and Preparation

```r
### Set the working directory
setwd(path_input)

### Read data with applied exchange rates, NetDWT is translated into US dollars
df <- read_dta("Data_Tax.dta")

df <- df[c(1,2,5)]

# select only the necessary data to create a panel matrix, which is a prerequisite for synthDiD
colnames(df)[3] <- "tax"
df$tax <- df$tax/1000

# Transform variables, so that they conform to the example data
df$time <- as.integer(df$Year)

# Program the treatment as applying to Denmark after 2015
df$treatment <- 0
df$treatment[df$Year>base_year&df$Country=="DNK"] <- 1
df <- df[,c("Country","Year","tax", "treatment")]
```

### 3. Synthetic Difference-in-Differences Estimation

```r
# Set up the panel matrix
setup <- panel.matrices(as.data.frame(df))

# Do the synth did estimate
estimate <- synthdid_estimate(setup$Y, setup$N0, setup$T0)

# Estimate the standard error with the placebo method
se <- sqrt(vcov(estimate, method='placebo'))

# Get top controls for spaghetti plots
top.controls = synthdid_controls(estimate)
```

### 4. Figure Creation

```r
# Create a base synthetic plot
a <- plot(estimate, spaghetti.units=rownames(top.controls),
        treated.name="Denmark",
        control.name="Synthetic Control",
        line.width=2,
        spaghetti.line.width=1,
        spaghetti.label.size=10)

# Delete the 7th layer, containing the vline
b <- delete_layers(a, idx=7L)

# Create a larger arrow object
big_arrow <- arrow(
  angle = 30,                 # keep the same angle
  length = unit(1, "cm"),   # increase from 0.2 to 0.6 cm
  ends   = "last",           
  type   = "closed"           # fill the arrowhead
)

# Assign it to that layer's geom parameters and increase line size
b$layers[[8]]$geom_params$arrow <- big_arrow
b$layers[[8]]$geom_params$size  <- 2  # thicker line

# Add to the plot through ggplot some refinements
a1 <- b+scale_x_continuous(breaks=seq(2010,2020,1))+
  theme(text=element_text(size=40),
        axis.text = element_text(size = 40),
        legend.text = element_text(size = 40),
        strip.text=element_text(size = 40))+
  geom_vline(xintercept=2014.5, color="red", size=2)

# Save the figure
filename <- paste0("Figure10_synthDiD_NetDWT_Revenue_data_sept22.png")
setwd(path_output)
png(filename, width=1600, height=1200)
print(a1)
dev.off()
```

### 5. Table Creation

```r
# Build an output table
outtable <- NULL
outtable$tax <- 0
outtable$tax[1] <- est_tax
outtable$tax[2] <- se_tax

outtable <- as.data.frame(outtable)
rownames(outtable) <- c("estimate","se")
outtable[nrow(outtable)+1,] <- c(-1)

# Get synthetic control weights
t <- as.data.frame(summary(est_tax)$controls)
t$id <- rownames(t)
names(t)[1] <- "tax"
t$id[t$id=="SWE"] <- "Sweden"
t$id[t$id=="FIN"] <- "Finland"
t$id[t$id=="NOR"] <- "Norway"

table <- t
  
outtable$id <- rownames(outtable)
outtable <- rbind(outtable, table)
outtable <- outtable[c(2,1)]
outtable[,2] <- round(outtable[,2], digits=3)
outtable[2,] <- paste0("(", outtable[2,], ")")
outtable$id[1] <- "SDiD Denmark"
outtable$id[2] <- ""
outtable[3,1] <- c("Synthetic Weights:")
outtable[3,2] <- c("")

# Generate LaTeX table
setwd(path_output)
stargazer(outtable,
          summary=FALSE, rownames=FALSE, type="latex", colnames=FALSE,
          out="Table5.tex")
```

## Technical Details

### Synthetic Difference-in-Differences Method

The synthetic difference-in-differences (SDiD) method combines elements of synthetic control and difference-in-differences approaches. It:

1. Constructs a synthetic control for the treated unit (Denmark)
2. Estimates the treatment effect as the difference between:
   - The post-treatment difference between Denmark and its synthetic control
   - The pre-treatment difference between Denmark and its synthetic control

### Implementation Notes

- The `synthdid` package in R implements the method from Arkhangelsky et al. (2021)
- Treatment is defined as the Danish reform occurring after 2014
- Standard errors are estimated using the placebo method
- The synthetic control is a weighted average of other Nordic countries (Finland, Norway, Sweden)

### Output Interpretation

- The estimate in Table 5 represents the causal effect of the reform on net dividend withholding tax revenue
- The standard error represents the uncertainty in this estimate
- The synthetic weights indicate the contribution of each control country to the synthetic Denmark

## Input and Output Files

### Input Files

- `2_final_data/Data_Tax.dta`: Processed tax revenue data

### Output Files

- `4_output/Figure10_synthDiD_NetDWT_Revenue_data_sept22.png`: Figure 10 in the paper
- `4_output/Table5.tex`: Table 5 in the paper