#' Read in various image formats for the Colormesh pipeline
#' @importFrom magick image_read magick2cimg
#' @importFrom imager load.image
#' @param imagedir directory of images.
#' @param image.names A vector of image names to look for in imagedir.
#' @return Returns the loaded image
#' @examples
#' #load an image and plot
#' rgb.test <- rgb.measure(imagedir = paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), image.names = specimen.factors[,2], delaunay.map = delaunay.map, linearize.color.space = F)
#'
#' plot(rgb.test, individual = 5)
#' plot(rgb.test, individual = 5, style = "comparison")
#'
#' @export
image_reader <- function(imagedir, image.names){

  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP|*.cr2|*.CR2|*.nef|*.orf|*.crw")

  supported.raw.formats <- c("cr2","nef","orf","crw","CR2")

  tmp.name <- image.files[grepl(image.names, image.files)]

  if(substr(tmp.name, nchar(tmp.name) - 3, nchar(tmp.name)) %in% supported.raw.formats){
    tmp.image <- magick::image_read(paste0(imagedir, image.files[grepl(image.names, image.files)]))
    tmp.image <- magick::magick2cimg(tmp.image)
    } else {
    tmp.image <- imager::load.image(paste0(imagedir, image.files[grepl(image.names, image.files)]))
      }

  return(tmp.image)
}

