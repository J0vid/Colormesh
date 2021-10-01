#' Color sampling from a set of pre-warped images
#' @import imager
#' @param imagedir directory of images to measure. Only images with landmarks will be processed. The landmark file names are assumed to exactly match the image names.
#' @param image.names A vector of image names to look for in imagedir. These images should be unwarped or deformed to a common reference shape.
#' @param delaunay.map delaunay triangulation object
#' @param px.radius The size of the circular neighborhood (in pixels) to sample color around each triangulated point.
#' @param linearize.color.space should the sampled color data be transformed into linear color space
#' @return The function will return $sampled.color-- an N_points x 3 (RGB) x N_observations array of sampled color values. A tri.surf.points class object will also be returned as $delaunay.
#' @examples
#' #covariate data and consensus lms
#' specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)
#' consensus <- tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))
#' test.image <- image_reader(paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), "GPLP_unw_001.jpg")
#' delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)
#'
#' rgb.test <- rgb.measure(imagedir = paste0(path.package("Colormesh"),"/extdata/unwarped_images/"), image.names = specimen.factors[,2], delaunay.map = delaunay.map, linearize.color.space = F)
#'
#' plot(rgb.test, individual = 5)
#' plot(rgb.test, individual = 5, style = "comparison")
#'
#' @export
rgb.measure <- function(imagedir, image.names, delaunay.map, px.radius = 2, linearize.color.space = F){

  # imagedir <- "Guppies/EVERYTHING/righties/"
  image.files <- list.files(imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP|*.cr2|*.nef|*.orf|*.crw")
  image.files.san.ext <- tools::file_path_sans_ext(image.files)
  image.names <- tools::file_path_sans_ext(image.names)
  if(length(image.files) > 0) print("The provided image format is assumed to be in sRGB colorspace. If you would like to linearize these values and apply the standard linear transform (based on international standard IEC 61966-2-1:1999), set linearize.color.space to T.")

  start.time <- as.numeric(Sys.time())


    #triangulate
    delaunay.template <- delaunay.map #tri.surf(mean.lm, point.map, 4)
    # sampled.r <- sampled.g <- sampled.b <- matrix(0, ncol = nrow(delaunay.template$interior), nrow = dim(landmarks)[3])
    # if(is.null(calib.file) == F) calibration.array <- array(NA, dim = c(sum(as.numeric(calib.file$ID) == 1), 3, dim(landmarks)[3]))
    sampled.array <- array(NA, dim = c(nrow(delaunay.template$interior), 3, length(image.names)))
    sampled.array.perimeter <- array(NA, dim = c(nrow(delaunay.template$perimeter), 3, length(image.names)))
    # calibrated.array <- sampled.array
    circle.coords <- sampling.circle(px.radius)


  for(i in 1:length(image.names)){
    #the issue with the old approach is that we need to get the lm names from somewhere and it's no longer from the TPS readin
    #it has to be from coords
    # tmp.image <- load.image(paste0(imagedir, image.files[grepl(image.names[i], image.files)]))

    tmp.image <- image_reader(imagedir, image.files[image.files.san.ext == image.names[i]])
    img.dim <- dim(tmp.image)
    # orig.lms <- cbind(abs(landmarks[,1,i] - img.dim[1]), abs(landmarks[,2,i]- img.dim[2]))


    #match up delaunay points to image by flipping Y axis on image dimensions
      translated.interior <-  cbind(delaunay.template$interior[,1], delaunay.template$interior[,2])
      translated.perimeter <- cbind(delaunay.template$perimeter[,1], delaunay.template$perimeter[,2])

      #add offset if image was originally RAW format
      supported.raw.formats <- c("cr2","nef","orf","crw","CR2")
      tmp.name <- image.files[grepl(image.names[i], image.files)]

      if(substr(tmp.name, nchar(tmp.name) - 2, nchar(tmp.name)) %in% supported.raw.formats){
      off.y <- min(which(rowMeans(tmp.image) < 1))
      off.x <- min(which(colMeans(tmp.image) < 1))

      translated.interior <-  cbind(delaunay.template$interior[,1] + off.y, delaunay.template$interior[,2] - off.x)
      translated.perimeter <- cbind(delaunay.template$perimeter[,1] + off.y, delaunay.template$perimeter[,2] - off.x)

      }

      #add buffer to image so we don't ask for pixels that don't exist
      if(px.radius < 2){
        buffered.image <- array(0, dim = c(dim(tmp.image)[1]+ 2*1,dim(tmp.image)[2]+ 2*1, 3))
        buffered.image[(px.radius):(dim(tmp.image)[1]+(1-1)),(1+1):(dim(tmp.image)[2]+(1)),] <- tmp.image

        for(j in 1:length(translated.interior[,1])){
          sampled.array[j,1,i] <-  buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius,(px.radius + (translated.interior[j,2] + circle.coords[,2])), 1]
          sampled.array[j,2,i] <-  buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.interior[j,2] + circle.coords[,2])), 2]
          sampled.array[j,3,i] <-  buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.interior[j,2] + circle.coords[,2])), 3]

          if(j <= nrow(translated.perimeter)){
            sampled.array.perimeter[j,1,i] <-  buffered.image[(translated.perimeter[j,1] + circle.coords[,1]) + px.radius,(px.radius + (translated.perimeter[j,2] + circle.coords[,2])), 1]
            sampled.array.perimeter[j,2,i] <-  buffered.image[(translated.perimeter[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.perimeter[j,2] + circle.coords[,2])), 2]
            sampled.array.perimeter[j,3,i] <-  buffered.image[(translated.perimeter[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.perimeter[j,2] + circle.coords[,2])), 3]
          }
        }

      } else{
        buffered.image <- array(0, dim = c(dim(tmp.image)[1]+ 2*px.radius,dim(tmp.image)[2]+ 2*px.radius, 3))
        buffered.image[(px.radius):(dim(tmp.image)[1]+(px.radius-1)),(px.radius+1):(dim(tmp.image)[2]+(px.radius)),] <- tmp.image

        for(j in 1:length(translated.interior[,1])){
          sampled.array[j,1,i] <-  mean(diag(buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius,(px.radius + (translated.interior[j,2] + circle.coords[,2])), 1]))
          sampled.array[j,2,i] <-  mean(diag(buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.interior[j,2] + circle.coords[,2])), 2]))
          sampled.array[j,3,i] <-  mean(diag(buffered.image[(translated.interior[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.interior[j,2] + circle.coords[,2])), 3]))

          if(j <= nrow(translated.perimeter)){
            sampled.array.perimeter[j,1,i] <-  mean(diag(buffered.image[(translated.perimeter[j,1] + circle.coords[,1]) + px.radius,(px.radius + (translated.perimeter[j,2] + circle.coords[,2])), 1]))
            sampled.array.perimeter[j,2,i] <-  mean(diag(buffered.image[(translated.perimeter[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.perimeter[j,2] + circle.coords[,2])), 2]))
            sampled.array.perimeter[j,3,i] <-  mean(diag(buffered.image[(translated.perimeter[j,1] + circle.coords[,1]) + px.radius, (px.radius + (translated.perimeter[j,2] + circle.coords[,2])), 3]))
          }
        }


      }

      dimnames(sampled.array)[[3]] <- image.names
      dimnames(sampled.array.perimeter)[[3]] <- image.names

    if(i == 1){
      end.time <- as.numeric(Sys.time())
      iteration.time <- abs(start.time - end.time)
      estimated.time <- (iteration.time * length(image.files)) / 60
    }

    cat(paste0("Processed ", image.names[i], ": ", round((i/length(image.names)) * 100, digits = 2), "% done. \n Estimated time remaining: ", round(abs((iteration.time * i)/60 - estimated.time), digits = 1), " minutes \n"))

  } #end i

    #linearize sampling array
    if(linearize.color.space){
      sampled.array <- linearize.colors(sampled.array)
      sampled.array.perimeter <- linearize.colors(sampled.array.perimeter)
    }

  mesh.colors <- list(sampled.color = sampled.array, delaunay.map = delaunay.map, linearized = if(linearize.color.space){T}else{F}, imagedir = imagedir, image.names = image.names, sampled.perimeter = sampled.array.perimeter)

  class(mesh.colors) <- "mesh.colors"
  return(mesh.colors)
}

