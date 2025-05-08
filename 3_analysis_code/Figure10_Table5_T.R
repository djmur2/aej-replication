# **********************************************************************
# ***** Replication code for 
# ***** The Big Short (Interest): 
# ***** Closing the Loopholes in the Dividend-Withholding Tax
# ***** Elisa Casi, Evelina Gavrilova, David Murphy and Floris Zoutman
# **********************************************************************

# Load configuration
source("config.R")

outtable<-NULL


base_year<-2014

#####################
### Figure 10 - The effect of the reform on Net Divident witholding tax revenue
#####################

### Set the working directory
setwd(path_input)


### Read data with applied exchange rates, NetDWT is translated into US dollars
df <- read_dta("Data_Tax.dta")

df<-df[c(1,2,5)]

# select only the necessary data to create a panel matrix, which is a prerequisite for synthDiD

colnames(df)[3]<-"tax"
df$tax<-df$tax/1000
# Transform variables, so that they conform to the example data
df$time<-as.integer(df$Year)
# Program the treatment as applying to Denmark after 2015
df$treatment<-0
df$treatment[df$Year>base_year&df$Country=="DNK"]<-1
df<-df[,c("Country","Year","tax", "treatment")]

# Set up the panel matrix, necessary to add as.data.frame because of issues with input formats
# It is apparently super important the way in which the variables are ordered
# otherwise we get an error:
# Error in panel.matrices(as.data.frame(tax)) : 
# The package cannot use this data. Treatment adoption is not simultaneous.
setup<-panel.matrices(as.data.frame(df))
# Do the synth did estimate
estimate<-synthdid_estimate(setup$Y, setup$N0, setup$T0)
# Estimate the standard error with the placebo method
se<-sqrt(vcov(estimate, method='placebo'))
# Take the spaghetti plots 
top.controls = synthdid_controls(estimate)
# Create a base synthetic plot
a<-plot(estimate, spaghetti.units=rownames(top.controls),
        treated.name="Denmark",
        control.name="Synthetic Control",
        line.width=2,
        spaghetti.line.width=1,
        spaghetti.label.size=10)
# Delete the 7th layer, containing the vline
# print(a$layers)
#library(gginnards)
b<-delete_layers(a,idx=7L)
# 1) Create a larger arrow object:
big_arrow <- arrow(
  angle = 30,                 # keep the same angle
  length = unit(1, "cm"),   # increase from 0.2 to 0.6 cm
  ends   = "last",           
  type   = "closed"           # fill the arrowhead
)

# 2) Assign it to that layer’s geom parameters and increase line size:
b$layers[[8]]$geom_params$arrow <- big_arrow
b$layers[[8]]$geom_params$size  <- 2  # thicker line
# Add to the plot through ggplot some refinements
a1<-b+scale_x_continuous(breaks=seq(2010,2020,1))+
  theme(text=element_text(size=40),
        axis.text = element_text(size = 40),
        legend.text = element_text(size = 40),
        strip.text=element_text(size = 40))+
  geom_vline(xintercept=2014.5, color="red", size=2)

# Note, if you attempt to plot it might give an error
# But it does successfully create an output

filename<-paste0("Figure10_synthDiD_NetDWT_Revenue_data_sept22.png")
setwd(path_output)
png(filename,width=1600,height=1200)
print(a1)
dev.off()

# View the summary to see what are the weights
summary(estimate)
est1=list(estimate)
est_tax<-estimate
se_tax<-se




#####################
### Table 5. Synthetic Difference-in-Difference
#####################
### Build an output table, that will make it easier to copy the results, 
### just shifting around estimates

outtable<-NULL
outtable$tax<-0
outtable$tax[1]<-est_tax
outtable$tax[2]<-se_tax

outtable<-as.data.frame(outtable)
rownames(outtable)<-c("estimate","se")
outtable[nrow(outtable)+1,]<-c(-1)

t<-as.data.frame(summary(est_tax)$controls)
t$id<-rownames(t)
names(t)[1]<-"tax"
t$id[t$id=="SWE"]<-"Sweden"
t$id[t$id=="FIN"]<-"Finland"
t$id[t$id=="NOR"]<-"Norway"

table<-t
  
outtable$id<-rownames(outtable)

outtable<-rbind(outtable,table)


outtable<-outtable[c(2,1)]

outtable[,2]<-round(outtable[,2], digits=3)

outtable[2,]<-paste0("(", outtable[2,], ")")

outtable$id[1]<-"SDiD Denmark"
outtable$id[2]<-""
outtable[3,1]<-c("Synthetic Weights:")
outtable[3,2]<-c("")

setwd(path_output)
#Here I convert the table to Latex        
stargazer(outtable,
          summary=FALSE, rownames=FALSE,  type="latex", colnames=FALSE,
          out="Table5.tex")


