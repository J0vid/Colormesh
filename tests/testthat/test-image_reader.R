test_that("Image reads succesfully", {

  expect_equal(class(image_reader("../../inst/extdata/unwarped_images/", "GPLP_unw_001.jpg"))[1], "cimg")

})
