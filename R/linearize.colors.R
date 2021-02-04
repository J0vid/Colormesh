#' Linear color data with approximation from Caves & Johnsen 2017
#'
#' @param rgb.object An array
#' @return An array of sampled colors in linearized space
#' @export
linearize.colors <- function(rgb.object) {

  linearized.rgb.object <- rgb.object

  if(length(dim(linearized.rgb.object)) > 2){
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

  } else if(length(dim(linearized.rgb.object)) < 3) {

    linearized.rgb.object <- array(NA, dim = c(dim(rgb.object), 2))
    rgb.object.array <- array(NA, dim = c(dim(rgb.object), 2))
    linearized.rgb.object[,,1] <- rgb.object
    linearized.rgb.object[,,2] <- rgb.object
    rgb.object.array[,,1] <- rgb.object
    rgb.object.array[,,2] <- rgb.object


    ## Transform the red measure to linear values
    linearized.rgb.object[,1,] <- apply(rgb.object.array[,1,], 1:2, function(x) if (x < 0.04045){
      (x/12.92)
    }
    else {
      ((x+0.055)/1.055)^2.4
    })

    ## Transform the green measure to linear values
    linearized.rgb.object[,2,] <- apply(rgb.object.array[,2,], 1:2, function(x) if (x < 0.04045){
      (x/12.92)
    }
    else {
      ((x+0.055)/1.055)^2.4
    })

    ## Transform the blue measure to linear values
    linearized.rgb.object[,3,] <- apply(rgb.object.array[,3,], 1:2, function(x) if (x < 0.04045){
      (x/12.92)
    }
    else {
      ((x+0.055)/1.055)^2.4
    })

  }

  return(linearized.rgb.object)

}
