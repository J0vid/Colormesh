#' Read in and convert raw images to jpeg for digitization in geomorph
#' @importfrom magick image_read image_convert image_write
#' @param imagedir directory of images to measure. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param image.names A vector of image names to look for in imagedir. These images should be unwarped or deformed to a common reference shape.
#' @param writedir directory to save converted images.
#' @return This function reads in Raw image formats and converts them to jpeg. These jpegs can then be used by geomorph for landmarking within R.
#' @examples
#' #load an image and convert
#'
#' #use newly created jpegs for landmarking
#'
#' #remove tmpdir
#'
#' @export
raw2jpeg <- function(imagedir, image.names, writedir){

  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP|*.cr2|*.CR2|*.nef|*.orf|*.crw")

  for(i in 1:length(image.names)){
    # rawread <- image_reader(imagedir, image.files[grepl(image.names[i], image.files)])
    rawread <- image_read(paste0(imagedir, image.files[grepl(image.names[i], image.files)]))

    tmp.jpeg <- image_convert(rawread, "JPEG")

    image_write(tmp.jpeg, path = paste0(writedir, image.names[i], ".jpg"))
  }
}



