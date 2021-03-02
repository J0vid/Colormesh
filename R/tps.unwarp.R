#' Non-linear image registration using TPS deformation.
#'
#' @param imagedir directory of images to deform. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param landmarks A landmark array with dimensions N_landmarks x 2 x N_observations. dimnames(landmarks)[[3]] should have the corresponding image filenames for each observation.
#' @param write.images T or F indicating whether or not to save warped images. This is highly recommended so you can check out of image warping worked like expected.
#' @param write.dir Where to save warped images. Images will be named after the original image name (is that a bad idea because of overwriting? We will find out).
#' @param color.sampling T or F indicating whether or not to sample color using delaunay triangulation.
#' @param num.delaunay.passes The number of rounds of delaunay triangulation to perform if color sampling is desired.
#' @param point.map The order of points around the perimeter of your object
#' @param px.radius The size of the circular neighborhood (in pixels) to sample color around each triangulated point.
#' @param calib.file If color standard data is provided and color sampling is selected, $calibrated color will provide second set of color sampling data, adjusted for the differences in color standard values between images
#' @return If write.images is true, warped images will be saved to the write.dir directory. If color sampling is true, the function will return $sampled.color-- an N_points x 3 (RGB) x N_observations array of sampled color values. A tri.surf.points class object will also be returned as $delaunay.
#' @export
tps.unwarp <- function(imagedir, landmarks, write.images = T, write.dir = NULL, color.sampling = F, num.delaunay.passes = 2, point.map, px.radius = 2, calib.file = NULL){

  require(sp)
  require(tripack)

  if(write.images & is.null(write.dir)) stop("Please provide a folder to save images to by using the write.dir parameter. Alternatively, don't save images by making write.images = FALSE.")

  if(imagedir == write.dir) stop("Please write the warped images to a different path, so your original data don't get overwritten!")

  suppressMessages(mean.lm <- procSym(landmarks, scale = F, CSinit = F)$mshape)

  # imagedir <- "Guppies/EVERYTHING/righties/"
  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.PNG|*.png")
  start.time <- as.numeric(Sys.time())

  if(color.sampling){
    #triangulate
    corresponding.image <- load.image(paste0(imagedir, image.files[image.files == dimnames(landmarks)[[3]][1]]))
    suppressMessages(delaunay.template <- tri.surf(mean.lm, point.map, 4, corresponding.image = corresponding.image, flip.delaunay = T))
    # sampled.r <- sampled.g <- sampled.b <- matrix(0, ncol = nrow(delaunay.template$interior), nrow = dim(landmarks)[3])
    if(is.null(calib.file) == F) calibration.array <- array(NA, dim = c(sum(as.numeric(calib.file$ID) == 1), 3, dim(landmarks)[3]))
    sampled.array <- array(NA, dim = c(nrow(delaunay.template$interior), 3, dim(landmarks)[3]))
    calibrated.array <- sampled.array
    circle.coords <- sampling.circle(px.radius)
  }

  for(i in 1:length(image.files)){
    tmp.image <- load.image(paste0(imagedir, image.files[image.files == dimnames(landmarks)[[3]][i]]))
    img.dim <- dim(tmp.image)
    # orig.lms <- cbind(abs(landmarks[,1,i] - img.dim[1]), abs(landmarks[,2,i]- img.dim[2]))
    orig.lms <- cbind(abs(landmarks[,1,i]), abs(landmarks[,2,i]- img.dim[2]))
    tar.lms <- cbind(mean.lm[,1] + img.dim[1]/2, mean.lm[,2] + img.dim[2]/2)

    image_defo <- function(x, y){ #I'm aware that it's terrible practice to use variables out of scope
      xs <- c(0:(img.dim[1] - 1))
      ys <- c(0:(img.dim[2] - 1))
      img.long <- as.matrix(expand.grid(xs, ys))
      img.long <- tps3d(img.long, tar.lms, orig.lms, threads = 0)
      return(list(x= img.long[,1], y = img.long[,2]))
    }

    # imwarp(tmp.image,map=image_defo,direction="reverse") %>% plot()
    # points(orig.lms , col = 2)
    # points(tar.lms, col = 3)


    tmp.warp <- imwarp(tmp.image, map = image_defo, direction = "reverse")
    image.name <- substr(dimnames(landmarks)[[3]][i], 1, nchar(as.character(dimnames(landmarks)[[3]][i])) - 4)
    #should I create a directory in the current working directory if write.dir is not provided? dir.create("warped_images")
    if(write.images) imager::save.image(tmp.warp, file = paste0(write.dir, image.name,".png"))


    if(color.sampling){
      translated.interior <-  cbind(delaunay.template$interior[,1] + img.dim[1]/2, delaunay.template$interior[,2] + img.dim[2]/2)
      #add buffer to image so we don't as for pixels that don't exist
      buffered.image = array(0, dim = c(dim(tmp.warp)[1]+ 2*px.radius, dim(tmp.warp)[2]+ 2*px.radius, 3))
      buffered.image[(px.radius):(dim(tmp.warp)[1]+(px.radius-1)),(px.radius+1):(dim(tmp.warp)[2]+(px.radius)),] = tmp.warp
      # buffered.image[(px.radius):(dim(tmp.warp)[1]+(px.radius-1)),(px.radius+1):(dim(tmp.warp)[2]+(px.radius)),] = tmp.warp[,,]+ final.adjustment2[ind,]

      if(max(buffered.image) > 20){ #if the image looks like it's in a non-normalize scale, normalize it
        buffered.image[(px.radius):(dim(tmp.warp)[1]+(px.radius-1)),(px.radius+1):(dim(tmp.warp)[2]+(px.radius)),1] <- as.matrix(tmp.warp[,,1])/max(tmp.warp[,,1])
        buffered.image[(px.radius):(dim(tmp.warp)[1]+(px.radius-1)),(px.radius+1):(dim(tmp.warp)[2]+(px.radius)),2] <- as.matrix(tmp.warp[,,2])/max(tmp.warp[,,2])
        buffered.image[(px.radius):(dim(tmp.warp)[1]+(px.radius-1)),(px.radius+1):(dim(tmp.warp)[2]+(px.radius)),3] <- as.matrix(tmp.warp[,,3])/max(tmp.warp[,,3])
      }

      for(j in 1:length(translated.interior[,1])){
        sampled.array[j,1,i] <-  mean(diag(buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius,(px.radius + (translated.interior[j,2] + circle.coords[,2])), 1]))
        sampled.array[j,2,i] <-  mean(diag(buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.interior[j,2] + circle.coords[,2])), 2]))
        sampled.array[j,3,i] <-  mean(diag(buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.interior[j,2] + circle.coords[,2])), 3]))
      }
    dimnames(sampled.array)[[3]] <- dimnames(landmarks)[[3]]
    } else {delaunay.template <- NULL}

    if(is.null(calib.file) == F){
      #get calibration data while we're at it
      for(j in 1:nrow(calibration.array)){
        calibration.array[j,1,i] <-  mean(diag(buffered.image[(calib.file[calib.file$IMAGE == dimnames(landmarks)[[3]][i], ][j,1] + circle.coords[,1] + px.radius), (px.radius + (calib.file[calib.file$IMAGE == dimnames(landmarks)[[3]][i], ][j,2] + circle.coords[,2])), 1]))
        calibration.array[j,2,i] <-  mean(diag(buffered.image[(calib.file[calib.file$IMAGE == dimnames(landmarks)[[3]][i], ][j,1] + circle.coords[,1] + px.radius), (px.radius + (calib.file[calib.file$IMAGE == dimnames(landmarks)[[3]][i], ][j,2] + circle.coords[,2])), 2]))
        calibration.array[j,3,i] <-  mean(diag(buffered.image[(calib.file[calib.file$IMAGE == dimnames(landmarks)[[3]][i], ][j,1] + circle.coords[,1] + px.radius), (px.radius + (calib.file[calib.file$IMAGE == dimnames(landmarks)[[3]][i], ][j,2] + circle.coords[,2])), 3]))
      }
    }

    if(i == 1){
      end.time <- as.numeric(Sys.time())
      iteration.time <- abs(start.time - end.time)
      estimated.time <- (iteration.time * length(image.files)) / 60
    }

    cat(paste0("Processed ", image.name, ": ", round((i/dim(landmarks)[3]) * 100, digits = 2), "% done. \n Estimated time remaining: ", round(abs((iteration.time * i)/60 - estimated.time), digits = 1), "minutes"))

  } #end i

  if(is.null(calib.file) == F){
    #currently assumes the calibration data are landmarks on an RGB color standard.
    calib.means <- array.mean(calibration.array[,,1:3])
    col.change <- calib.means
    for(j in 1:3){ #dim(col.change)[3]){
      col.change <- calibration.array[,,j] - calib.means
      #substract away RGB deviation for each color
      calibrated.array[,1,j] <- sampled.array[,1,j] - mean(col.change[1,1])
      calibrated.array[,2,j] <- sampled.array[,2,j] - mean(col.change[2,2])
      calibrated.array[,3,j] <- sampled.array[,3,j] - mean(col.change[3,3])
    }
    dimnames(calibrated.array)[[3]] <- dimnames(landmarks)[[3]]
  } else {calibrated.array <- NULL}

  mesh.colors <- list(sampled.color = sampled.array, delaunay = delaunay.template, calibrated = calibrated.array, imagedir = imagedir, image.names = dimnames(landmarks)[[3]])

  class(mesh.colors) <- "mesh.colors"
  return(mesh.colors)
}
