#' Internal function for color sampling an image. Calculates the pixels in a circular neighborhood of specified radius.
#'
#' @param px.radius How many neighboring pixels to include when analyzing image color at a given landmark. A value of 1 just gives back the original pixel.
#' @return The coordinates of a circle with radius px.radius
#' @examples
#' plot(sampling.circle(4), asp = 1)
#' @export
sampling.circle <- function(px.radius = 2){
  y = -px.radius:px.radius
  x.circle= rep(0, length(y))
  for(j in 1:length(x.circle)){
    x.circle[j] = sqrt(px.radius^2 - y[j]^2)
  }

  circle.nums = rbind(cbind(x.circle,y), cbind(-x.circle,y))

  dimvec = rep(0, length(x.circle))
  for(i in 1:length(x.circle)){
    dimvec[i] = dim(cbind(x.circle[i]:-x.circle[i], y[i]))[1]
  }

  circle.coords = matrix(0, nrow=sum(dimvec), ncol=2)
  for(i in 1:length(dimvec)){
    circle.coords[(sum(dimvec[1:i-1])+1):(sum(dimvec[1:(i)])),] =  cbind(x.circle[i]:-x.circle[i], y[i])
  }

  #if(px.radius == 1) circle.coords <- t(as.matrix(c(0,0)))

  return(circle.coords)
}
