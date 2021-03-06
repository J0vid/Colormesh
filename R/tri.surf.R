#' Fit a delaunay triangulation to an outline of landmarks.
#'
#' @import imager
#' @importFrom tripack tri.mesh triangles
#' @importFrom sp point.in.polygon
#' @param tri.object A 2D matrix of landmarks to initialize delaunay triangulation. This should be the configuration you used for unwarping. If you did your unwarping in Colormesh, the target configuration was returned by the function.
#' @param point.map A vector that denotes the correct order of landmarks in tri.object. Landmarks must form a perimeter for delaunay triangulation
#' @param num.passes How many rounds of delaunay triangulation to perform. In each pass, the centroids of the triangles will be calculated and be used as points in the next round of triangulation.
#' @param corresponding.image Supply a corresponding image to the mesh to make sure that the points line up with the image correctly. If an image is not provided, no plot will be produced.
#' @param flip.delaunay Logical value for fliping the Y-axis of the delaunay points. Set delaunay.flip to true if your points appear upside down on the image.
#' @return A list of class tri.surf.points. $interior is the position of internal (non-perimeter) points generated from triangulation. $perimeter is the initial points submitted for triangulation. $centroids is the final set of centroids from the triangulation. $final.mesh is the last round of triangulation. $point.map is the point map used to give the order of perimeter landmarks.
#' @examples
#' consensus <- tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))
#' test.image <- image_reader(paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), "GPLP_unw_001.jpg")
#' delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)
#' @export
tri.surf <- function(tri.object, point.map, num.passes, corresponding.image = NULL, flip.delaunay = F){

  if(length(dim(tri.object)) > 2 & dim(tri.object)[3] == 1) tri.object <- tri.object[,,1]
  if(length(dim(tri.object)) > 2 & dim(tri.object)[3] > 1){
    warning("Did you mean to supply an array to this function? By default we will use the first slice.")
    tri.object <- tri.object[,,1]
  }

  #remove initial duplicates
  if(sum(duplicated(tri.object)) > 0) warning("Initial landmark set has duplicate coordinates; they've been removed")

  tri.object <- tri.object[duplicated(tri.object) == F,]

  tri.object.prime <- tri.object

  tri.object <- tri.object[point.map,]

  for(i in 1:num.passes){

    gen.tri <- tri.mesh(tri.object[,1], tri.object[,2])
    tri.cent <- matrix(0, nrow= length(tripack::triangles(gen.tri)[,1]), ncol= 2) #get centroids from triangulation

    for(j in 1:length(tri.cent[,1])){
      tri.cent[j,] = round(colMeans(tri.object[tripack::triangles(gen.tri)[j,1:3],]))
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

  if(is.null(corresponding.image) == F){
  plot(corresponding.image)
  points(tri.interior, col = 2)
  lines(tri.object.prime[point.map,], lwd = 1.5, col = "yellow")
 }

  #Old returned list with centroids in case that's a breaking change:
  tri.surf.object <- list(interior = tri.interior, perimeter = tri.object.prime, centroids = tri.cent.plot, final.mesh = gen.tri, point.map = point.map)
  # tri.surf.object <- list(interior = tri.interior, perimeter = tri.object.prime, final.mesh = gen.tri, point.map = point.map)
  class(tri.surf.object) <- c("tri.surf.points")
  return(tri.surf.object)
}













