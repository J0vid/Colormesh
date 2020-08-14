#' Flips landmarks to the same orientation if you have a mixture of left and right facing data
#'
#' @param landmarks A landmark array with dimensions N_landmarks x 2 x N_observations
#' @param imagepath The path to the working folder of images
#' @param side_data An index of which side the landmarks are facing
#' @param side_code What you call the side you want to flip (for example, "right" or "R")
#' @return An array of landmark info with dimensions N_landmarks x 2 x N_observations with all data facing the same direction
#' @export
flip.lms <- function(landmarks, imagepath, side_data, side_code = "right"){
  #this function requires that the images are the same dimensions they were when you did the landmarking, otherwise it won't flip the image correctly
  #assumes constant image dimensions

  imagepath <- paste0(imagepath, list.files(imagepath, pattern = "*.JPG|*.jpg|*.tif|*.png")[1])
  flip.ref = dim(load.image(imagepath[1]))[1]

  for(i in 1:sum(side_data == side_code)) landmarks[,,side_data == side_code][,1,i] <- abs(landmarks[,,side_data == side_code][,1,i] - flip.ref)
  return(landmarks)
}
