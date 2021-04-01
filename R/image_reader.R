#' Internal tool to read in various image formats for the Colormesh pipeline
#' @importFrom magick image_read
#' @importFrom imager load.image magick2cimg
#' @param imagedir directory of images.
#' @param image.names A vector of image names to look for in imagedir.
#' @return Returns the loaded image
#'
#' @export
image_reader <- function(imagedir, image.names){

  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP|*.cr2|*.CR2|*.nef|*.orf|*.crw")

  supported.raw.formats <- c("cr2","nef","orf","crw","CR2")

  tmp.name <- image.files[grepl(image.names, image.files)]

  if(substr(tmp.name, nchar(tmp.name) - 2, nchar(tmp.name)) %in% supported.raw.formats){
    tmp.image <- magick::image_read(paste0(imagedir, image.files[grepl(image.names, image.files)]))
    tmp.image <- imager::magick2cimg(tmp.image)
    } else {
    tmp.image <- imager::load.image(paste0(imagedir, image.files[grepl(image.names, image.files)]))
      }

  return(tmp.image)
}

