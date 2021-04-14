#' Read in and convert images to jpeg for digitization in geomorph
#' @importFrom magick image_read
#' @importFrom imager load.image magick2cimg save.image
#' @importFrom geomorph digitize2d
#' @param imagedir directory of images to measure. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param image.names A vector of image names to look for in imagedir. These images should be unwarped or deformed to a common reference shape.
#' @param nlandmarks number of landmarks to acquire per image.
#' @param writedir directory to save converted images. If left NULL, images will be save to a temporary directory
#' @param dump.tmp.images Logical value to keep temporarily created jpegs. By default they will be deleted when landmarking is completed.
#' @return This function reads in several image formats and converts them to jpeg. The function returns the paths to the images that were converted, as well as the landmarks.
#' @details This function is a wrapper around geomorph::digitize2d() that a) allows for more general image format reading and b) automatically reads in the landmarks into R after saving the TPS files. Geomorph only supports reading in jpeg files, so this function converts all images to jpeg in a temporary directory, calls digitize2d for landmarking and then removes the temporary jpegs upon completion.
#' @seealso \code{\link[geomorph]{digitize2d}} (used for landmarking)
#' @examples
#' #example place 3 landmarks on one image
#' ex.landmark <- landmark.images(imagedir = paste0(path.package("Colormesh"),"/extdata/cropped_images/"), image.names = "GPHP_001.tiff", nlandmarks = 3)
#'
#' @export
landmark.images <- function(imagedir, image.names, nlandmarks, writedir = NULL, dump.tmp.images = T){

  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP|*.cr2|*.CR2|*.nef|*.orf|*.crw")
  if(is.null(writedir)){
    dump.tmp.images <- T
    writedir <- tempdir()
  }
  for(i in 1:length(image.names)){
    rawread <- image_reader(imagedir, image.files[grepl(image.names[i], image.files)])
    # rawread <- image_read(paste0(imagedir, image.files[grepl(image.names[i], image.files)]))

    # tmp.jpeg <- image_convert(rawread, "JPEG")

    # image_write(tmp.jpeg, path = paste0(writedir, "/", image.names[i], ".jpg"))
    save.image(rawread, file = paste0(writedir, "/", image.names[i], ".jpg"))

  }

  written.images <- paste0(writedir, "/", dir(writedir, pattern = "*.jpg"))

  geomorph::digitize2d(filelist = written.images, nlandmarks = nlandmarks, tpsfile = paste0(writedir, "/Colormesh_landmarks.TPS"))

  cm_lm <- tps2array(paste0(writedir, "/Colormesh_landmarks.TPS"))
  dimnames(cm_lm)[[3]] <- image.names

  if(dump.tmp.images) file.remove(written.images)

  return(cm_lm)
}



