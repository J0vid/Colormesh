#read in RAW images

library(hexView)
raw_image <- readRaw("~/Downloads/IMG_7632.CR2")
str(raw_image)

image_matrix <- matrix(raw_image$fileRaw, nrow = 4368, ncol = 2912, byrow = T)






#colormesh 1.0 test
library(imager)
library(Colormesh)
specimen_factors <- read.csv("~/R_packages/Colormesh/inst/extdata/specimen_factors.csv", header = F)
calib.file <- read.tps("~/R_packages/Colormesh/inst/extdata/calib_LM_coords.TPS")
cons <- read.tps("~/R_packages/Colormesh/inst/extdata/consensus_LM_coords.TPS")

delaunay.map <- tri.surf(tps2array(cons)[,,1], point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3)

#what should we do with these points?
point.overlap(delaunay.map = delaunay.map, px.radius = 2)

#do I need to flip my delaunay map to match the image?
test.image <- load.image("~/R_packages/Colormesh/inst/extdata/GPHP_unw_001.jpg")
dev.off()
plot(test.image)
points(delaunay.map$interior[,1], -delaunay.map$interior[,2] + dim(test.image)[2], col = 2)

rgb.test <- rgb.measure(imagedir = "~/R_packages/Colormesh/inst/extdata/", image.names = specimen_factors$V2, delaunay.map = delaunay.map)

plot(rgb.test, individual = 5)

#Calibrate
# debug(rgb.calibrate)
rgb.cal <- rgb.calibrate(rgb.test, imagedir =  "~/R_packages/Colormesh/inst/extdata/", image.names = specimen_factors$V1, calib.file = calib.file)

plot(rgb.cal, individual = 10, visualization_type = "diagnostic")






