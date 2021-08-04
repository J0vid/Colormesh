#' Diagnostic tool for looking at calibration images and the sampling landmarks
#'
#' @param imagedir path to calibration images
#' @param image.names A vector of image names to look for in imagedir.
#' @param calib.file tps2array object with the sampled color standard
#' @param cex change the point size on the image
#' @param col change point colors
#' @param individual which specimen do you want to plot? Defaults to the first specimen
#' @return a plot to check if you should flip the y-axis of the color standard landmarks
#' @examples
#' #load covariates and calibration file
#' specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)
#' calib.file <- tps2array(system.file("extdata", "calib_LM_coords.TPS", package = "Colormesh"))
#'
#' calib.plot(paste0(path.package("Colormesh"),"/extdata/original_images/"), image.names = specimen.factors[,1], calib.file = calib.file)
#'
#' @export


calib.plot <- function(imagedir, image.names, calib.file, cex = 2, col = "red", individual = 1, flip.y.values = F){

  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.tif| *.TIF|*.png|*.PNG|*.bmp|*.BMP")
  corresponding.image <- load.image(paste0(imagedir, image.files[grepl(image.names[individual], image.files)]))
  img.dim <- dim(corresponding.image)

  plot(corresponding.image)
  if(flip.y.values) calib.file[,2,] <- -calib.file[,2,] + img.dim[2]
  points(calib.file[,,grepl(image.names[individual], dimnames(calib.file)[[3]])][,1], -calib.file[,,grepl(image.names[individual], dimnames(calib.file)[[3]])][,2] + dim(corresponding.image)[2], col = col, pch = 19, cex = cex)

  if(flip.y.values == F) print("If the landmarks look flipped relative to the image, set flip.y.values to T in rgb.calibrate")
    else{ print("If the landmarks look flipped relative to the image, set flip.y.values to F in rgb.calibrate")}
}

