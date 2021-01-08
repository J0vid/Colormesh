#' Diagnostic tool for looking at point sampling density
#'
#' @param delaunay.map delaunay triangulation object
#' @param px.radius The size of the circular neighborhood (in pixels) to sample color around each triangulated point.
#' @return An index of points pairs that will have overlapping (and redundant) pixel information.
#' @export


point.overlap <- function(delaunay.map, px.radius){

# full symmetric distance matrix of triangulation object interior points
delaunay.dmatrix <- fields::rdist(delaunay.map$interior)

#convert it to long format
delaunay.dists.long <- cbind(expand.grid(1:nrow(delaunay.dmatrix), 1:nrow(delaunay.dmatrix)), delaunay.dmatrix[1:(nrow(delaunay.dmatrix)^2)])
colnames(delaunay.dists.long) <- c("point1", "point2", "distance")

#index points that are likely overlapping in pixel sampling
too.close <- delaunay.dists.long[delaunay.dists.long[,3] < px.radius & delaunay.dists.long[,3] != 0,]


plot(delaunay.map, xlab = "", ylab = "")
points(delaunay.map$interior[too.close[,1],], col = 2)

return(list(close.points = too.close))

}

