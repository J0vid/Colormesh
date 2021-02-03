#' Diagnostic tool for looking at calibration images and the sampling landmarks
#'
#' @param corresponding.image an example calibration image
#' @param calib.file tps2array object with the sampled color standard
#' @param point.size change the point size on the image
#' @return a plot to check if you should flip the y-axis of the color standard landmarks
#' @export


calib.plot <- function(corresponding.image, calib.file, point.size = 2){

  plot(corresponding.image)
  points(calib.file[,1,1], -calib.file[,2,1] + dim(corresponding.image)[2], col = 2, pch = 19, cex = point.size)

  print("If the landmarks look flipped relative to the image, set flip.y.values to T in rgb.calibrate")
}
