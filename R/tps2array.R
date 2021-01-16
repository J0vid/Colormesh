#' convert TPS data to landmark array
#'
#' @param tpsfile A read.tps() object
#' @return An array of landmark info with dimensions N_landmarks x 2 x N_observations
#' @export
tps2array <- function (tpsfile)
{
  #this function assumes unique image names!
  # arrayname <- substr(unique(tpsfile$IMAGE), 1, nchar(as.character(unique(tpsfile$IMAGE))) - 4)
  arrayname <- factor(unique(tpsfile$IMAGE))
  Nlandmarks <- sum(tpsfile$ID == unique(tpsfile$ID)[1])
  # ID.nums <- rep(0, length(tpsfile$ID))
  coord.array <- array(dim = c(Nlandmarks, 2, length(arrayname)))
  # for (i in 0:(length(tpsfile$ID)/Nlandmarks)) {
  #   ID.nums[((i * Nlandmarks) + 1):(((i + 1) * Nlandmarks) +
  #                                     1)] = rep(i, length(Nlandmarks))
  # }
  for (ind in 1:length(coord.array[1, 1, ])) {
    coord.array[, , ind] = as.matrix(tpsfile[tpsfile$ID == unique(tpsfile$ID)[ind],
                                             1:2])
  }
  # dimnames(coord.array)[[3]] <- (arrayname)

  return(coord.array)
}
