#' Internal tool to read in various image formats for the Colormesh pipeline
#' @importFrom magick image_read
#' @importFrom imager load.image magick2cimg
#' @param imagedir directory of images.
#' @param image.names A vector of image names to look for in imagedir.
#' @return Returns the loaded image
#' @examples
#'  #read in an image and plot it
#'  ex.image <- image_reader(paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), "GPLP_unw_001.jpg")
#'  plot(ex.image)
#' @export
image_reader <- function(imagedir, image.names){

  image.files <- list.files(imagedir, pattern = "*\\.JPG|*\\.jpg|*\\.TIF|*\\.tif|*\\.TIFF|*\\.tif|*\\.png|*\\.PNG|*\\.bmp|*\\.BMP|*\\.cr2|*\\.CR2|*\\.nef|*\\.orf|*\\.crw")
  image.files.san.ext <- tools::file_path_sans_ext(image.files)
  image.names <- tools::file_path_sans_ext(image.names)

  supported.raw.formats <- c("cr2","nef","orf","crw","CR2", "TIF", "tif", "TIFF", "tif")

  # tmp.name <- image.files[grepl(pattern = image.names, image.files)]
  tmp.name <- image.files[image.files.san.ext == image.names]
  if(length(tmp.name) == 0) stop(paste0("Could not find ", image.names, " in the directory provided. Do the names provided match the images in the directory?"))

  if(substr(tmp.name, nchar(tmp.name) - 2, nchar(tmp.name)) %in% supported.raw.formats){
    tmp.image <- magick::image_read(paste0(imagedir, tmp.name))
    tmp.image <- imager::magick2cimg(tmp.image)
    } else {
    tmp.image <- imager::load.image(paste0(imagedir, tmp.name))
      }

  return(tmp.image)
}

