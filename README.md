# Colormesh
An R package for analyzing color patterns in images

## Installation

I strongly recommend you build the included vignette when installing the package. It shows a quick workflow with 3 images for example and should take about a minute to build. Here's how to install the package with the vignette:

```r
devtools::install_github("j0vid/Colormesh", build_vignettes = T)
```

and here's how to view the vignette:

```r
vignette("Guppy-images”)
```

## Using Colormesh

This package requires at least 2 things to process your data:
1. A landmark set. We provide functions for reading in tpsDig files (```r read.tps()```), as well as converting them to an array (```r tps2array()```). Other formats can be read from geomorph or Morpho.
2. A corresponding set of images. Images are loaded by looking at the names of your landmark data, so when you make an array be sure that its dimnames match the image names. With those two things, you can generate a set of warped images to the landmark consensus shape using ```r tps.unwarp()```. 

## tps.unwarp()

```r tps.unwarp()``` is the main funcion for processing your data. It does the image warping, and it can also do color sampling and calibration. To better understand how this works, let's walk through the process. 

### Image warping

Image warping is done for each image to the average shape. Here's what it looks like:

![Registration example](images/registration_example.png)

### Color sampling

Instead of using every pixel of the registered images as an individual measurement/trait, we generate a mesh overlay using Delaunay triangulation. We wrote a function that uses the centroids of the triangles from a triangulation as new points for successive rounds of triangulation (see ```r tri.surf()```). Here's what it looks like:

![Triangulation example](images/DT.png)

If you would like to sample color from your images with Delaunay triangulation, you will need a point map. A point map is a vector that specifies the order of your landmarks. If your landmarks are in order around the perimeter of the object, we can generate a sampling mesh with ```r tri.surf()```. 

If you look at the image below, you'll see that we collected 7 initial landmarks on our guppy, and then an additional 55 semi-landmarks around the outline.

Thus, our point map to make a continuous perimeter looks like this: ```r gup.map <- c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62)```

![Outline example](images/outline.png)

We sample color at each of these interior points. We do so by averaging color information around the local neighborhood of each of these points. You can see that with enough sampling points, you start to approximate the original image without as many pixels.

### Color calibration

Color information across images can be pretty noisy due to inconsistent lighting, different camera settings, movement of the object, etc. We highly recommend adjusting for those differences by including a color standard in each image. We can use the differences in color standard values between images to try and mitigate variation due to noise and better measure the traits you're interested in. I wrote a vignette just for this step because it's crucial and our method is a bit rigid at the moment (see ```r vignette("Calibrate-images")```). I'm open to any suggestions for streamlining this part of the data processing.  



