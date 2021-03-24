#' Read in various image formats for the Colormesh pipeline
#'
#' @param imagedir directory of images to measure. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param image.names A vector of image names to look for in imagedir. These images should be unwarped or deformed to a common reference shape.
#' @return The function will return $sampled.color-- an N_points x 3 (RGB) x N_observations array of sampled color values. A tri.surf.points class object will also be returned as $delaunay.
#' @examples
#' #load an image and plot
#' rgb.test <- rgb.measure(imagedir = paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), image.names = specimen.factors[,2], delaunay.map = delaunay.map, linearize.color.space = F)
#'
#' plot(rgb.test, individual = 5)
#' plot(rgb.test, individual = 5, style = "comparison")
#'
#' @export
rgb.measure <- function(imagedir, image.names, delaunay.map, px.radius = 2, linearize.color.space = F){

  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP|*.cr2|*.nef|*.orf|*.crw")

  #if the last 3 letters are raw format, load the image with magick, then convert to cimg
  if(image.files)
  tmp.image <- load.image(paste0(imagedir, image.files[grepl(image.names[i], image.files)]))

  return(tmp.image)


