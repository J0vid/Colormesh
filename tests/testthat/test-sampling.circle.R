test_that("sampling circle works", {
  #specified radius should match range
  expect_equal(max(range(sampling.circle(2))), 2)
  #test the catch for radius of 1
  expect_equal(sum(sampling.circle(1)), 0)
  #zero should give the same result as 1
  expect_equal(sampling.circle(1), sampling.circle(0))
})
