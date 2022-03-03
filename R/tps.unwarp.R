#' Non-linear image registration using TPS deformation.
#' @importFrom Morpho tps3d procSym
#' @importFrom geomorph gpagen
#' @importFrom sp point.in.polygon
#' @importFrom tripack tri.mesh
#' @param imagedir Directory of images to deform. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param landmarks A landmark array with dimensions N_landmarks x 2 x N_observations. dimnames(landmarks)[[3]] should have the corresponding image filenames for each observation.
#' @param image.names A vector of image names to look for in imagedir. These images should be unwarped or deformed to a common reference shape.
#' @param write.dir Where to save warped images. Images will be named after the original image name (is that a bad idea because of overwriting? We will find out).
#' @param sliders An index of sliding semilandmarks for calculating the mean landmark shape.
#' @param target Supply a target shape to warp to. The default is the mean shape. The target will be placed in the center of the image for unwarping.
#' @return warped images will be saved to the write.dir directory. We also return the consensus shape of the landmarks. This can be used for delaunay triangulation. Finally, we return the unwarped image names.
#' @examples
#' #load landmarks and covariate data
#' guppy.lms <- tps2array(system.file("extdata", "original_lms.TPS", package = "Colormesh"))
#' specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)
#'
#' #define sliders for guppy data
#' sliders <- make.sliders(c(1,8:17, 2, 18:19, 3, 20:27, 4, 28:42, 5, 43:52, 6, 53:54, 7, 55:62), main.lms = 1:7)
#'
#' #unwarp images--change writedir if you want to see the images!
#' example.sample <- tps.unwarp(imagedir = paste0(path.package("Colormesh"),"/extdata/cropped_images/"), landmarks = guppy.lms, image.names = specimen.factors[,1], sliders = sliders, write.dir = tempdir())
#' @export
tps.unwarp <- function(imagedir, landmarks, image.names, write.dir = NULL, sliders = NULL, target = NULL){

  if(is.null(write.dir)) stop("Please provide a folder to save images to by using the write.dir parameter.")

  if(imagedir == write.dir) stop("Please write the unwarped images to a different path, so your original data don't get overwritten!")

  # suppressMessages(mean.lm <- Morpho::procSym(landmarks, scale = F, CSinit = F)$mshape)
  suppressMessages({
    tmp.reg <- geomorph::gpagen(landmarks, curves = sliders, print.progress = F)
    mean.lm <- tmp.reg$consensus * mean(tmp.reg$Csize)
    })


  # imagedir <- "Guppies/EVERYTHING/righties/"
  image.files <- list.files(imagedir, pattern = "*\\.JPG|*\\.jpg|*\\.TIF|*\\.tif|*\\.TIFF|*\\.tif|*\\.png|*\\.PNG|*\\.bmp|*\\.BMP|*\\.cr2|*\\.CR2|*\\.nef|*\\.orf|*\\.crw")
  image.files.san.ext <- tools::file_path_sans_ext(image.files)
  image.names <- tools::file_path_sans_ext(image.names)
  dimnames(landmarks)[[3]] <- tools::file_path_sans_ext(dimnames(landmarks)[[3]])

  not.in.dir <- NULL
  not.in.tps <- NULL

  start.time <- as.numeric(Sys.time())

  for(i in 1:length(image.names)){
    #check if image.name[i] has a corresponding image in the folder and an entry in the lm file. If not, save a record and skip
    if(sum(image.files.san.ext == image.names[i]) > 0 & sum(dimnames(landmarks)[[3]] == image.names[i]) > 0){
    # tmp.image <- load.image(paste0(imagedir, image.files[image.files == dimnames(landmarks)[[3]][i]]))
    # tmp.image <- load.image(paste0(imagedir, image.files[grepl(image.names[i], image.files)]))

    tmp.image <- image_reader(imagedir, image.files[image.files.san.ext == image.names[i]])
    img.dim <- dim(tmp.image)
    # orig.lms <- cbind(abs(landmarks[,1,i] - img.dim[1]), abs(landmarks[,2,i]- img.dim[2]))
    # orig.lms <- cbind((landmarks[,1,grepl(image.names[i], dimnames(landmarks)[[3]])]), abs(landmarks[,2,grepl(image.names[i], dimnames(landmarks)[[3]])]- img.dim[2]))
    orig.lms <- cbind((landmarks[,1,dimnames(landmarks)[[3]] == image.names[i]]), abs(landmarks[,2, dimnames(landmarks)[[3]] == image.names[i]]- img.dim[2]))

    if(is.null(target)){
      tar.lms <- cbind(mean.lm[,1] + img.dim[1]/2, mean.lm[,2] + img.dim[2]/2)
      tar.lms[,2] <- abs(tar.lms[,2] - img.dim[2])
    } else {
      tar.lms <- cbind(target[,1] + img.dim[1]/2, target[,2] + img.dim[2]/2)
      #make sure supplied target is correct scale
      if(diff(range(target)) < 5) tar.lms <- tar.lms * mean(tmp.reg$Csize)
      }

    if(is.null(target) == F & nrow(landmarks) != nrow(tar.lms)) stop("The supplied target does not have the same number of landmarks as the data.")

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

    #needs to save as the format it read in as
    imager::save.image(tmp.warp, file = paste0(write.dir, "/", image.names[i],"_unwarped.png"))

    } else {
      if(sum(image.files.san.ext == image.names[i]) == 0){
        print(paste0("Couldn't find ", image.names[i], " in provided folder. Skipping."))
        not.in.dir <- c(not.in.dir, image.names[i])
      }

      if(sum(dimnames(landmarks)[[3]] == image.names[i]) == 0){
        print(paste0("Couldn't find landmarks for ", image.names[i], ". Skipping."))
        not.in.tps <- c(not.in.tps, image.names[i])
      }
    }

    if(i == 1){
      end.time <- as.numeric(Sys.time())
      iteration.time <- abs(start.time - end.time)
      estimated.time <- (iteration.time * length(image.files)) / 60
    }

    cat(paste0("Processed ", image.names[i], ": ", round((i/dim(landmarks)[3]) * 100, digits = 2), "% done. \n Estimated time remaining: ", round(abs((iteration.time * i)/60 - estimated.time), digits = 1), " minutes \n")) #readout % is bugged in cases of missing lms

  } #end i
return(list(target = tar.lms, unwarped.names = paste0(image.names,"_unwarped.png"), not.in.dir = not.in.dir, not.in.tps = not.in.tps)) #Use %in% to give back correct unwarped image name list
}
