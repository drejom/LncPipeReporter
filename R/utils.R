#' Change the first letter of sentence/phrase to uppercase
#'
#' @param x The sentence/phrase.
#'
#' @return The sentence/phrase converted.
#'
#' @examples
#' toUpperFirstLetter('the man called Qi Zhao is handsome!')
#' toUpperFirstLetter('coolest Yu Sun')
toUpperFirstLetter <- function(x) {
  paste0(toupper(substr(x, 1, 1)), substring(x, 2))
}


#' Search the data folder recursively then determine their types
#'
#' @param path path for searching.
#'
#' @return A list with types containing file absolute path in vector.
#'
#' @examples
#' search_then_determine()
search_then_determine <- function(path = system.file(paste0("extdata", .Platform$file.sep, "demo_results"),
                                                    package = "LncPipeReporter")) {
  # Initialize an empty list for storing file types
  type.list <- list()
  
  determine_type <- function(x, x.name) {
    file.header <- paste(x[,1], x[,2])
    if (grepl("Left", file.header)) {
      # It's highly not recommended to use <<- symbol, 
      # but here is to build a temporary function called many times in lapply.
      type.list[['Tophat2']] <<- x.name
    } else if (grepl("LINC", file.header)) {
      type.list[['lncRNA']] <<- x.name
    } else if (grepl("Started", file.header)) {
      if (is.null(type.list[['STAR']])) {
        type.list[['STAR']] <<- x.name
      } else {
        type.list[['STAR']][length(type.list[['STAR']]) + 1] <<- x.name
      }
    } else if (grepl(":", file.header)) {
      type.list[['Design']] <<- x.name
    } else if (grepl("ID", file.header)) {
      type.list[['RSEM']] <<- x.name
    } else if (grepl("reads", file.header)) {
      if (is.null(type.list[['Hisat2']])) {
        type.list[['Hisat2']] <<- x.name
      } else {
        type.list[['Hisat2']][length(type.list[['Hisat2']]) + 1] <<- x.name
      }
    }
  }
  
  parsing.list <-  sapply(list.files(path = path, recursive = TRUE), 
                          USE.NAMES = FALSE, 
                          function(x) paste0(path, .Platform$file.sep, x))
  
  parsing.list <- parsing.list[- grep("fastqc", parsing.list)]
  file.headlines <- sapply(parsing.list, function(x) 
    tryCatch({fread(x, fill = TRUE, nrows = 1, header = FALSE)}, error = function(e) {}))
  
  lapply(names(file.headlines), function(x) determine_type(file.headlines[[x]], x))
  
  return(type.list)
}
