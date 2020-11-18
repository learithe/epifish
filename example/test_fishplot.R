

library("dplyr"); library("tidyr")
library("fishplot")

#source("R/epifish.R")


#parent_df <- read.csv("~/Desktop/epifish/data/parents.csv", stringsAsFactors=FALSE)
#sample_df <- read.csv("~/Desktop/epifish/data/cluster_counts.csv", stringsAsFactors=FALSE)
#colour_df <- read.csv("~/Desktop/epifish/data/colours.csv", stringsAsFactors=FALSE)

fish_list <- epifish::build_fishplot_tables(sample_df, parent_df=parent_df, colour_df=colour_df, show_labels=TRUE)

fishplot::fishPlot(fish_list$fish, pad.left=0.1, shape="spline", vlines=fish_list$weeks, vlab=fish_list$weeks)
epifish::drawLegend2(fish_list$fish, nrow=1)

fishplot::fishPlot(fish_list$fish, pad.left=0.1, shape="bezier", vlines=fish_list$weeks, vlab=fish_list$weeks)
fishplot::drawLegend(fish_list$fish, nrow=1)









