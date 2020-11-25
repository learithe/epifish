

#== epifish.R
#
# A package of functions to generate an epidemic curve fishplot
# Essentially a wrapper for Chris Miller's fishplot package, https://github.com/chrisamiller/fishplot
# that normalises epi case datasets to generate a count ratio matrix that fits fishplot rules.
#
# Jenny Draper November 2020
#




#- f() to convert sample, cluster, and colour data frames into a fishplot ------------------
#  returns a list of the important objects generated in the process
#  to make debugging/inspecting easier

#' @export
build_fishplot_tables <- function( df, parent_df=NULL, colour_df=NULL, min_cluster_size=1, timepoint_labels=FALSE, show_labels=TRUE)
{

  #clear any prior rowwise() and groupby() operations
  df <- ungroup(df)

  #-- process clusters to display -----------------------------------
  # initialise new cluster column with original cluster values
  df$FPCluster <- select(df, cluster_id)[[1]]

  # identify all clusters big enough to label
  clustercounts <- df %>% group_by(FPCluster) %>% count()
  big_clusters <- clustercounts[clustercounts$n >= min_cluster_size,  ]$FPCluster


  # lump all small clusters together
  df <- df %>% mutate("FPCluster"= ifelse(FPCluster %in% big_clusters, FPCluster, "other small cluster"))


  #-- generate per-timepoint count table -------------------------------
  # get count of each population per timepoint
  clusters_by_timepoint <- df %>% group_by(timepoint, FPCluster) %>% summarise(n = n())
  clusters_by_timepoint <- arrange(clusters_by_timepoint, timepoint) #ensure we're in time order
  sums_by_timepoint <- df %>% group_by(timepoint) %>% summarise(n = n())

  #get count matrix (one row per cluster/timepoint pair)
  frac.table <- pivot_wider(clusters_by_timepoint, names_from= FPCluster, values_from= n) %>%
    mutate_at(vars(-group_cols()), ~replace(., is.na(.), 0))

  #collapse to one row per timepoint
  frac.table <- frac.table %>% group_by(`timepoint`) %>% summarise_all(~sum(.))
  #remove any duplicate rows prev step creates
  frac.table <- filter(frac.table, `timepoint` %in% unique(clusters_by_timepoint$`timepoint`))

  #convert to fishplot-friendly format
  frac.table <- as.data.frame(frac.table)
  rownames(frac.table) <- frac.table$`timepoint`; frac.table$`timepoint` <- NULL


  ## - NORMALISE counts to a max sum of 99/timepoint for relative fishplot display ---------------

  # get multiplier to normalise maximum timepoint count to ~99 for display
  norms <- c()
  for (i in 1:nrow(frac.table)) {
    row <- frac.table[i, ]
    normaliser <- 99 / sum(row)
    norms <- c(norms, normaliser)
  }
  normaliser <- min(norms)
  normaliser <- normaliser - 0.01  #make room for padding

  # generate normalised table
  fish_table <- round(frac.table*normaliser, 3)
  fishplot_names <- names(fish_table)

  # pad "temporary dropouts" to fit fishplot rules
  fish_table <- pad_matrix(fish_table, names(frac.table), 0.0001)


  #-- set up parent vector & padding if needed -----------------------
  if(is.null(parent_df)){
    parents <- rep(0, length(fishplot_names))

  } else {

    parents <- make_parent_list(parent_df, fishplot_names)

    #NOTE this relies on fact that children must arise after parents & that fishplot_names is a time-sorted ascending list)
    #correct the ratios for parent/child relationship
    fish_table <- pad_parents(fish_table, parents)

  }


  #-- prepare timepoints
  timepoints <- as.numeric(unique(clusters_by_timepoint$`timepoint`))
  names(timepoints) <- timepoints

  #-- use custom timepoint labels if desired
  if (timepoint_labels==TRUE) {

    if("timepoint_label" %in% names(df) ) {

      tmpdf <- select(sample_df, timepoint, timepoint_label) %>% distinct()
      tmpdf <- arrange(tmpdf, timepoint)
      names(timepoints) <- tmpdf$timepoint_label

    } else {
      warning("Column 'timepoint_label' not found in sample dataframe; skipping use of custom labels")
      names(timepoints) <- as.character(timepoints)
    }
  }

  # convert our table to a matrix
  fish_matrix <- as.matrix(fish_table); colnames(fish_matrix) <- NULL;
  fish_matrix <- t(fish_matrix) #rows are clones, cols are timepoints


  # temporarily create a new version of the fishplot annotClone() function
  # allows some control of cluster label position
  annotClone <- function(x, y, annot, angle=0, col = "black") {
    text(x, y, annot, pos = 2, cex = 0.7, col = col, xpd = NA, srt = angle, offset = 0.2)
    #default is: pos = 4, cex = 0.5, col = col, xpd = NA, srt = angle, offset = 0.5
  }
  tmpfun <- get("annotClone", envir = asNamespace("fishplot"))
  environment(annotClone) <- environment(tmpfun)
  utils::assignInNamespace("annotClone", annotClone, ns="fishplot")


  # set up fish colour scheme if it was defined (and do some common error checking)
  if (! is.null(colour_df) ){
    fish_colours <- set_fish_colours(colour_df, fishplot_names)
  } else {
    fish_colours <- NULL
  }


  # create the fishplot object!
  fish = createFishObject(fish_matrix, as.numeric(parents), timepoints, clone.labels=fishplot_names)
  fish = layoutClones(fish)
  if(! is.null(fish_colours) ){ fish = setCol(fish, unlist(fish_colours)) }
  if( show_labels==TRUE ){ fish@clone.annots = fishplot_names } #this adds labels onto the plot


  # prepare list of fish object & associated data tables to return
  ret <- list()
  ret$timepoint_counts <- clusters_by_timepoint
  ret$timepoint_sums <- sums_by_timepoint
  ret$cluster_sums <- clusters_by_timepoint %>% group_by(FPCluster) %>% summarise(n = n())

  ret$fish <- fish

  ret$timepoints <- timepoints
  ret$timepoint_labels <- names(timepoints)
  ret$raw_table <- frac.table
  ret$fish_table <- fish_table
  ret$fish_matrix <- fish_matrix
  ret$parents <- parents

  cat("The maximum sample count per timepoint (height of Y-axis) is: ", max(rowSums(frac.table)))

  return(ret)
}




