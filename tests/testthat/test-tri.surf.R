test_that("triangulation works", {
  consensus <- tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))
  test.image <- image_reader("../../inst/extdata/unwarped_images/", "GPLP_unw_001.jpg")
  delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)
  expect_equal(class(delaunay.map), "tri.surf.points")
  #flip test
  delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image, flip.delaunay = T)

  #duplicated lm warning
  expect_warning(tri.surf(rbind(consensus[,,1],consensus[1,,1]), point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image))

  #array warning
  guppy.lms <- tps2array(system.file("extdata", "original_lms.TPS", package = "Colormesh"))
  expect_warning(tri.surf(guppy.lms, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image))


})
