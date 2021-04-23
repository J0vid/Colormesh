#' Internal tool to read in various image formats for the Colormesh pipeline
#' @importFrom magick image_read
#' @importFrom imager load.image magick2cimg
#' @param imagedir directory of images.
#' @param image.names A vector of image names to look for in imagedir.
#' @return Returns the loaded image
#' @examples
#'  #read in an image and plot it
#'  plot(image_reader(paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), "GPLP_unw_001.jpg"))
#' @export
image_reader <- function(imagedir, image.names){

  image.files <- list.files(imagedir, pattern = "*\\.JPG|*\\.jpg|*\\.TIF|*\\.tif|*\\.TIFF|*\\.tif|*\\.png|*\\.PNG|*\\.bmp|*\\.BMP|*\\.cr2|*\\.CR2|*\\.nef|*\\.orf|*\\.crw")

  supported.raw.formats <- c("cr2","nef","orf","crw","CR2")

  tmp.name <- image.files[grepl(pattern = image.names, image.files)]

  if(substr(tmp.name, nchar(tmp.name) - 2, nchar(tmp.name)) %in% supported.raw.formats){
    tmp.image <- magick::image_read(paste0(imagedir, tmp.name))
    tmp.image <- imager::magick2cimg(tmp.image)
    } else {
    tmp.image <- imager::load.image(paste0(imagedir, tmp.name))
      }

  return(tmp.image)
}

