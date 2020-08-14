#' Internal function for calculating a mean of data in array format
#' @param data an array from which to calculate a mean
#' @return a matrix of N_landmarks x N_dims
#' @export
array.mean <- function (data){
  mean.matrix = matrix(0, nrow = length(data[, 1, 1]), ncol = length(data[1,, 1]))
  for (i in 1:length(data[, 1, 1])) {
    for (j in 1:length(data[1, , 1])) {
      mean.matrix[i, j] = mean(data[i, j, ])
    }
  }
  return(mean.matrix)
}

#' Calculating means/group means for color sampled data
#'
#' @param mesh.colors.object a mesh.colors object. The result of tps.unwarp when color.sampling was specified
#' @param covariate_data dataframe with variables to specify a group mean to calculate
#' @param group_labels a vector of factors to group by. Up to two separate factors can be accepted
#' @return a mesh.colors object, with $sampled.colors now being the specified mean
#' @export
mean.mesh.colors <- function(mesh.colors.object, covariate_data = NULL, group_labels = NULL){

  if(is.null(covariate_data)){
    mean.mesh <- array.mean(mesh.colors.object$sampled.color)
  } else{
    if(is.null(group_labels)) stop("Give me some group labels to calculate a mean with!")
    for(i in 1:length(group_labels)){
      for(j in 1:ncol(covariate_data)){
        if(sum(group_labels[i] == covariate_data[,j]) > 0) assign(paste0("f", i), which(group_labels[i] == covariate_data[,j]))

      }
    }
    if(length(group_labels) == 1) mean.mesh <- array.mean(mesh.colors.object$sampled.color[,, f1])
    if(length(group_labels) == 2) mean.mesh <- array.mean(mesh.colors.object$sampled.color[,, intersect(f1, f2)])

    mesh.colors.object$sampled.color <- array(mean.mesh, dim = c(nrow(mean.mesh), ncol(mean.mesh), 1))
    return(mesh.colors.object)
    # return(list(mean.mesh = mean.mesh, delaunay = mesh.colors.object$delaunay))
  }
}
