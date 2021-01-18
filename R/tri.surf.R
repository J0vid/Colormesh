#' Flips landmarks to the same orientation if you have a mixture of left and right facing data
#'
#' @param tri.object A 2D matrix of landmarks to initialize delaunay triangulation
#' @param point.map A vector that denotes the correct order of landmarks in tri.object. Landmarks must form a perimeter for delaunay triangulation
#' @param num.passes How many rounds of delaunay triangulation to perform. In each pass, the centroids of the triangles will be calculated and be used as points in the next round of triangulation.
#' @param corresponding.images Supply a corresponding image to the mesh to make sure that the points line up with the image correctly
#' @param flip.delaunay Logical value for fliping the Y-axis of the delaunay points. Set delaunay.flip to true if your points appear upside down on the image.
#' @return A list of class tri.surf.points. $interior is the position of internal (non-perimeter) points generated from triangulation. $perimeter is the initial points submitted for triangulation. $centroids is the final set of centroids from the triangulation. $final.mesh is the last round of triangulation. $point.map is the point map used to give the order of perimeter landmarks.
#' @export
tri.surf <- function(tri.object, point.map, num.passes, corresponding.image, flip.delaunay = F){

  require(tripack)
  require(sp)

  #remove initial duplicates
  if(sum(duplicated(tri.object)) > 0) warning("Initial landmark set has duplicate coordinates; they've been removed")

  tri.object <- tri.object[duplicated(tri.object) == F,]

  tri.object.prime <- tri.object

  tri.object <- tri.object[point.map,]

  for(i in 1:num.passes){

    gen.tri <- tri.mesh(tri.object[,1], tri.object[,2])
    tri.cent <- matrix(0, nrow= length(triangles(gen.tri)[,1]), ncol= 2) #get centroids from triangulation

    for(j in 1:length(tri.cent[,1])){
      tri.cent[j,] = round(colMeans(tri.object[triangles(gen.tri)[j,1:3],]))
    }

    are.you.in <- point.in.polygon(tri.cent[,1], tri.cent[,2], tri.object.prime[point.map,1], tri.object.prime[point.map,2]) #index for out of boundary triangles caused by concavities

    tri.cent.plot <- tri.cent

    tri.cent <- tri.cent[are.you.in == 1,] #keep only triangles in original boundaries

    tri.object <- rbind(as.matrix(tri.object), tri.cent) #for each iteration of num.passes, bind the new centroid coordinates with the starting coords

    tri.object <- tri.object[duplicated(tri.object) == F,] #remove duplicates generated from triangulation
  }

  tri.interior <- tri.object[-c(1:nrow(tri.object.prime)),]

  #initial point flip ####need to flip gen.tri as well?
  tri.interior[,2] <- -tri.interior[,2] + dim(corresponding.image)[2]
  tri.object.prime[,2] <- -tri.object.prime[,2] + dim(corresponding.image)[2]
  tri.cent.plot[,2] <- -tri.cent.plot[,2] + dim(corresponding.image)[2]




  if(flip.delaunay){
    tri.interior[,2] <- -tri.interior[,2] + dim(corresponding.image)[2]
    tri.object.prime[,2] <- -tri.object.prime[,2] + dim(corresponding.image)[2]
    tri.cent.plot[,2] <- -tri.cent.plot[,2] + dim(corresponding.image)[2]
  }

  # plot(corresponding.image)
  # points(tri.interior, col = 2)
  # lines(tri.object.prime[point.map,], lwd = 1.5, col = "yellow")

  tri.surf.object <- list(interior = tri.interior, perimeter = tri.object.prime, centroids = tri.cent.plot, final.mesh = gen.tri, point.map = point.map)
  class(tri.surf.object) <- c("tri.surf.points")
  return(tri.surf.object)
}

#' plotting method for objects of class "tri.surf.points"
#'
#' @method plot
#' @param x an object of class "tri.surf.points"
#' @param style the type of plot to generate. There are currently 2 options, "points" and "triangulation". "points" is the default and just plots the interior and perimeter points. "triangulation" plots the delaunay triangulation wireframe with centroids highlighted.
#' @param ... Additional plotting parameters to be passed to plot.default
#' @return A list of class tri.surf.points. $interior is the position of internal (non-perimeter) points generated from triangulation. $perimeter is the initial points submitted for triangulation. $centroids is the final set of centroids from the triangulation. $final.mesh is the last round of triangulation. $point.map is the point map used to give the order of perimeter landmarks.
#' @export
plot.tri.surf.points <- function(x, style = "points",...){
  if(style == "points"){
    plot(x$perimeter, ylim = rev(range(x$perimeter[,2])), asp = 1, ...)
    points(x$interior, ...)
  }

  if(style == "triangulation"){
    tri.object <- rbind(x$perimeter[x$point.map,], x$interior)
    are.you.in <- point.in.polygon(x$centroids[,1], x$centroids[,2], x$perimeter[x$point.map,1], x$perimeter[x$point.map,2]) #index for out of boundary triangles caused by concavities
    plot(x$perimeter, typ = "n", ylab = "", xlab = "", asp = 1, axes = F, ylim = rev(range(x$perimeter[,2])), ...)
    points(x$centroids[are.you.in == 1,], col = 2, pch = 19, cex = .25, ...)

    for(j in c(1:nrow(triangles(x$final.mesh)))[are.you.in==1]){
      lines(rbind(tri.object[triangles(x$final.mesh)[j,1],], tri.object[triangles(x$final.mesh)[j,2],]))
      lines(rbind(tri.object[triangles(x$final.mesh)[j,1],], tri.object[triangles(x$final.mesh)[j,3],]))
      lines(rbind(tri.object[triangles(x$final.mesh)[j,2],], tri.object[triangles(x$final.mesh)[j,3],]))
    }
  }

}











