test_that("overlapping plot works", {
  #create delaunay map
  consensus <- tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))
  test.image <- image_reader("../../inst/extdata/unwarped_images/", "GPLP_unw_001.jpg")
  delaunay.map <- tri.surf(consensus, point.map = c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62), 3, test.image)

  #points shouldn't be this close
  expect_equal(nrow(point.overlap(delaunay.map, 1)$close.points), 0)
  #12 points should be within 2 px
  expect_equal(nrow(point.overlap(delaunay.map, 2)$close.points), 12)

  #test triangulation style
  point.overlap(delaunay.map, 2, style = "triangulation")

})
