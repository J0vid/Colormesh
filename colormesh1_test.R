#read in RAW images

# library(hexView)
# raw_image <- readRaw("~/Downloads/IMG_7632.CR2")
# str(raw_image)
#
# image_matrix <- matrix(raw_image$fileRaw, nrow = 4368, ncol = 2912, byrow = T)


#colormesh 1.0 test
library(Colormesh)
library(imager)

specimen_factors <- read.csv("~/R_packages/Colormesh/inst/extdata/specimen_factors.csv", header = F)
calib.file <- tps2array("~/R_packages/Colormesh/inst/extdata/calib_LM_coords.TPS")
cons <- tps2array("~/R_packages/Colormesh/inst/extdata/consensus_LM_coords.TPS")
test.image <- load.image("~/R_packages/Colormesh/inst/extdata/GPHP_unw_001.jpg")
delaunay.map <- tri.surf(cons, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)

plot(delaunay.map, style = "overlay", corresponding.image = test.image)
plot(delaunay.map, corresponding.image = test.image, style = "triangulation")
#what should we do with these points?
point.overlap(delaunay.map = delaunay.map, px.radius = 10)

#do I need to flip my delaunay map to match the image?
# test.image <- load.image("~/R_packages/Colormesh/inst/extdata/GPHP_unw_001.jpg")
# dev.off()
# plot(test.image)
# points(delaunay.map$interior[,1], delaunay.map$interior[,2], col = 2)
#
# points(delaunay.map$interior[,1], -delaunay.map$interior[,2] + dim(test.image)[2], col = 2)

rgb.test <- rgb.measure(imagedir = "~/R_packages/Colormesh/inst/extdata/", image.names = specimen_factors$V2, delaunay.map = delaunay.map, linearize.color.space = F)

plot(rgb.test, individual = 5)
plot(rgb.test, individual = 5, visualization_type = "comparison")

