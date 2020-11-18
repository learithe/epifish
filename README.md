
<!-- README.md is generated from README.Rmd. Please edit that file -->

# epifish

<!-- badges: start -->

<!-- badges: end -->

This package provides tools to use Chris Miller’s fishplot package
(<https://github.com/chrisamiller/fishplot>) with epidemiological
datasets, to generate fishplot epi-curves.

## Installation

You can install epifish with:

``` r
#install devtools if you don't have it already for easy installation
install.packages("devtools")
library(devtools)
devtools::install_github("learithe/epifish")
```

## Quick demo

Load epifish and required packages

``` r
library(fishplot); library(dplyr); library(tidyr); library(epifish)
```

Read in the tables of sample data, cluster relationships, and a custom
colour scheme

``` r
sample_df <- read.csv("epifish/inst/extdata/cluster_counts.csv", stringsAsFactors=FALSE)
parent_df <- read.csv("epifish/inst/extdata/parents.csv", stringsAsFactors=FALSE)
colour_df <- read.csv("epifish/inst/extdata/colours.csv", stringsAsFactors=FALSE)
```

Convert these into a fishplot-ready relative count matrix, fishplot
object, and assorted summary data structures:

``` r
fish_list <- epifish::build_fishplot_tables(sample_df, parent_df, colour_df)
#> Padding parent values in matrix: 
#> adding child  D.4  to parent  D.2 
#> adding child  D.3  to parent  D.2 
#> adding child  D.2  to parent  D.1 
#> adding child  D.1  to parent  D 
#> adding child  A.1  to parent  A
```

Then use the fishplot package to generate the fishplot image:

``` r
fishplot::fishPlot(fish_list$fish, pad.left=0.1, shape="spline", vlines=fish_list$weeks, vlab=fish_list$weeks)
fishplot::drawLegend(fish_list$fish, nrow=1)
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

Take a look at the underlying matrix and data summaries:

``` r
fish_list$week_counts
#> # A tibble: 34 x 3
#> # Groups:   week [14]
#>     week FPCluster     n
#>    <int> <chr>     <int>
#>  1     1 A             3
#>  2     1 B             1
#>  3     2 A             2
#>  4     2 B             2
#>  5     3 A             9
#>  6     3 A.1           1
#>  7     3 B             4
#>  8     3 C             1
#>  9     4 A             2
#> 10     4 A.1           3
#> # ... with 24 more rows

fish_list$week_sums
#> # A tibble: 14 x 2
#>     week     n
#>    <int> <int>
#>  1     1     4
#>  2     2     4
#>  3     3    15
#>  4     4    10
#>  5     5     5
#>  6     6     4
#>  7     7     3
#>  8     8     1
#>  9    10     2
#> 10    11     5
#> 11    12     4
#> 12    13     8
#> 13    14    14
#> 14    15     4

fish_list$cluster_sums
#> # A tibble: 9 x 2
#>   FPCluster     n
#>   <chr>     <int>
#> 1 A             6
#> 2 A.1           6
#> 3 B             4
#> 4 C             4
#> 5 D             5
#> 6 D.1           3
#> 7 D.2           3
#> 8 D.3           2
#> 9 D.4           1

fish_list$parents
#>   A   B A.1   C   D D.1 D.2 D.3 D.4 
#>   0   0   1   0   0   5   6   7   7

fish_list$raw_table
#>    A B A.1 C D D.1 D.2 D.3 D.4
#> 1  3 1   0 0 0   0   0   0   0
#> 2  2 2   0 0 0   0   0   0   0
#> 3  9 4   1 1 0   0   0   0   0
#> 4  2 1   3 4 0   0   0   0   0
#> 5  0 0   2 3 0   0   0   0   0
#> 6  1 0   0 3 0   0   0   0   0
#> 7  3 0   0 0 0   0   0   0   0
#> 8  0 0   1 0 0   0   0   0   0
#> 10 0 0   1 0 1   0   0   0   0
#> 11 0 0   1 0 4   0   0   0   0
#> 12 0 0   0 0 3   1   0   0   0
#> 13 0 0   0 0 5   2   1   0   0
#> 14 0 0   0 0 0   6   3   3   2
#> 15 0 0   0 0 1   0   1   2   0

fish_list$fish_table
#>          A     B     A.1     C       D   D.1   D.2   D.3   D.4
#> 1  19.7700  6.59  0.0000  0.00  0.0000  0.00  0.00  0.00  0.00
#> 2  13.1800 13.18  0.0000  0.00  0.0000  0.00  0.00  0.00  0.00
#> 3  65.9000 26.36  6.5900  6.59  0.0000  0.00  0.00  0.00  0.00
#> 4  32.9500  6.59 19.7700 26.36  0.0000  0.00  0.00  0.00  0.00
#> 5  13.1801  0.00 13.1800 19.77  0.0000  0.00  0.00  0.00  0.00
#> 6   6.5901  0.00  0.0001 19.77  0.0000  0.00  0.00  0.00  0.00
#> 7  19.7701  0.00  0.0001  0.00  0.0000  0.00  0.00  0.00  0.00
#> 8   6.5900  0.00  6.5900  0.00  0.0000  0.00  0.00  0.00  0.00
#> 10  6.5900  0.00  6.5900  0.00  6.5900  0.00  0.00  0.00  0.00
#> 11  6.5900  0.00  6.5900  0.00 26.3600  0.00  0.00  0.00  0.00
#> 12  0.0000  0.00  0.0000  0.00 26.3600  6.59  0.00  0.00  0.00
#> 13  0.0000  0.00  0.0000  0.00 52.7200 19.77  6.59  0.00  0.00
#> 14  0.0000  0.00  0.0000  0.00 92.2601 92.26 52.72 19.77 13.18
#> 15  0.0000  0.00  0.0000  0.00 26.3600 19.77 19.77 13.18  0.00

fish_list$fish_matrix
#>           1     2     3     4       5       6       7    8   10    11    12
#>  [1,] 19.77 13.18 65.90 32.95 13.1801  6.5901 19.7701 6.59 6.59  6.59  0.00
#>  [2,]  6.59 13.18 26.36  6.59  0.0000  0.0000  0.0000 0.00 0.00  0.00  0.00
#>  [3,]  0.00  0.00  6.59 19.77 13.1800  0.0001  0.0001 6.59 6.59  6.59  0.00
#>  [4,]  0.00  0.00  6.59 26.36 19.7700 19.7700  0.0000 0.00 0.00  0.00  0.00
#>  [5,]  0.00  0.00  0.00  0.00  0.0000  0.0000  0.0000 0.00 6.59 26.36 26.36
#>  [6,]  0.00  0.00  0.00  0.00  0.0000  0.0000  0.0000 0.00 0.00  0.00  6.59
#>  [7,]  0.00  0.00  0.00  0.00  0.0000  0.0000  0.0000 0.00 0.00  0.00  0.00
#>  [8,]  0.00  0.00  0.00  0.00  0.0000  0.0000  0.0000 0.00 0.00  0.00  0.00
#>  [9,]  0.00  0.00  0.00  0.00  0.0000  0.0000  0.0000 0.00 0.00  0.00  0.00
#>          13      14    15
#>  [1,]  0.00  0.0000  0.00
#>  [2,]  0.00  0.0000  0.00
#>  [3,]  0.00  0.0000  0.00
#>  [4,]  0.00  0.0000  0.00
#>  [5,] 52.72 92.2601 26.36
#>  [6,] 19.77 92.2600 19.77
#>  [7,]  6.59 52.7200 19.77
#>  [8,]  0.00 19.7700 13.18
#>  [9,]  0.00 13.1800  0.00
```

## Input

Example input files/templates can be found in the “inst/extdata” folder
in this repository. The basic requirement is a data frame containing one
row per sample, with columns `cluster_id` and `week` (any other columns
are ignored).

Files can also be provided that describe parent-child relationships for
clusters (eg cluster A.1 evolved from cluster A), or a custom colour
scheme, but these are optional.

Look at these table structures

``` r
head(sample_df)
#>   case_id cluster_id date_of_collection week
#> 1       1          A                 NA    1
#> 2       2          A                 NA    1
#> 3       3          A                 NA    1
#> 4       4          B                 NA    1
#> 5       5          B                 NA    2
#> 6       6          A                 NA    2

parent_df
#>   cluster parent
#> 1       A   <NA>
#> 2     A.1      A
#> 3       B   <NA>
#> 4       C   <NA>
#> 5       D   <NA>
#> 6     D.3    D.2
#> 7     D.2    D.1
#> 8     D.1      D
#> 9     D.4    D.2


colour_df
#>   cluster      colour
#> 1       A      orange
#> 2     A.1         red
#> 3       B      yellow
#> 4       C      green3
#> 5       D greenyellow
#> 6     D.1 springgreen
#> 7     D.2 deepskyblue
#> 8     D.3  royalblue1
#> 9     D.4       blue3
```

## Output

Output is an R plot. If using RStudio, it is most straightforward to
save these as PDF images from the RStudio plot window (Export -\> “Save
as PDF”).

## Notes:

Fishplot citation: Visualizing tumor evolution with the fishplot package
for R. Miller CA, McMichael J, Dang HX, Maher CA, Ding L, Ley TJ, Mardis
ER, Wilson RK. BMC Genomics. <doi:10.1186/s12864-016-3195-z>
