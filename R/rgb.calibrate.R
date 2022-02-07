#' Calibration of existing color sampled data
#'
#' @param sampled.array Previously sampled data from the rgb.measure function.
#' @param imagedir directory of images to measure for calibration. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param image.names A vector of image names to look for in imagedir.
#' @param color.standard.values a matrix of known values for collected color standard points. Should be N_points x 3
#' @param px.radius The size of the circular neighborhood (in pixels) to sample color around each triangulated point.
#' @param flip.y.values should the calbration points be flipped to match the images?
#' @return The function will return $sampled.color-- an N_points x 3 (RGB) x N_observations array of sampled color values. A tri.surf.points class object will also be returned as $delaunay. Finally, a calibrated array of color values will be returned under $calibrated
#' @examples
#'
#' #load landmarks and covariate data
#' guppy.lms <- tps2array(system.file("extdata", "original_lms.TPS", package = "Colormesh"))
#' specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)
#' calib.file <- tps2array(system.file("extdata", "calib_LM_coords.TPS", package = "Colormesh"))
#' consensus <- tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))
#' test.image <- image_reader(paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), "GPLP_unw_001.jpg")
#' delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)
#'
#' rgb.test <- rgb.measure(imagedir = paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), image.names = specimen.factors[,2], delaunay.map = delaunay.map, linearize.color.space = F)
#'
#' calibration.test <- rgb.calibrate(rgb.test, imagedir = paste0(path.package("Colormesh"),"/extdata/original_images/"), image.names = specimen.factors[,1], calib.file = calib.file)
#'
#' #check result####
#' plot(calibration.test, individual = 2, style = "comparison")
#' @export
rgb.calibrate <- function(sampled.array, imagedir, image.names, calib.file, color.standard.values = NULL, px.radius = 2, flip.y.values = F){

#check that if color standard is suppplied, it is actually a matrix
  if(is.null(color.standard.values) == F & missing(color.standard.values)) stop("color.standard.values is not provided. Please make sure to define your color standard.")
  if(is.null(color.standard.values) == F){
    if(ncol(color.standard.values) > 3) stop("color.standard.values has more columns than expected. Is the data in N_colors X RGB format?")}

  # imagedir <- "Guppies/EVERYTHING/righties/"
  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP|*.cr2|*.nef|*.orf|*.crw")
  image.files.san.ext <- tools::file_path_sans_ext(image.files)
  image.names <- tools::file_path_sans_ext(image.names)

  #check sampled.array image names against calib image.names supplied. If not the same, warn with 3 example paired names that didn't match
  if(identical(gsub("_unwarped", "", sampled.array$image.names), image.names) == F){
    #
    identical.index <- gsub("_unwarped", "", sampled.array$image.names) == image.names

    warning(paste("Original image name and calibration image name don't exactly match. \n Confirm calibration image is associated with the correct original image: \n",
            gsub("_unwarped", "", sampled.array$image.names)[!identical.index][1], " -> ",  image.names[!identical.index][1]))

  }

  calibration.array <- array(NA, dim = c(nrow(calib.file), 3, length(image.names)))
  calibrated.array <- sampled.array$sampled.color
  calibrated.perimeter <- sampled.array$sampled.perimeter

  start.time <- as.numeric(Sys.time())

  circle.coords <- sampling.circle(px.radius)

  for(i in 1:length(image.names)){

    # tmp.image <- load.image(paste0(imagedir, image.files[grepl(image.names[i], image.files)]))
    tmp.image <- image_reader(imagedir, image.files[image.files.san.ext == image.names[i]])
    img.dim <- dim(tmp.image)

    if(i == 1) calib.file[,2,] <- -calib.file[,2,] + img.dim[2]
    if(flip.y.values & i == 1) calib.file[,2,] <- -calib.file[,2,] + img.dim[2]

    buffered.image <- array(0, dim = c(dim(tmp.image)[1],dim(tmp.image)[2], 3))
    buffered.image[,,1] <- as.matrix(tmp.image[,,1])
    buffered.image[,,2] <- as.matrix(tmp.image[,,2])
    buffered.image[,,3] <- as.matrix(tmp.image[,,3])

    if(max(buffered.image) > 20){ #if the image looks like it's in a non-normalize scale, normalize it
      buffered.image[,,1] <- as.matrix(tmp.image[,,1])/max(tmp.image[,,1])
      buffered.image[,,2] <- as.matrix(tmp.image[,,2])/max(tmp.image[,,2])
      buffered.image[,,3] <- as.matrix(tmp.image[,,3])/max(tmp.image[,,3])
    }


    for(j in 1:nrow(calibration.array)){
      #select the landmarks for the corresponding image from calib.file
      #tmp.x & y currently rely on read.tps info. make sure it works with new tps2array
      calib.file.names <- tools::file_path_sans_ext(dimnames(calib.file)[[3]])
      #shakes fist at windows paths
      calib.file.names <- basename(gsub("\\\\", "/", calib.file.names))

      tmp.x <- calib.file[,, calib.file.names == image.names[i]][j,1] + circle.coords[,1]
      tmp.y <- calib.file[,,calib.file.names == image.names[i]][j,2] + circle.coords[,2]
      if(px.radius == 0){
        calibration.array[j,1,i] <-  buffered.image[tmp.x, tmp.y, 1]
        calibration.array[j,2,i] <-  buffered.image[tmp.x, tmp.y, 2]
        calibration.array[j,3,i] <-  buffered.image[tmp.x, tmp.y, 3]
      } else{
        calibration.array[j,1,i] <-  mean(diag(buffered.image[tmp.x, tmp.y, 1]))
        calibration.array[j,2,i] <-  mean(diag(buffered.image[tmp.x, tmp.y, 2]))
        calibration.array[j,3,i] <-  mean(diag(buffered.image[tmp.x, tmp.y, 3]))
      }
    }

    if(i == 1){
      end.time <- as.numeric(Sys.time())
      iteration.time <- abs(start.time - end.time)
      estimated.time <- (iteration.time * length(image.files)) / 60
    }

    cat(paste0("Processed ", image.names[i], ": ", round((i/length(image.names)) * 100, digits = 2), "% done. \n Estimated time remaining: ", round(abs((iteration.time * i)/60 - estimated.time), digits = 1), " minutes \n"))


  } #end i

  #if no color standard values are provided this function will assume the calibration data are landmarks on an RGB color standard and adjusts for differences in brightness. Otherwise, it will correct against the known color standard values
  # lcalib <- linearize.colors(calibration.array)
  if(sampled.array$linearized == F) calib.means <- array.mean(calibration.array)
  if(sampled.array$linearized == T){
    calibration.array <- linearize.colors(calibration.array)
    calib.means <- array.mean(calibration.array)
    color.standard.values <- linearize.colors(color.standard.values)[,,1]
  }
  # lcalib.means <- array.mean(lcalib)
  col.change <- calib.means

  for(j in 1:dim(calibrated.array)[3]){
    col.change <- calibration.array[,,j] - calib.means

    #substract away RGB deviation for each color
    calibrated.array[,1,j] <- sampled.array$sampled.color[,1,j] - mean(col.change[,1])
    calibrated.array[,2,j] <- sampled.array$sampled.color[,2,j] - mean(col.change[,2])
    calibrated.array[,3,j] <- sampled.array$sampled.color[,3,j] - mean(col.change[,3])

    calibrated.perimeter[,1,j] <- sampled.array$sampled.perimeter[,1,j] - mean(col.change[,1])
    calibrated.perimeter[,2,j] <- sampled.array$sampled.perimeter[,2,j] - mean(col.change[,2])
    calibrated.perimeter[,3,j] <- sampled.array$sampled.perimeter[,3,j] - mean(col.change[,3])
    #substract away RGB deviation for each color
    # lcol.change <- lcalib[,,j] - lcalib.means
    # calibrated.linearized.array[,1,j] <- sampled.array$linearized.color[,1,j] - mean(lcol.change[,1])
    # calibrated.linearized.array[,2,j] <- sampled.array$linearized.color[,2,j] - mean(lcol.change[,2])
    # calibrated.linearized.array[,3,j] <- sampled.array$linearized.color[,3,j] - mean(lcol.change[,3])
  }

  #adjust to know color standard values instead of image brightness####
  if(is.null(color.standard.values) == F){
    #linearize known color standard values?
    for(j in 1:dim(calibrated.array)[3]){
      col.change <- calibration.array[,,j] - color.standard.values
      #substract away RGB deviation for each color
      calibrated.array[,1,j] <- sampled.array$sampled.color[,1,j] - mean(col.change[,1])
      calibrated.array[,2,j] <- sampled.array$sampled.color[,2,j] - mean(col.change[,2])
      calibrated.array[,3,j] <- sampled.array$sampled.color[,3,j] - mean(col.change[,3])

      calibrated.perimeter[,1,j] <- sampled.array$sampled.perimeter[,1,j] - mean(col.change[,1])
      calibrated.perimeter[,2,j] <- sampled.array$sampled.perimeter[,2,j] - mean(col.change[,2])
      calibrated.perimeter[,3,j] <- sampled.array$sampled.perimeter[,3,j] - mean(col.change[,3])
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

  dimnames(calibrated.perimeter)[[3]] <- image.names
  #limit adjustments to viable image ranges
  calibrated.perimeter[calibrated.perimeter < 0] <- 0
  calibrated.perimeter[calibrated.perimeter > 1] <- 1


  #mesh.colors needs to also return a list of pairwise sample points that had overlapping pixels#### This is handled as a separate function currently...
  calibrated.mesh.colors <- list(sampled.color = sampled.array$sampled.color, calibrated = calibrated.array, delaunay.map = sampled.array$delaunay.map, calibrated.perimeter = calibrated.perimeter)

  class(calibrated.mesh.colors) <- "calibrated.mesh.colors"
  return(calibrated.mesh.colors)
}


