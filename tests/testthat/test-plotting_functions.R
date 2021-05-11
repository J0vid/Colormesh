test_that("plotting method works", {
  #covariate data and consensus lms
  specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)
  consensus <- tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))
  test.image <- image_reader("../../inst/extdata/unwarped_images/", "GPLP_unw_001.jpg")
  delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)

  rgb.test <- rgb.measure(imagedir = "../../inst/extdata/unwarped_images/", image.names = specimen.factors[1:2,2], delaunay.map = delaunay.map, linearize.color.space = F)

  plot(delaunay.map, style = "interior")
  plot(delaunay.map, style = "points")
  plot(delaunay.map, style = "perimeter")
  plot(delaunay.map, style = "triangulation")
  plot(delaunay.map, style = "overlay", corresponding.image = test.image)

  plot(rgb.test, individual = 2)
  plot(rgb.test, individual = 2, style = "perimeter")
  plot(rgb.test, individual = 2, style = "points")
  plot(rgb.test, individual = 2, style = "comparison")

  #test calibrated data plotting
  # calib.file <- tps2array(system.file("extdata", "calib_LM_coords.TPS", package = "Colormesh"))
  # calibration.test <- rgb.calibrate(rgb.test, imagedir = "../../inst/extdata/original_images/", image.names = specimen.factors[,1], calib.file = calib.file)
  #
  # plot(calibration.test, individual = 2)
  # plot(calibration.test, individual = 2, style = "perimeter")
  # plot(calibration.test, individual = 2, style = "points")
  # plot(calibration.test, individual = 2, style = "differences")
  # plot(calibration.test, individual = 2, style = "comparison")


})
