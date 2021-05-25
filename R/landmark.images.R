#' Read in and convert images to jpeg for digitization in geomorph
#' @importFrom magick image_read
#' @importFrom imager load.image magick2cimg save.image
#' @importFrom geomorph digitize2d define.sliders gpagen
#' @param imagedir directory of images to measure. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param image.names A vector of image names to look for in imagedir. These images should be unwarped or deformed to a common reference shape.
#' @param nlandmarks number of landmarks to acquire per image.
#' @param scale how long is the scale in your images?
#' @param Multscale Logical value--should the coords be pre-multiplied by scale value?
#' @param writedir directory to save the TPS file.
#' @param tps.filename a name for the TPS file. If no name is provided, it will default to "/Colormesh_landmarks.TPS"
#' @return This function reads in several image formats and converts them to jpeg. The function returns the paths to the images that were converted, as well as the landmarks.
#' @details This function is a wrapper around geomorph::digitize2d() that a) allows for more general image format reading and b) automatically reads in the landmarks into R after saving the TPS files. Geomorph only supports reading in jpeg files, so this function converts all images to jpeg in a temporary directory, calls digitize2d for landmarking and then removes the temporary jpegs upon completion.
#' @seealso \code{\link[geomorph]{digitize2d}} (used for landmarking)
#' @examples
#' #example place 3 landmarks on one image
#' ex.landmark <- landmark.images(imagedir = paste0(path.package("Colormesh"),"/extdata/cropped_images/"), image.names = "GPLP_001.png", nlandmarks = 3)
#'
#' @export
landmark.images <- function(imagedir, image.names, nlandmarks, scale = NULL, Multscale = F, writedir = NULL, tps.filename = NULL){

  image.files <- list.files(imagedir, pattern = "*\\.JPG|*\\.jpg|*\\.TIF|*\\.tif|*\\.TIFF|*\\.tif|*\\.png|*\\.PNG|*\\.bmp|*\\.BMP|*\\.cr2|*\\.CR2|*\\.nef|*\\.orf|*\\.crw")
  if(is.null(writedir)) stop("Please provide a directory to save the TPS file to.")

    tmpimgdir <- tempdir()

  for(i in 1:length(image.names)){
    if(length(grepl(image.names[i], image.files)) == 0) stop(paste0("Didn't find a matching image name in the provided directory. Please check that image.names match the images in imagedir."))
    rawread <- image_reader(imagedir, image.files[grepl(image.names[i], image.files)])
    # rawread <- image_read(paste0(imagedir, image.files[grepl(image.names[i], image.files)]))

    # tmp.jpeg <- image_convert(rawread, "JPEG")

    # image_write(tmp.jpeg, path = paste0(writedir, "/", image.names[i], ".jpg"))
    save.image(rawread, file = paste0(tmpimgdir, "/tmp_", image.names[i], ".jpg"))

  }

  written.images <- paste0(tmpimgdir, "/", dir(tmpimgdir, pattern = "tmp_*"))
 if(is.null(tps.filename)) tps.filename <- "/Colormesh_landmarks.TPS"
  geomorph::digitize2d(filelist = written.images, nlandmarks = nlandmarks, tpsfile = paste0(writedir, tps.filename), scale = scale, MultScale = Multscale)

  cm_lm <- tps2array(paste0(writedir, tps.filename))
  dimnames(cm_lm)[[3]] <- image.names

  file.remove(written.images)

  return(cm_lm)
}



