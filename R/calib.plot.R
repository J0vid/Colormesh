#' Diagnostic tool for looking at calibration images and the sampling landmarks
#'
#' @param imagedir path to calibration images
#' @param image.names A vector of image names to look for in imagedir.
#' @param calib.file tps2array object with the sampled color standard
#' @param cex change the point size on the image
#' @param col change point colors
#' @param individual which specimen do you want to plot? Defaults to the first specimen
#' @return a plot to check if you should flip the y-axis of the color standard landmarks
#' @export


calib.plot <- function(imagedir, image.names, calib.file, cex = 2, col = "red", individual = 1){

  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.tif| *.TIF|*.png|*.PNG|*.bmp|*.BMP")
  corresponding.image <- load.image(paste0(imagedir, image.files[grepl(image.names[individual], image.files)]))

  plot(corresponding.image)
  points(calib.file[,,grepl(image.names[individual], dimnames(calib.file)[[3]])][,1], -calib.file[,,grepl(image.names[individual], dimnames(calib.file)[[3]])][,2] + dim(corresponding.image)[2], col = col, pch = 19, cex = cex)

  print("If the landmarks look flipped relative to the image, set flip.y.values to T in rgb.calibrate")
}
