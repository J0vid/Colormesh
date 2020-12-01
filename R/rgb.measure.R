#' Non-linear image registration using TPS deformation.
#'
#' @param imagedir directory of images to measure. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param landmarks A landmark array with dimensions N_landmarks x 2 x N_observations. dimnames(landmarks)[[3]] should have the corresponding image filenames for each observation.
#' @param delaunay.map delaunay triangulation object
#' @param px.radius The size of the circular neighborhood (in pixels) to sample color around each triangulated point.
#' @return If write.images is true, warped images will be saved to the write.dir directory. If color sampling is true, the function will return $sampled.color-- an N_points x 3 (RGB) x N_observations array of sampled color values. A tri.surf.points class object will also be returned as $delaunay.
#' @export
rgb.measure <- function(imagedir, landmarks, delaunay.map, px.radius = 2){

  require(sp)
  require(tripack)

  # imagedir <- "Guppies/EVERYTHING/righties/"
  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.tif|*.png")
  start.time <- as.numeric(Sys.time())

  if(color.sampling){
    #triangulate
    delaunay.template <- delaunay.map #tri.surf(mean.lm, point.map, 4)
    # sampled.r <- sampled.g <- sampled.b <- matrix(0, ncol = nrow(delaunay.template$interior), nrow = dim(landmarks)[3])
    if(is.null(calib.file) == F) calibration.array <- array(NA, dim = c(sum(as.numeric(calib.file$ID) == 1), 3, dim(landmarks)[3]))
    sampled.array <- array(NA, dim = c(nrow(delaunay.template$interior), 3, dim(landmarks)[3]))
    calibrated.array <- sampled.array
    circle.coords <- sampling.circle(px.radius)
  }

  for(i in 1:3){ #length(image.files)){
    tmp.image <- load.image(paste0(imagedir, image.files[image.files == dimnames(landmarks)[[3]][i]]))
    img.dim <- dim(tmp.image)
    orig.lms <- cbind(abs(landmarks[,1,i] - img.dim[1]), abs(landmarks[,2,i]- img.dim[2]))


      translated.interior <-  cbind(delaunay.template$interior[,1] + img.dim[1]/2, delaunay.template$interior[,2] + img.dim[2]/2)
      #add buffer to image so we don't ask for pixels that don't exist
      buffered.image = array(0, dim = c(dim(tmp.warp)[1]+ 2*px.radius,dim(tmp.warp)[2]+ 2*px.radius, 3))
      buffered.image[(px.radius):(dim(tmp.warp)[1]+(px.radius-1)),(px.radius+1):(dim(tmp.warp)[2]+(px.radius)),] = tmp.warp
      # buffered.image[(px.radius):(dim(tmp.warp)[1]+(px.radius-1)),(px.radius+1):(dim(tmp.warp)[2]+(px.radius)),] = tmp.warp[,,]+ final.adjustment2[ind,]

      for(j in 1:length(translated.interior[,1])){
        sampled.array[j,1,i] <-  mean(diag(buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius,(px.radius + (translated.interior[j,2] + circle.coords[,2])), 1]))
        sampled.array[j,2,i] <-  mean(diag(buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.interior[j,2] + circle.coords[,2])), 2]))
        sampled.array[j,3,i] <-  mean(diag(buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.interior[j,2] + circle.coords[,2])), 3]))
      }
      dimnames(sampled.array)[[3]] <- dimnames(landmarks)[[3]]

    if(i == 1){
      end.time <- as.numeric(Sys.time())
      iteration.time <- abs(start.time - end.time)
      estimated.time <- (iteration.time * length(image.files)) / 60
    }

    cat(paste0("Processed ", image.name, ": ", round((i/dim(landmarks)[3]) * 100, digits = 2), "% done. \n Estimated time remaining: ", round(abs((iteration.time * i)/60 - estimated.time), digits = 1), "minutes"))

  } #end i

  mesh.colors <- list(sampled.color = sampled.array, delaunay = delaunay.template)

  class(mesh.colors) <- "mesh.colors"
  return(mesh.colors)
}
