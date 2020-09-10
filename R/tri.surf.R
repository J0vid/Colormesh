#' Flips landmarks to the same orientation if you have a mixture of left and right facing data
#'
#' @param tri.object A 2D matrix of landmarks to initialize delaunay triangulation
#' @param point.map A vector that denotes the correct order of landmarks in tri.object. Landmarks must form a perimeter for delaunay triangulation
#' @param num.passes How many rounds of delaunay triangulation to perform. In each pass, the centroids of the triangles will be calculated and be used as points in the next round of triangulation.
#' @return A list of class tri.surf.points. $interior is the position of internal (non-perimeter) points generated from triangulation. $perimeter is the initial points submitted for triangulation. $centroids is the final set of centroids from the triangulation. $final.mesh is the last round of triangulation. $point.map is the point map used to give the order of perimeter landmarks.
#' @export
tri.surf <- function(tri.object, point.map, num.passes){
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

  tri.surf.object <- list(interior = tri.interior, perimeter = tri.object.prime, centroids = tri.cent.plot, final.mesh = gen.tri, point.map = point.map)
  class(tri.surf.object) <- "tri.surf.points"
  return(tri.surf.object)
}










