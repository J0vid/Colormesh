#' Linear color data with approximation from Caves & Johnsen 2017
#'
#' @param rgb.object A .TPS file
#' @return An array of sampled colors in linearized space
#' @export
linearize.colors <- function(rgb.object) {

  linearized.rgb.object <- rgb.object

  ## Transform the red measure to linear values
  linearized.rgb.object[,1,] <- apply(rgb.object[,1,], 1:2, function(x) if (x < 0.04045){
    (x/12.92)
  }
  else {
    ((x+0.055)/1.055)^2.4
  })

  ## Transform the green measure to linear values
  linearized.rgb.object[,2,] <- apply(rgb.object[,2,], 1:2, function(x) if (x < 0.04045){
    (x/12.92)
  }
  else {
    ((x+0.055)/1.055)^2.4
  })

  ## Transform the blue measure to linear values
  linearized.rgb.object[,3,] <- apply(rgb.object[,3,], 1:2, function(x) if (x < 0.04045){
    (x/12.92)
  }
  else {
    ((x+0.055)/1.055)^2.4
  })


  return(linearized.rgb.object)

}