#- f() to padd "temporarily disappearing" clusters with a small value
#  to fit fishplot rules where no cluster can go to zero and then come back later
#  because setting "fix.missing.clones=TRUE" doesn't actually work

#' @export
pad_matrix <- function(df, cnames, padval=0.001) {

  retdf <- as.data.frame(df)

  for (c in cnames) {

    v <- retdf[ , c]

    #first, get start and end timepoints for cases
    startpos <- 0; endpos <- 0

    for (i in 1:length(v) ){
      if ( (v[i] > 0) && (startpos ==  0) ){
        startpos <- i
      } else if ( (i > startpos) && (v[i] > 0) ) {
        endpos <- i
      }
    }
    #cat(c, " ", startpos, " ", endpos, "\n")

    #then 1-pad any zeros inbetween
    for (i in 1:length(v) ){
      if ( (v[i] == 0) && (i > startpos) && (i < endpos) ){
        v[i] <- padval
      }
    }

    retdf[ ,c] <- v  #update this cluster's column

  }
  return(retdf)
}




#' Create fishplot cluster colour vector
#'
#' Converts an input cluster-colour pairing table to a named list in the proper order
#' for the fishplot, to enable easy use of custom colour palettes.
#'
#' @details

#' Takes a dataframe describing cluster-colour pairings, and generates a named list to
#' use when generating the fishplot. Colours can be described as R named colours
#' (https://www.nceas.ucsb.edu/sites/default/files/2020-04/colorPaletteCheatsheet.pdf) or hexadecimal codes.
#' An example input table is included in the epifish package.
#'
#' @param colour_df data frame with columns "cluster" and "colour"
#' @param fishplot_names the fishplot table's column (cluster) names
#'
#' @return list of form ("clustername"= "colour")
#'
#' @export
#'
set_fish_colours <- function(colour_df, fishplot_names){

  fish_colours <- colour_df$colour
  names(fish_colours) <- colour_df$cluster

  missing = fishplot_names[ ! fishplot_names %in% names(fish_colours) ]
  if( length(missing) > 0 ){
    warning( "WARNING: existing clusters not found in colour list: ", paste(missing, collapse=", "))
  }
  extra = names(fish_colours)[ ! names(fish_colours) %in% fishplot_names ]
  if( length(extra) > 0 ){
    warning( "WARNING: some clusters in colour list not found in data: ", paste(extra, collapse=", "))
  }

  if ( length(missing) + length(extra) > 0){
    warning("WARNING: Errors found in colour list; ignoring custom colour palette")
    fish_colours <- NULL
  } else {
    fish_colours <- fish_colours[fishplot_names]
  }

  return(fish_colours)

}



#' Create fishplot parent/child position vector
#'
#' Fishplots require an input vector/list that matches each cluster in the fishplot table to its
#' parent's position in the table (or 0 if it is an independent cluster). This function
#' generates that vector for you, given a data frame naming the parent/child pairings.
#'
#' @details

