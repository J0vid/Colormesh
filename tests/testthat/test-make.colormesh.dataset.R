test_that("dataset is made correctly", {
  #covariate data and consensus lms
  specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)
  consensus <- tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))
  test.image <- image_reader("../../inst/extdata/unwarped_images/", "GPLP_unw_001.jpg")
  delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)

  rgb.test <- rgb.measure(imagedir = "../../inst/extdata/unwarped_images/", image.names = specimen.factors[,2], delaunay.map = delaunay.map, linearize.color.space = F)
  cm.dataset <- make.colormesh.dataset(rgb.test, specimen.factors)

  #dims for the simple example should be metadata + colors + landmarks
  expect_equal(dim(cm.dataset)[2], dim(rgb.test$sampled.color)[1] * 3 + nrow(rgb.test$delaunay.map$interior) *2 + ncol(specimen.factors))

  cm.dataset <- make.colormesh.dataset(rgb.test, specimen.factors, use.perimeter.data = T, write2csv = "test.csv")
  #dims for the perim example should be metadata + colors + landmarks
  expect_equal(dim(cm.dataset)[2], dim(rgb.test$sampled.color)[1] * 3 + nrow(rgb.test$delaunay.map$interior) *2 + ncol(specimen.factors) + dim(rgb.test$sampled.perimeter)[1] * 3 + nrow(rgb.test$delaunay.map$perimeter) * 2)

  #write calibrated file
  calib.file <- tps2array(system.file("extdata", "calib_LM_coords.TPS", package = "Colormesh"))
  calibration.test <- rgb.calibrate(rgb.test, imagedir = "../../inst/extdata/original_images/", image.names = specimen.factors[,1], calib.file = calib.file)
  cm.dataset <- make.colormesh.dataset(calibration.test, specimen.factors, use.perimeter.data = T)
})