individual=1
image.files <- list.files(rgb.test$imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP")
tmp.image <- load.image(paste0(rgb.test$imagedir, image.files[grepl(rgb.test$image.names[individual], image.files)]))
plot(tmp.image)
points(rgb.test$delaunay$interior, col = rgb(rgb.test$sampled.color[,,individual]), pch = 19)

#Calibrate
# debug(rgb.calibrate)
test.image <- load.image("~/R_packages/Colormesh/inst/extdata/GPHP_001.jpg")
dev.off()

#plot calibration image function

plot(test.image)
points(calib.file[,1,1], -calib.file[,2,1] + dim(test.image)[2], col = 2)

#brightness correction
rgb.cal <- rgb.calibrate(rgb.test, imagedir =  "~/R_packages/Colormesh/inst/extdata/", image.names = specimen_factors$V1, calib.file = calib.file, flip.y.values = T)

plot(rgb.cal, individual = 7, visualization_type = "diagnostic")

#calibration with known color standard values
library(readr)
known_RGB <- t(read_csv("inst/extdata/known_RGB.csv",
                      col_names = FALSE))


#flip calibration in the code by default!
rgb.cal <- rgb.calibrate(rgb.test, imagedir =  "~/R_packages/Colormesh/inst/extdata/", image.names = specimen_factors$V1, calib.file = calib.file, flip.y.values = T, color.standard.values = known_RGB)

plot(rgb.cal, individual = 3)

#combine dataset
final.df <- make.colormesh.dataset(calibrated.data = rgb.cal, specimen.factors = specimen_factors, use.perimeter.data = T)

#things to add:

# 1) linearization in both sampling and calibration steps as a logical toggle
# 2) if a tif | png | jpeg , print a warning that we recommend linearization. another option is to output both non-linear sampled and linearized sample
# 3) remove overlapping delaunay points function
# 4) flip delaunay function (documentation needs to be very clear! plot your image, make sure it lines up )
# 5) tell people to load an example image so that we get dimensions to work with throughout.





#colormesh jenn test####
library(Colormesh)
# library(imager)

specimen_factors <- read.csv("~/Downloads/Colormesh_test_files/specimen_factors.csv", header = F)
calib.file <- tps2array("~/Downloads/Colormesh_test_files/calib_images/calib_LM_coords.TPS")
cons <- tps2array("~/Downloads/Colormesh_test_files/consensus_LM_coords.TPS")
test.image <- load.image("~/Downloads/Colormesh_test_files/unwarped_images/TUHPAM02_3018_un.TIF")
delaunay.map <- tri.surf(cons, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)

plot(delaunay.map, style = "overlay", corresponding.image = test.image)
plot(delaunay.map, corresponding.image = test.image, style = "triangulation")
#what should we do with these points?
point.overlap(delaunay.map = delaunay.map, px.radius = 10)

#do I need to flip my delaunay map to match the image?
# test.image <- load.image("~/R_packages/Colormesh/inst/extdata/GPHP_unw_001.jpg")
# dev.off()
# plot(test.image)
# points(delaunay.map$interior[,1], delaunay.map$interior[,2], col = 2)
#
# points(delaunay.map$interior[,1], -delaunay.map$interior[,2] + dim(test.image)[2], col = 2)

rgb.test <- rgb.measure(imagedir = "~/Downloads/Colormesh_test_files/unwarped_images/", image.names = specimen_factors$V2, delaunay.map = delaunay.map, linearize.color.space = T)

plot(rgb.test, individual = 5)
plot(rgb.test, individual = 5, style = "comparison")
plot(rgb.test, individual = 5, style = "points")

individual=1
image.files <- list.files(rgb.test$imagedir, pattern = "*.JPG|*.jpg|*.TIF|*.tif|*.png|*.PNG|*.bmp|*.BMP")
tmp.image <- load.image(paste0(rgb.test$imagedir, image.files[grepl(rgb.test$image.names[individual], image.files)]))
plot(tmp.image)
points(rgb.test$delaunay$interior, col = rgb(rgb.test$sampled.color[,,individual]), pch = 19)

#Calibrate
# debug(rgb.calibrate)
test.image <- load.image("~/Downloads/Colormesh_test_files/calib_images/TUHPAM02_3.TIF")
dev.off()

#plot calibration image function
calib.plot(imagedir = "~/Downloads/Colormesh_test_files/calib_images/", image.names = specimen_factors$V1, calib.file = calib.file)

#brightness correction
rgb.cal <- rgb.calibrate(rgb.test, imagedir =  "~/Downloads/Colormesh_test_files/calib_images/", image.names = specimen_factors$V1, calib.file = calib.file, flip.y.values = F)

plot(rgb.cal, individual = 7, style = "diagnostic")

#calibration with known color standard values
library(readr)
known_RGB <- t(read_csv("~/Downloads/Colormesh_test_files/known_RGB.csv",
                        col_names = FALSE))


#flip calibration in the code by default!
rgb.cal <- rgb.calibrate(rgb.test, imagedir =  "~/Downloads/Colormesh_test_files/calib_images/", image.names = specimen_factors$V1, calib.file = calib.file, flip.y.values = F, color.standard.values = known_RGB)

plot(rgb.cal, individual = 10, style = "comparison")

#combine dataset
final.df <- make.colormesh.dataset(calibrated.data = rgb.cal, specimen.factors = specimen_factors, use.perimeter.data = T)

#things to add:
# 1) plotting methods points need to be correct points & perimeter: done
# 2) calib.plot needs to find corresponding image: done
# 3) calibration fails when colors are linearized and color standard is provided: done
# 4) plotting calibrated mesh "diagnostic" needs to be called comparison: done
# 5) Get means for a group
# 6) plot differences in RGB and Brightness
# 7) gradient of brightness
# 8) make.colormesh.dataset work with mesh.colors class: done

