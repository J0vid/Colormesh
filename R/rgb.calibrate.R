#' Calibration of existing color sampled data
#'
#' @param sampled.array Previously sampled data from the rgb.measure function.
#' @param imagedir directory of images to measure for calibration. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param image.names A vector of image names to look for in imagedir. These images should be unwarped or deformed to a common reference shape.
#' @param color.standard.values a matrix of known values for collected color standard points. Should be N_points x 3
#' @param px.radius The size of the circular neighborhood (in pixels) to sample color around each triangulated point.
#' @param flip.y.values should the calbration points be flipped to match the images?
#' @return The function will return $sampled.color-- an N_points x 3 (RGB) x N_observations array of sampled color values. A tri.surf.points class object will also be returned as $delaunay. Finally, a calibrated array of color values will be returned under $calibrated
#' @export
rgb.calibrate <- function(sampled.array, imagedir, image.names, calib.file, color.standard.values = NULL, px.radius = 2, flip.y.values = F){

#check that if color standard is suppplied, it is actually a matrix
  #linearize needs to be a toggle

  # imagedir <- "Guppies/EVERYTHING/righties/"
  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.tif| *.TIF|*.png|*.PNG|*.bmp|*.BMP")
  calibration.array <- array(NA, dim = c(sum(as.numeric(calib.file$ID) == 1), 3, length(image.names)))
  calibrated.array <- sampled.array$sampled.color
  calibrated.linearized.array <- sampled.array$linearized.color

  start.time <- as.numeric(Sys.time())

  circle.coords <- sampling.circle(px.radius)


  for(i in 1:length(image.names)){

    tmp.image <- load.image(paste0(imagedir, image.files[grepl(image.names[i], image.files)]))
    img.dim <- dim(tmp.image)

    if(flip.y.values & i == 1) calib.file[,2] <- -calib.file[,2] + img.dim[2]

    buffered.image <- array(0, dim = c(dim(tmp.image)[1],dim(tmp.image)[2], 3))
    buffered.image[,,1] <- as.matrix(tmp.image[,,1])
    buffered.image[,,2] <- as.matrix(tmp.image[,,2])
    buffered.image[,,3] <- as.matrix(tmp.image[,,3])


    for(j in 1:nrow(calibration.array)){
      #select the landmarks for the corresponding image from calib.file
      #tmp.x & y currentlyrely on read.tps info. make sure it works with new tps2array

      tmp.x <- calib.file[grepl(image.names[i], calib.file$IMAGE),][j,1] + circle.coords[,1]
      tmp.y <- calib.file[grepl(image.names[i], calib.file$IMAGE),][j,2] + circle.coords[,2]

      calibration.array[j,1,i] <-  mean(diag(buffered.image[tmp.x, tmp.y, 1]))
      calibration.array[j,2,i] <-  mean(diag(buffered.image[tmp.x, tmp.y, 2]))
      calibration.array[j,3,i] <-  mean(diag(buffered.image[tmp.x, tmp.y, 3]))
    }

    if(i == 1){
      end.time <- as.numeric(Sys.time())
      iteration.time <- abs(start.time - end.time)
      estimated.time <- (iteration.time * length(image.files)) / 60
    }

    cat(paste0("Processed ", image.names[i], ": ", round((i/length(image.names)) * 100, digits = 2), "% done. \n Estimated time remaining: ", round(abs((iteration.time * i)/60 - estimated.time), digits = 1), " minutes \n"))


  } #end i

  #if no color standard values are provided this function will assume the calibration data are landmarks on an RGB color standard and adjusts for differences in brightness. Otherwise, it will correct against the known color standard values
  lcalib <- linearize.colors(calibration.array)
  calib.means <- array.mean(calibration.array)
  lcalib.means <- array.mean(lcalib)
  col.change <- calib.means

  for(j in 1:3){ #dim(col.change)[3]){
    col.change <- calibration.array[,,j] - calib.means
    #substract away RGB deviation for each color
    calibrated.array[,1,j] <- sampled.array$sampled.color[,1,j] - mean(col.change[,1])
    calibrated.array[,2,j] <- sampled.array$sampled.color[,2,j] - mean(col.change[,2])
    calibrated.array[,3,j] <- sampled.array$sampled.color[,3,j] - mean(col.change[,3])

    #substract away RGB deviation for each color
    lcol.change <- lcalib[,,j] - lcalib.means
    calibrated.linearized.array[,1,j] <- sampled.array$linearized.color[,1,j] - mean(lcol.change[,1])
    calibrated.linearized.array[,2,j] <- sampled.array$linearized.color[,2,j] - mean(lcol.change[,2])
    calibrated.linearized.array[,3,j] <- sampled.array$linearized.color[,3,j] - mean(lcol.change[,3])
  }

  #adjust to know color standard values instead of image brightness
  if(is.null(color.standard.values) == F){
    #linearize known color standard values?


    for(j in 1:3){ #dim(col.change)[3]){
      col.change <- calibration.array[,,j] - color.standard.values
      #substract away RGB deviation for each color
      calibrated.array[,1,j] <- sampled.array$sampled.color[,1,j] - mean(col.change[,1])
      calibrated.array[,2,j] <- sampled.array$sampled.color[,2,j] - mean(col.change[,2])
      calibrated.array[,3,j] <- sampled.array$sampled.color[,3,j] - mean(col.change[,3])

      #substract away RGB deviation for each color linearized
      # lcol.change <- lcalib[,,j] - linearize.colors(color.standard.values)
      # calibrated.linearized.array[,1,j] <- sampled.array$linearized.color[,1,j] - mean(lcol.change[,1])
      # calibrated.linearized.array[,2,j] <- sampled.array$linearized.color[,2,j] - mean(lcol.change[,2])
      # calibrated.linearized.array[,3,j] <- sampled.array$linearized.color[,3,j] - mean(lcol.change[,3])
    }

  }


  dimnames(calibrated.array)[[3]] <- image.names
  #limit adjustments to viable image ranges
  calibrated.array[calibrated.array < 0] <- 0
  calibrated.array[calibrated.array > 1] <- 1
  calibrated.linearized.array[calibrated.linearized.array < 0] <- 0
  calibrated.linearized.array[calibrated.linearized.array > 1] <- 1

  #mesh.colors needs to also return a list of pairwise sample points that had overlapping pixels#### This is handled as a separate function currently...
  calibrated.mesh.colors <- list(sampled.color = sampled.array$sampled.color, calibrated = calibrated.array, linearized.color = sampled.array$linearized.color, calibrated.linear = calibrated.linearized.array, delaunay.map = delaunay.map)

  class(calibrated.mesh.colors) <- "calibrated.mesh.colors"
  return(calibrated.mesh.colors)
}


