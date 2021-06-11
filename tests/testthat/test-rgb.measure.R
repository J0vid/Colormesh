test_that("rgb.measure works, both linear and not", {
  #covariate data and consensus lms
  specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)
  consensus <- tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))
  test.image <- image_reader("../../inst/extdata/unwarped_images/", "GPLP_unw_001.jpg")
  delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)

  rgb.test <- rgb.measure(imagedir = "../../inst/extdata/unwarped_images/", image.names = specimen.factors[,2], delaunay.map = delaunay.map, linearize.color.space = F)
  #is the class right
  expect_equal(class(rgb.test), "mesh.colors")
  #test that linearization actually works
  linear.rgb.test <- rgb.measure(imagedir = "../../inst/extdata/unwarped_images/", image.names = specimen.factors[,2], delaunay.map = delaunay.map, linearize.color.space = T)
  expect_equal(linear.rgb.test$linearized, T)

  #still need to test the offset for raw images

})
