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
