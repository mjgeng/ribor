#' Information on the RNA-Seq data of the experiments, if any
#'
#' \code{\link{get_rnaseq}} returns a data frame containing information on the transcript name, experiment, and
#' sequence abundance
#'
#' As a default value, experiment.list is presumed to include all of the
#' experiments within a ribo file. RNA-Seq data is an optional dataset to
#' include in a .ribo file. The experiments in experiment.list are checked
#' for experiment existence in the ribo file and then checked for RNA-seq data.
#'
#' The returned DataFrame can either be in the tidy format for easier data
#' cleaning or in a condensed non-tidy format. The data will present RNA-seq counts
#' for each transcript in each valid experiment in experiment.list.
#'
#' The 'alias' parameter specifies whether or not the returned DataFrame
#' should present each transcript as an alias instead of the original name.
#' If 'alias' is set to TRUE, then the column of the transcript names will
#' contain the aliases rather than the original reference names of the .ribo
#' file.
#'
#' @examples
#' #generate the ribo object
#' file.path <- system.file("extdata", "sample.ribo", package = "ribor")
#' sample <- Ribo(file.path)
#'
#' #list out the experiments of interest that have RNA-Seq data
#' experiments <- c("Hela_1", "Hela_2", "WT_1")
#' regions <- c("UTR5", "CDS", "UTR3")
#' rnaseq.data <- get_rnaseq(ribo.object = sample,
#'                           tidy = TRUE,
#'                           region = regions,
#'                           experiment = experiments)
#'
#'
#' @param ribo.object A 'Ribo' object
#' @param experiment List of experiment names
#' @param alias Option to report the transcripts as aliases/nicknames
#' @param region Specific region(s) of interest
#' @param compact Option to return a DataFrame with Rle and factor as opposed to a raw data.frame
#' @param tidy Option to return the data frame in a tidy format
#' @seealso \code{\link{Ribo}} to generate the necessary ribo.object parameter
#' @return An annotated data frame containing the RNA-Seq counts for the regions in specified in the `region` parameter with the option of
#' presenting the data in a tidy format. Additionally, the function returns a DataFrame with Rle and factor applied if the `compact` parameter
#' is set to TRUE and a data.frame without any Rle or factor if the `compact` parameter is set to FALSE
#' @importFrom rhdf5 h5ls h5read
#' @importFrom S4Vectors DataFrame Rle
#' @importFrom tidyr gather
#' @export
get_rnaseq <- function(ribo.object,
                       tidy = TRUE,
                       region = c("UTR5", "UTR5J", "CDS", "UTR3J", "UTR3"),
                       experiment = experiments(ribo.object),
                       compact = TRUE,
                       alias = FALSE) {
    if (!is(ribo.object, "Ribo")) stop("Please provide a ribo object.")
    rnaseq.experiments <- check_rnaseq(ribo.object, experiment)
    check_alias(ribo.object, alias)
    regions <- check_regions(ribo.object, region)
    ribo.experiments <- experiments(ribo.object)
    
    #get just the experiments that exist
    ref.names <- change_reference_names(ribo.object, alias)
    ref.length <- length(ref.names)
    total.experiments <- length(rnaseq.experiments)
    num.regions <- length(regions)
    path <- path(ribo.object)
    
    result <- matrix(nrow = ref.length * total.experiments, ncol = num.regions)
    colnames(result) <- regions
    
    values <- c("UTR5" = 1, "UTR5J" = 2, "CDS" = 3, "UTR3J" = 4, "UTR3" = 5)
    cols   <- unname(values[regions])
    rows   <- seq_len(ref.length)
    
    #generate the untidy version
    for (index in seq(total.experiments)) {
        experiment <- rnaseq.experiments[index]
        exp_path <- paste("/experiments/", experiment, "/rnaseq/rnaseq", sep = "")
        row.start <- (index - 1) * ref.length + 1
        row.stop <- row.start + ref.length - 1
        result[row.start:row.stop,] <- t(h5read(path, exp_path, index = list(cols, rows)))
    }
    
    rnaseq <- rep(rnaseq.experiments, each = ref.length)
    transcripts <- rep(ref.names, total.experiments)
    
    result <- data.frame(experiment = rnaseq,
                         transcript = factor(transcripts),
                         result,
                         stringsAsFactors = FALSE)
    
    if (tidy) result <- gather(result, "region", "count", regions)
    if (!compact) return (result)
    
    return(prepare_DataFrame(ribo.object, as(result, "DataFrame")))
}

change_reference_names <- function(ribo.object,
                                   alias) {
    #generate appropriate ref.names in the untidy version
    ref.names <- get_reference_names(ribo.object)
    if (alias) {
        original <- ref.names
        ref.names <- vector(mode = "character", length = length(original))
        for (i in seq_len(length(original))) {
            ref.names[i] <- original_hash(ribo.object)[[original[i]]]
        }
    }
    return(ref.names)
}

check_rnaseq <- function(ribo.object, experiments) {
    #check the experiments for validity and RNA-seq presence
    check_experiments(ribo.object, experiments)
    
    #obtain the rnaseq data
    path <- path(ribo.object)
    table <- get_content_info(path)
    has.rnaseq <- table[table$rna.seq == TRUE,]$experiment
    
    #find the experiments in the experiment.list that do not have coverage and print warnings
    check <- setdiff(experiments, has.rnaseq)
    if (length(check)) {
        for (experiment in check) {
            warning("'",
                    experiment,
                    "'",
                    " did not have RNA-Seq data.",
                    call. = FALSE)
        }
        
        if (length(check) == length(experiments)) {
            stop("No valid experiments with RNA-Seq.", call. = FALSE)
        } else {
            warning("Param 'experiments' contains experiments that did not",
                    "have RNA-Seq data. The return value ignores these", 
                    "experiments.",
                    call. = FALSE)
        }
    }
    return(intersect(experiments, has.rnaseq))
}