test_that("lm flipper works", {
  guppy.lms <- tps2array(system.file("extdata", "original_lms.TPS", package = "Colormesh"))
  flip.test <- flip.lms(landmarks = guppy.lms, imagedir = "../../inst/extdata/cropped_images/", side_data = c("right", rep("left", 9)))
  did.it.flip <- flip.test[1,1,1] < guppy.lms[1,1,1]
  expect_equal(did.it.flip, T)
})