#' Takes a dataframe describing parent-child relationships and a vector of fishplot cluster names
#' and generates the named child->parent position list needed for a fishplot and for the
#' `pad_parents()` function. An example parent data frame file is included with the epifish package.
#' Clusters with `NA` in the parent column will be considered independently derived.
#'
#' @param parent_df data frame with columns "parent" and "child"
#' @param fishplot_names the fishplot table's column (cluster) names
#'
#' @return list of form ("child_cluster_name"= parent_column_number)
#'
#' @export
#'
#create the list specifying matrix position needed by fishplot package
make_parent_list <- function(parent_df, fishplot_names) {

  plist <- rep(0, length(fishplot_names))
  names(plist) <- fishplot_names

  for( i in 1:nrow(parent_df)){
    if( ! is.na(parent_df[i, "parent"]) ){

      parent <- parent_df[i, 2]
      child <- parent_df[i, 1]
      #cat(parent, child, "\n")

      if (! parent %in% names(plist) | ! child %in% names(plist) ) {
        warning(paste0("Requested parent or child cluster not present in fish table names: ", parent) )
      } else {
        position <- match(parent, names(plist))
        #cat("setting parent position of child", child, " to ", position, "\n")
        plist[ child ] <- match(parent, names(plist))
      }
    }
  }

  return( plist )

}



#' Adjust counts for fishplot parent/child relationship rules
#'
#' Add child counts to parent counts for all clusters with a parent/child relationship.
#'
#' @details
#' Fishplots require parent cluster counts to include the counts of all their
#' children as well (no parent can ever have a lower count than its children). This function
#' pads counts for parents with the counts for all their children to fulfil this rule.
#' NOTE to handle nesting this function relies on the fact that children must arise after parents
#' and that `parents` is a time-sorted list. If your data contains complex nested parent/child
#' relationships, check the output messages to ensure the additions occurred in the correct order.
#'
#'
#' @param fish_table count table/matrix
#' @param parents named list of parent/child positions in the table (output of make_parent_list())
#' @export
#'
pad_parents <- function(fish_table, parents){

  pad_parent <- function(ft, parent, child)
  {
    ft[ ,parent] <- ft[ ,parent] + ft[ ,child]
    return(ft)
  }

  cat("Padding parent values in matrix: \n")
  p_rev <- rev(parents) #reverse order for processing

  for( i in 1:length(p_rev) ) {
    if ( p_rev[[i]] != 0 ){
      childid <- names(p_rev[i])
      parentpos <- p_rev[[i]]
      parentid <- names(parents[parentpos])
      cat( "adding child ", childid, " to parent ", parentid, "\n")

      fish_table <- pad_parent(fish_table, parent=parentid, child=childid)
    }

  }
  return(fish_table)
}






#' Add a cluster legend to a fishplot
#'
#' A modified version of the fishplot::drawLegend() function to allow more customisation of
#' the legend formatting, especially horizontal spacing when legend entries are long.
#' Refer to https://github.com/chrisamiller/fishplot/blob/master/R/draw.R
#'
#' @param fish fishplot object
#' @param xpos distance from left edge of fishplot
#' @param ypos distance from bottom edge of fishplot
#' @param nrow number of rows to split clusters into
#' @param cex  size of text
#' @param widthratio width of columns relative to longest legend entry
#' @param xsp horizontal spacing factor
#'
#' @export
#' @examples
#'
drawLegend2 <- function(fish, xpos=0, ypos=-5, nrow=NULL, cex=1, widthratio=1.5, xsp=0.5){
  if(is.null(fish@clone.labels)){
    fish@labels=1:dim(fish@frac.table)[1]
  }

  #do something sensible by default - can fit about 8 per row on a typically sized plot
  if(is.null(nrow)){
    nrow = ceiling(length(fish@clone.labels)/8)
  }

  ##reorder for multi-row layout
  ncol = ceiling(length(fish@clone.labels)/nrow)
  lab = as.vector(suppressWarnings(t(matrix(fish@clone.labels,nrow=ncol))))[1:length(fish@clone.labels)]
  col = as.vector(suppressWarnings(t(matrix(fish@col,nrow=ncol))))[1:length(fish@col)]

  ##define a better spacing between the columns
  maxlablen <- max(sapply(fish@clone.labels, function(x) nchar(x)))
  col_width <- maxlablen/(ncol*widthratio)

  legend(xpos,ypos,fill=col, legend=lab, bty="n", ncol=ncol, xpd=T, col="grey30", border="grey30", cex=cex*0.8,
         text.width=col_width, x.intersp=xsp)
}





