#' Non-linear image registration using TPS deformation.
#'
#' @importFrom sp point.in.polygon
#' @importFrom tripack tri.mesh
#' @param imagedir directory of images to deform. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param landmarks A landmark array with dimensions N_landmarks x 2 x N_observations. dimnames(landmarks)[[3]] should have the corresponding image filenames for each observation.
#' @param image.names A vector of image names to look for in imagedir. These images should be unwarped or deformed to a common reference shape.
#' @param write.dir Where to save warped images. Images will be named after the original image name (is that a bad idea because of overwriting? We will find out).
#' @return warped images will be saved to the write.dir directory.
#' @examples
#' #load landmarks and covariate data
#' guppy.lms <- tps2array(system.file("extdata", "original_lms.TPS", package = "Colormesh"))
#' specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)
#'
#'  #unwarp images
#' example.sample <- tps.unwarp(imagedir = paste0(path.package("Colormesh"),"/extdata/cropped_images/"), landmarks = guppy.lms, image.names = specimen.factors[,1], write.dir = tempdir())
#' @export
tps.unwarp <- function(imagedir, landmarks, image.names, write.dir = NULL){

  require(sp)
  require(tripack)

  if(is.null(write.dir)) stop("Please provide a folder to save images to by using the write.dir parameter. Alternatively, don't save images by making write.images = FALSE.")

  if(imagedir == write.dir) stop("Please write the warped images to a different path, so your original data don't get overwritten!")

  suppressMessages(mean.lm <- Morpho::procSym(landmarks, scale = F, CSinit = F)$mshape)

  # imagedir <- "Guppies/EVERYTHING/righties/"
  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.tiff|*.PNG|*.png")
  start.time <- as.numeric(Sys.time())

  for(i in 1:length(image.files)){
    # tmp.image <- load.image(paste0(imagedir, image.files[image.files == dimnames(landmarks)[[3]][i]]))
    tmp.image <- load.image(paste0(imagedir, image.files[grepl(image.names[i], image.files)]))
    img.dim <- dim(tmp.image)
    # orig.lms <- cbind(abs(landmarks[,1,i] - img.dim[1]), abs(landmarks[,2,i]- img.dim[2]))
    orig.lms <- cbind((landmarks[,1,grepl(image.names[i], dimnames(landmarks)[[3]])]), abs(landmarks[,2,grepl(image.names[i], dimnames(landmarks)[[3]])]- img.dim[2]))
    tar.lms <- cbind(mean.lm[,1] + img.dim[1]/2, mean.lm[,2] + img.dim[2]/2)

    image_defo <- function(x, y){ #I'm aware that it's terrible practice to use variables out of scope
      xs <- c(0:(img.dim[1] - 1))
      ys <- c(0:(img.dim[2] - 1))
      img.long <- as.matrix(expand.grid(xs, ys))
      img.long <- Morpho::tps3d(img.long, tar.lms, orig.lms, threads = 0)
      return(list(x= img.long[,1], y = img.long[,2]))
    }

    # imwarp(tmp.image,map=image_defo,direction="reverse") %>% plot()
    # points(orig.lms , col = 2)
    # points(tar.lms, col = 3)


    tmp.warp <- imwarp(tmp.image, map = image_defo, direction = "reverse")
    # image.name <- substr(dimnames(landmarks)[[3]][i], 1, nchar(as.character(dimnames(landmarks)[[3]][i])) - 4)

    #should I create a directory in the current working directory if write.dir is not provided? dir.create("warped_images")
    imager::save.image(tmp.warp, file = paste0(write.dir, image.names[i],"_unwarped.png"))

    if(i == 1){
      end.time <- as.numeric(Sys.time())
      iteration.time <- abs(start.time - end.time)
      estimated.time <- (iteration.time * length(image.files)) / 60
    }

    cat(paste0("Processed ", image.names[i], ": ", round((i/dim(landmarks)[3]) * 100, digits = 2), "% done. \n Estimated time remaining: ", round(abs((iteration.time * i)/60 - estimated.time), digits = 1), "minutes \n"))

  } #end i
return(tar.lms)
}
