#' Combine metadata with calibrated colormesh data for analysis
#'
#' @param df A calibrated.mesh.colors object (generated from rgb.calibrate) or mesh.colors object (generated from rgb.measure)
#' @param use.perimeter.data If TRUE, we will return the color values for the perimeter landmarks as well as the interior landmarks.
#' @param write2csv A directory is to write a csv to, if desired
#' @return The function will return a dataframe of specimen data (inherits the original column names) and landmark x & y values along with calibrated RGB values.
#' @export
#' @examples
#' #covariate data and consensus lms
#' specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)
#' consensus <- tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))
#' test.image <- image_reader(paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), "GPLP_unw_001.jpg")
#' delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)
#'
#' rgb.test <- rgb.measure(imagedir = paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), image.names = specimen.factors[,2], delaunay.map = delaunay.map, linearize.color.space = F)
#' cm.dataset <- make.colormesh.dataset(rgb.test)
#'
make.colormesh.dataset <- function(df, use.perimeter.data = F, write2csv = NULL){

  if(class(df) == "calibrated.mesh.colors"){
    #interior color data####
    df.names <- dimnames(df$calibrated)[[3]]
    rgb.interior <- array2row3d(df$calibrated)
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
      rgb.perimeter <- array2row3d(df$calibrated.perimeter)
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

      combined.df <- data.frame(df.names, rgb.interior, rgb.perimeter, interior.lms, perimeter.lms)
    }
  }

  if(class(df) == "mesh.colors"){
    df.names <- dimnames(df$sampled.color)[[3]]
    rgb.interior <- array2row3d(df$sampled.color)
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
      rgb.perimeter <- array2row3d(df$sampled.perimeter)
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

      combined.df <- data.frame(df.names, rgb.interior, rgb.perimeter, interior.lms, perimeter.lms)
    }
  }

  if(use.perimeter.data == F) combined.df <- data.frame(df.names, rgb.interior, interior.lms)
  if(is.null(write2csv) == F) write.csv(combined.df, file = write2csv)

  return(combined.df)
}



