#' Create sliders file with code
#' @importFrom geomorph  define.sliders gpagen
#' @param perimeter.map A vector denoting the order your landmarks are placed in to create an outline around the object.
#' @param main.lms A vector of landmarks that should NOT be used as sliding semilandmarks.
#' @return This function returns a slider format that geomorph can use for sliding semilandmarks.
#' @details This function is a wrapper around geomorph::define.sliders(). Instead of loading up images and clicking on points to define sliders, we used define.sliders()'s AUTO mode, which can generate sliders from the points given in order. The drawback from that is that it treats the non-sliding landmarks like sliders. This function let's you specify the main landmarks and removes them from the sliders file, leaving you with only sliding semilandmarks.
#' @seealso \code{\link[geomorph]{define.sliders}} (used for landmarking)
#' @examples
#' #the first seven landmarks are type 1 lms for the guppy data. The rest can slide.
#' guppy.sliders <- make.sliders(c(1,8:17, 2, 18:19, 3, 20:27, 4, 28:42, 5, 43:52, 6, 53:54, 7, 55:62), main.lms = 1:7)
#'
#' @export
make.sliders <- function(perimeter.map, main.lms){

  sliders <- geomorph::define.sliders(perimeter.map)
  #remove type 1 landmarks from sliders matrix
  sliders <- sliders[sliders[,2] %in% main.lms == F,]
  return(sliders)
}
