#' Combine metadata with calibrated colormesh data for analysis
#'
#' @param df A calibrated.mesh.colors object (generated from rgb.calibrate) or mesh.colors object (generated from rgb.measure)
#' @param specimen.factors The covariate data that you want to combine with the calibrated data
#' @param use.perimeter.data If TRUE, we will return the color values for the perimeter landmarks as well as the interior landmarks.
#' @param write2csv A directory is to write a csv to, if desired
#' @return The function will return a dataframe of specimen data (inherits the original column names) and landmark x & y values along with calibrated RGB values.
#' @export
make.colormesh.dataset <- function(df, specimen.factors, use.perimeter.data = F, write2csv = NULL){

  if(class(df) == "calibrated.mesh.colors"){
  #interior color data####
  rgb.interior <- array2row3d(df$calibrated[,,order(dimnames(df$calibrated)[[3]], specimen.factors$V1)])
  rgb.names <- df$calibrated[,,1]
  rgb.names[,1] <- paste0("r_interior", 1:nrow(df$calibrated))
  rgb.names[,2] <- paste0("g_interior", 1:nrow(df$calibrated))
  rgb.names[,3] <- paste0("b_interior", 1:nrow(df$calibrated))
  colnames(rgb.interior) <- array2row3d(rgb.names)[1,]

  #interior lms####
  interior.lms <- array2row(df$delaunay.map$interior)
  xy.names <- df$delaunay.map$interior
  xy.names[,1] <- paste0("x_interior", 1:nrow(df$delaunay.map$interior))
  xy.names[,2] <- paste0("y_interior", 1:nrow(df$delaunay.map$interior))
  colnames(interior.lms) <- array2row(xy.names)[1,]

  if(use.perimeter.data){
    #perimeter color data####
    rgb.perimeter <- array2row3d(df$calibrated.perimeter[,,order(dimnames(df$calibrated.perimeter)[[3]], specimen.factors$V1)])
    rgb.names <- df$calibrated.perimeter[,,1]
    rgb.names[,1] <- paste0("r_perimeter", 1:nrow(df$calibrated.perimeter))
    rgb.names[,2] <- paste0("g_perimeter", 1:nrow(df$calibrated.perimeter))
    rgb.names[,3] <- paste0("b_perimeter", 1:nrow(df$calibrated.perimeter))
    colnames(rgb.perimeter) <- array2row3d(rgb.names)[1,]


    #perimeter.lms
    perimeter.lms <- array2row(df$delaunay.map$perimeter)
    xy.names <- df$delaunay.map$perimeter
    xy.names[,1] <- paste0("x_perimeter", 1:nrow(df$delaunay.map$perimeter))
    xy.names[,2] <- paste0("y_perimeter", 1:nrow(df$delaunay.map$perimeter))
    colnames(perimeter.lms) <- array2row(xy.names)[1,]

    combined.df <- data.frame(specimen.factors, rgb.interior, rgb.perimeter, interior.lms, perimeter.lms)
  }

  }


  if(class(df) == "mesh.colors"){
  rgb.interior <- array2row3d(df$sampled.color[,,order(dimnames(df$sampled.color)[[3]], specimen.factors$V1)])
  rgb.names <- df$sampled.color[,,1]
  rgb.names[,1] <- paste0("r_interior", 1:nrow(df$sampled.color))
  rgb.names[,2] <- paste0("g_interior", 1:nrow(df$sampled.color))
  rgb.names[,3] <- paste0("b_interior", 1:nrow(df$sampled.color))
  colnames(rgb.interior) <- array2row3d(rgb.names)[1,]

  #interior lms####
  interior.lms <- array2row(df$delaunay.map$interior)
  xy.names <- df$delaunay.map$interior
  xy.names[,1] <- paste0("x_interior", 1:nrow(df$delaunay.map$interior))
  xy.names[,2] <- paste0("y_interior", 1:nrow(df$delaunay.map$interior))
  colnames(interior.lms) <- array2row(xy.names)[1,]

  #perimeter option
  if(use.perimeter.data){
    rgb.perimeter <- array2row3d(df$sampled.perimeter[,,order(dimnames(df$sampled.perimeter)[[3]], specimen.factors$V1)])
    rgb.names <- df$sampled.perimeter[,,1]
    rgb.names[,1] <- paste0("r_perimeter", 1:nrow(df$sampled.perimeter))
    rgb.names[,2] <- paste0("g_perimeter", 1:nrow(df$sampled.perimeter))
    rgb.names[,3] <- paste0("b_perimeter", 1:nrow(df$sampled.perimeter))
    colnames(rgb.perimeter) <- array2row3d(rgb.names)[1,]

    #perimeter.lms
    perimeter.lms <- array2row(df$delaunay.map$perimeter)
    xy.names <- df$delaunay.map$perimeter
    xy.names[,1] <- paste0("x_perimeter", 1:nrow(df$delaunay.map$perimeter))
    xy.names[,2] <- paste0("y_perimeter", 1:nrow(df$delaunay.map$perimeter))
    colnames(perimeter.lms) <- array2row(xy.names)[1,]

    combined.df <- data.frame(specimen.factors, rgb.interior, rgb.perimeter, interior.lms, perimeter.lms)
  }
  }





  if(use.perimeter.data == F) combined.df <- data.frame(specimen.factors, rgb.interior, interior.lms)
  if(is.null(write2csv) == F) write.csv(combined.df, file = write2csv)

  return(combined.df)
}



