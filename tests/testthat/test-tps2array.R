test_that("TPS file imports correct number of lms", {
  expect_equal(nrow(tps2array(system.file("extdata", "consensus_LM_coords.TPS", package = "Colormesh"))), 62)
})
