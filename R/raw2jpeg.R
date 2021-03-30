#' Read in and convert raw images to jpeg for digitization in geomorph
#' @importfrom magick imageread
#' @param imagedir directory of images to measure. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param image.names A vector of image names to look for in imagedir. These images should be unwarped or deformed to a common reference shape.
#' @param writedir directory to save converted images.
#'  @return This function reads in Raw image formats and converts them to jpeg. These jpegs can then be used by geomorph for landmarking within R.
#' @examples
#' #load an image and convert
#'
#' #use newly created jpegs for landmarking
#'
#' #remove tmpdir
#'
#' @export
raw2jpeg <- function(imagedir, image.names, writedir){

  test <- magick::image_read("~/Downloads/Colormesh_Raw_test/IMG_7647.CR2")



  tmp.jpeg <- image_convert(test, "JPEG")

  image_write(tmp.jpeg, path = writedir)
}



