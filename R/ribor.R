#' ribor: A package for reading .ribo files 
#'
#' The 'ribor' package offers a suite of reading functions for the datasets
#' present in a .ribo file and also provides some rudimentary plotting 
#' functions.
#' 
#' @section Vignette:
#' To get started with the ribor package, please see the vignette page at
#' \url{https://ribosomeprofiling.github.io/ribor/ribor.html}.
#' 
#' @section Related Tools:
#' 
#' The paper associated with the Ribo ecosystem can be found at
#' \url{https://academic.oup.com/bioinformatics/advance-article/doi/10.1093/bioinformatics/btaa028/5701654}.
#' 
#' For more information on the preprocessing pipeline, please see the link to
#' the source code at \url{https://github.com/ribosomeprofiling/riboflow}.
#' 
#' For more information on the .ribo file format, please see its documentation
#' page at \url{https://ribopy.readthedocs.io/en/latest/ribo_file_format.html}.
#' 
#' For an alternative to ribor, please see a link to source code of ribopy, 
#' a python interface, at \url{https://github.com/ribosomeprofiling/ribopy}.
#' 
#' 
#' @section Package Content:
#' \subsection{Generating a ribo object}{
#'  \code{\link{Ribo}} to get started 
#' }
#' 
#' \subsection{Length Distribution}{
#'  \code{\link{get_length_distribution}} to get length distribution counts
#'  
#'  \code{\link{plot_length_distribution}} to plot the length distribution
#' }
#' 
#' \subsection{Region Counts}{
#'   \code{\link{get_region_counts}} to get region counts
#'    
#'   \code{\link{plot_region_counts}} to plot the region counts 
#' }
#' 
#' \subsection{Metagene Coverage}{
#'   \code{\link{get_metagene}} to get metagene site coverage
#'   
#'   \code{\link{get_tidy_metagene}} to get a tidy format of the metagene site coverage
#'   
#'   \code{\link{plot_metagene}} to plot the metagene site coverage
#' }
#' 
#' @docType package
#' @name ribor
#' @importFrom methods show setClass setGeneric setMethod is validObject new
#' @importFrom S4Vectors metadata metadata<-
NULL
