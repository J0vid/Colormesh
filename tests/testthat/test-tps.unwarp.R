test_that("unwarping works with mean estimation", {
  #load landmarks and covariate data
  guppy.lms <- tps2array(system.file("extdata", "original_lms.TPS", package = "Colormesh"))
  specimen.factors <- read.csv(system.file("extdata", "specimen_factors.csv", package = "Colormesh"), header = F)

  #define sliders for guppy data
  sliders <- make.sliders(c(1,8:17, 2, 18:19, 3, 20:27, 4, 28:42, 5, 43:52, 6, 53:54, 7, 55:62), main.lms = 1:7)

  #unwarp images--change writedir if you want to see the images!
  example.sample <- tps.unwarp(imagedir = "../../inst/extdata/cropped_images/", landmarks = guppy.lms, image.names = specimen.factors[,1], sliders = sliders, write.dir = tempdir())

  #test mean
  expect_equal(nrow(example.sample$target), 62)
  #test image.names list
  expect_equal(length(example.sample$unwarped.names), nrow(specimen.factors))

  expect_error(example.sample <- tps.unwarp(imagedir = "../../inst/extdata/cropped_images/", landmarks = guppy.lms, image.names = specimen.factors[,1], sliders = sliders), "Please provide a folder to save images to by using the write.dir parameter.")
  expect_error(example.sample <- tps.unwarp(imagedir = "../../inst/extdata/cropped_images/", landmarks = guppy.lms, image.names = specimen.factors[,1], sliders = sliders, write.dir = "../../inst/extdata/cropped_images/"), "Please write the unwarped images to a different path, so your original data don't get overwritten!")

})
