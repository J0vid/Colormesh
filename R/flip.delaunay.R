#' flip delaunay triangulation along the Y axis to match an image
#'
#' @param delaunay.map delaunay triangulation object
#' @param example.image image that corresponds to the delaunay map
#' @return The function will return delaunay objects with the Y-axis values flipped to deal with non-matching origins between images and landmarks
#' @export
flip.delaunay <- function(delaunay.map, example.image){

  image.dims <- dim(example.image)
  delaunay.map$interior[,2] <- -delaunay.map$interior[,2] + image.dims[2]
  delaunay.map$perimeter[,2] <- -delaunay.map$perimeter[,2] + image.dims[2]
  delaunay.map$centroids[,2] <- -delaunay.map$centroids[,2] + image.dims[2]

  return(delaunay.map)
}
