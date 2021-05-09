#' Converts arrays to row formats for 2D data
#'
#' @param data an array of N_landmarks x 2 x N_specimens
#' @return
#' @export
array2row <- function (data){

    Nlandmarks <- dim(data)[2] * dim(data)[1]
    x.y = matrix(0, 1, dim(data)[1] * dim(data)[2])
    xseq = seq(1, Nlandmarks, 2)
    yseq = seq(2, Nlandmarks, 2)

    for (ind in 1:dim(x.y)[1]) {
      x.y[1, xseq] <- data[, 1]
      x.y[1, yseq] <- data[, 2]
    }
  return(x.y)
}


#' Converts arrays to row formats for 3D data
#'
#' @param data an array of N_landmarks x 3 x N_specimens
#' @return
#' @export
array2row3d <- function (data){

  Nlandmarks = dim(data)[2] * dim(data)[1]
  if (length(dim(data)) > 2) {
    x.y = matrix(0, dim(data)[3], dim(data)[1] * dim(data)[2])
    xseq = seq(1, Nlandmarks, 3)
    yseq = seq(2, Nlandmarks, 3)
    zseq = seq(3, Nlandmarks, 3)

    for (ind in 1:dim(x.y)[1]) {
      x.y[ind, xseq] = data[, 1, ind]
      x.y[ind, yseq] = data[, 2, ind]
      x.y[ind, zseq] = data[, 3, ind]
    }
  }
  else if(length(dim(data)) == 2) {
    #catch for a matrix with one ind
    x.y = matrix(0, 1, dim(data)[1] * dim(data)[2])
  xseq = seq(1, Nlandmarks, 3)
  yseq = seq(2, Nlandmarks, 3)
  zseq = seq(3, Nlandmarks, 3)
  x.y[1, xseq] = data[, 1]
  x.y[1, yseq] = data[, 2]
  x.y[1, zseq] = data[, 3]
  }


  return(x.y)
}

