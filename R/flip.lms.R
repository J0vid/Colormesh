#' Flips landmarks to the same orientation if you have a mixture of left and right facing data
#'
#' @param landmarks A landmark array with dimensions N_landmarks x 2 x N_observations
#' @param imagedir The path to the working folder of images
#' @param side_data An index of which side the landmarks are facing
#' @param side_code What you call the side you want to flip (for example, "right" or "R")
#' @return An array of landmark info with dimensions N_landmarks x 2 x N_observations with all data facing the same direction
#' @examples
#' guppy.lms <- tps2array(system.file("extdata", "original_lms.TPS", package = "Colormesh"))
#' flip.test <- flip.lms(landmarks = guppy.lms, imagedir = paste0(path.package("Colormesh"),"/inst/extdata/cropped_images/"), side_data = c("right", rep("left", 9)))
#'
#' #plot the flipped example
#' plot(flip.test[,,1])
#' points(guppy.lms[,,1])
#' @export
flip.lms <- function(landmarks, imagedir, side_data, side_code = "right"){
  #this function requires that the images are the same dimensions they were when you did the landmarking, otherwise it won't flip the image correctly
  #assumes constant image dimensions
  tmp.img <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP|*.cr2|*.CR2|*.nef|*.orf|*.crw")[1]
  flip.ref = dim(image_reader(imagedir = imagedir, image.names = tmp.img))[1]

  for(i in which(side_code == side_data)) landmarks[,1,i] <- abs(landmarks[,1,i] - flip.ref)
  return(landmarks)
}
