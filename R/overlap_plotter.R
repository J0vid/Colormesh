#' Diagnostic tool for looking at point sampling density
#'
#' @param delaunay.map delaunay triangulation object
#' @param px.radius The size of the circular neighborhood (in pixels) to sample color around each triangulated point.
#' @param style What kind of plot to show overlapping points with. Options are "points" and "triangulation".
#' @return An index of points pairs that will have overlapping (and redundant) pixel information. Only for the interior points of a delaunay triangulation (not the perimeter)
#' @export


point.overlap <- function(delaunay.map, px.radius, style = "points"){

# full symmetric distance matrix of triangulation object interior points
delaunay.dmatrix <- fields::rdist(delaunay.map$interior)

#convert it to long format
delaunay.dists.long <- cbind(expand.grid(1:nrow(delaunay.dmatrix), 1:nrow(delaunay.dmatrix)), delaunay.dmatrix[1:(nrow(delaunay.dmatrix)^2)])
colnames(delaunay.dists.long) <- c("point1", "point2", "distance")

#index points that are likely overlapping in pixel sampling
too.close <- delaunay.dists.long[delaunay.dists.long[,3] < px.radius & delaunay.dists.long[,3] != 0,]

#aspect ratio? plot(delaunay.map, xlab = "", ylab = "", asp = max(delaunay.map$interior[,2])/max(delaunay.map$interior[,1]))
if(style == "points"){
  plot(delaunay.map)
  points(delaunay.map$interior[too.close[,1],], col = 2, pch = 19)
  # text(delaunay.map$interior[too.close[,1],], col = 2, labels = too.close[,1])
}

if(style == "triangulation"){
  plot(delaunay.map, style = "triangulation")
  points(delaunay.map$interior[-too.close[,1],], col = 1, pch = 19, cex = .3)
  points(delaunay.map$interior[too.close[,1],], col = 2, pch = 19, cex = .7)
}

print(paste0("Indices of pairwise interior points that are within ", px.radius, " pixels of eachother."))

return(list(close.points = too.close))

}

