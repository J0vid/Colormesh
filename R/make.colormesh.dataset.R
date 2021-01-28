#' Combine metadata with calibrated colormesh data for analysis
#'
#' @param calibrated.data A calibrated.mesh.colors object (generated from rgb.calibrate)
#' @param specimen.factors The covariate data that you want to combine with the calibrated data
#' @param use.perimeter.data If TRUE, we will return the color values for the perimeter landmarks as well as the interior landmarks.
#' @param write.csv A directory is to write a csv to, if desired
#' @return The function will return a dataframe of specimen data (inherits the original column names) and landmark x & y values along with calibrated RGB values.
#' @export
make.colormesh.dataset <- function(calibrated.data, specimen.factors, use.perimeter.data = F, write2csv = NULL){

  #interior color data####
  rgb.interior <- array2row3d(calibrated.data$calibrated[,,order(dimnames(calibrated.data$calibrated)[[3]], specimen.factors$V1)])
  rgb.names <- calibrated.data$calibrated[,,1]
  rgb.names[,1] <- paste0("r_interior", 1:nrow(calibrated.data$calibrated))
  rgb.names[,2] <- paste0("g_interior", 1:nrow(calibrated.data$calibrated))
  rgb.names[,3] <- paste0("b_interior", 1:nrow(calibrated.data$calibrated))
  colnames(rgb.interior) <- array2row3d(rgb.names)[1,]

  #interior lms####
  interior.lms <- array2row(calibrated.data$delaunay.map$interior)
  xy.names <- calibrated.data$delaunay.map$interior
  xy.names[,1] <- paste0("x_interior", 1:nrow(calibrated.data$delaunay.map$interior))
  xy.names[,2] <- paste0("y_interior", 1:nrow(calibrated.data$delaunay.map$interior))
  colnames(interior.lms) <- array2row(xy.names)[1,]

  if(use.perimeter.data){
    #perimeter color data####
    rgb.perimeter <- array2row3d(calibrated.data$calibrated.perimeter[,,order(dimnames(calibrated.data$calibrated.perimeter)[[3]], specimen.factors$V1)])
    rgb.names <- calibrated.data$calibrated.perimeter[,,1]
    rgb.names[,1] <- paste0("r_perimeter", 1:nrow(calibrated.data$calibrated.perimeter))
    rgb.names[,2] <- paste0("g_perimeter", 1:nrow(calibrated.data$calibrated.perimeter))
    rgb.names[,3] <- paste0("b_perimeter", 1:nrow(calibrated.data$calibrated.perimeter))
    colnames(rgb.perimeter) <- array2row3d(rgb.names)[1,]

    #perimeter.lms
    perimeter.lms <- array2row(calibrated.data$delaunay.map$perimeter)
    xy.names <- calibrated.data$delaunay.map$perimeter
    xy.names[,1] <- paste0("x_perimeter", 1:nrow(calibrated.data$delaunay.map$perimeter))
    xy.names[,2] <- paste0("y_perimeter", 1:nrow(calibrated.data$delaunay.map$perimeter))
    colnames(perimeter.lms) <- array2row(xy.names)[1,]

    combined.df <- data.frame(specimen.factors, rgb.interior, rgb.perimeter, interior.lms, perimeter.lms)
  }

  if(use.perimeter.data == F) combined.df <- data.frame(specimen_factors, rgb.interior, interior.lms)
  if(is.null(write2csv) == F) write.csv(write2csv)

  return(combined.df)
}



