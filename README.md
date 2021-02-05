# Colormesh
An R package for extraction of color data from digital images.

## Installation

The following example code will guide you through the process of using Colormesh to extract color from your digital photos. At this time, image processing using geometric morphometric software must take place prior to color extraction with Colormesh. Future versions will include image processing within the Colormesh package. Additionally, Colormesh is capable of extracting color from four image formats: jpeg, tif, bmp, and png. We plan on updating Colormesh to allow for additional image formats to be used, including raw image formats. 

The examples below provide a step-by-step process to extract color from pre-processed images. The instructions below give descriptions of the required files to have prepared prior to using Colormesh. 

# Installing Colormesh from github
```r
devtools::install_github("https://github.com/J0vid/Colormesh")
```

## Using Colormesh (V1.0)

At this time, Colormesh requires that image processing using geometric morphometrics software take place prior to use. The guppy examples provided in the vignette were processed using the TPS Series software by James Rohlf, availble for free at the Stonybrook Morphometrics website (http://www.sbmorphometrics.org/). The TPS software was used for landmark placement and unwarping of images to a consensus shape. The rersulting files described below include TPS files, which contain landmark x,y coordinates, and the resulting unwarped images of each specimen to be sampled by Colormesh. 


# Required files for Colormesh (V1.0)
To prepare images for RGB color data sampling using Delaunay Triangulation, prepare the following folders and files:

  1. A .csv file containing factors that uniquely identify specimen images. This .csv file should omit the row names and column headers. This .csv file will be used as a check to ensure the calibration correction is applied to the appropriate image. The first column MUST be the image name of the original images (prior to unwarping to the consensus shape) used to place landmarks on the color standard; the names of these original images MUST be unique. The second column MUST contain the unique image name of the "unwarped" (to the consensus shape) version of the specimen image. This .csv file must contain at least these two columns and appear in the order described here. Any additional columns containing factors needed for your organization or identification (e.g., population name) can be included after these two columns.
  
  2. A .csv file containing the known RGB values of the colors on the color standard to be used for calibration. They should be on a scale of 0 to 1. Each row is a color on the standard, each column is a color channel; the know R, G, and B values must appear in columns 1, 2, and 3, respectively. If known RGB values are on a scale of 0-255, simply divide by 255 to convert values to the proper scale.
  
  3. A file folder containing: the original images that show the color standard AND the TPS file that was generated by placing landmarks (using geometric morphometric software) on each of the colors of the standard. The image names must match the names that appear in the 1st column of the .csv (#1 above). 

  4. A file containing: the unwarped (to a consensus shape) images of each specimen AND the TPS file containing the coordinates of the landmarks for this consensus shape. The image names must match the name that appear in the 2nd column of the .csv file (#1 above). These images are produced by image processing in a geometric morphometrics program (ex. tpsSuper). Since all images were unwarped to this consensus shape, this TPS will only contain the number of coordinates equal to the number of landmarks placed around your specimen.


## Reading in .csv files
Code below loads in the two .csv files needed to use the Colormesh package to extract color data: 

 1. Using base R, read in the .csv containing the specimen image names and identification information. The first column MUST be 
    the unique image names of the original images that contain the color standard. The second column MUST contain 
    the unique image names of the images that were unwarped to the consensus shape. The remaining columns can 
    contain any other information you may need to identify your specimens.

 2. Using base R, read in the .csv containing the known RGB values for each of the colors on your color standard. The color channel 
    values should be on the scale of 0 to 1; if the are out of 255, simply divide by 255. The columns
    of this csv should be the different colors found on your color standard. Each row should provide the known
    color values the three (RGB) color channels. For example, if you have 5 colors in your color standard, you
    will have 5 columns. The first row of the csv should contain the known RED value for each of the five colors.
    The second row should contain the GREEN color channel values for each of the five colors on the standard. 
    The third row should have the BLUE color channel values for each of the five known colors on the standard. 

```r
specimen.factors = read.csv("C:/Users/jennv/Desktop/Colormesh_Test_2/specimen_factors.csv", header = F) 

known.rgb = read.csv("C:/Users/jennv/Desktop/Colormesh_Test_2/known_RGB.csv", header = F) 
```

## Reading in .TPS files

The function *tps2array* will read in the .TPS file which contains landmark coordinates and converts the information 
   into an array to be used in later functions.

```r
## The code below reads in the coordinates of the consensus specimen shape
consensus.array = tps2array(data= "C:/Users/jennv/Desktop/Colormesh_Test_2/consensus_LM_coords.TPS")

## The code below reads in the TPS file containing the coordinates for landmarks placed on the color standard contained withing the original images. 
calib.array = tps2array("C:/Users/jennv/Desktop/Colormesh_Test_2/calib_images/calib_LM_coords.TPS")
```

## Reading in the perimeter map

The code below tells Colormesh what order to read the landmarks in so that a perimeter is drawn around the 
specimen in a "connect-the-dots" manner. In the guppy example below, the first seven landarks that were placed around the guppy were at traditional landmark locations (easily identifiable between images); the remaining 55 landmarks were interspersed between the traditional landmarks during the image processing. This perimeter map tells Colormesh the order in which to connect the points so a perimeter is drawn.

```r
perimeter.map <- c(1, 8:17, 2, 18:19, 3, 20:27, 4, 28:42,5,43:52, 6, 53:54, 7, 55:62)
```
![](images/perimeter_line_map.png)


# Determining sampling density

Colormesh uses Delaunay triangulation to determine locations to samples color. The first round of Delaunay triangulation uses the landmark coordinates of the consensus shape as the vertices of the triangles. It reads in the landmark coordinates of this consensus based on the order defined in the perimeter.map variable. The function that creates this mesh was designed to provide the user with flexibility in sampling density based on the number of rounds of triangulation specified by the user; more rounds provides a greater density of sampling points. This is accomplished by using the centroids of the triangles created from the first round of Delaunay triangulation as the vertices for subsequent rounds of triangulation. 

Here's what an example of two, three, and four rounds of triangulation looks like:

![Triangulation example](images/DT.png)


# Checking alignment and generating the sampling template

IMPORTANT: Test that your sampling points properly overlay your image. Image readers (e.g., EBImage & imager) place the 0,0 x,y-coordinate in the upper left corner. In contrast, the coordinates in the TPS file place 0,0 in the bottom left corner. Colormesh assumes this to be true. To check this, the code below is used to read in a test image, calculate the sampling template, then plot the Delaunay triangulation wire-frame on top of the image to ensure that you are properly sampling the image. 

## Reading in a test image

To check that Colormesh will be sampling your speciment correctly, first read in one of the unwarped images from your image file.

```r
test.image = load.image("C:/Users/jennv/Desktop/Colormesh_Test_2/unwarped_images/TULPAAM03_1015_un.TIF")
```
![](images/TULPAAM03_1015_un.png)


## Calculating sample location and checking alignment 

The density of sampling points is determined by Colormesh's *tri.surf* function and is an integer defined by the user. The *tri.surf* function identifies the X,Y coordinates of the centroid for each triangle generated by Delaunay triangulation. If more than one round of triangulation is specified by the user, these centroids function as vertices for subsequent rounds of triangulation. At the completion of the user-specified rounds of triangulation, the pixel coordinate for each triangle's centroid is saved as sampling coordinates. 


### Generating the sampling template

The user provides the consensus.array (the x,y coordinates, defined above), perimeter.map (the order in which to read the points, defined above), a numerical value for the number of rounds of Delaunay triangulation to perform, the test.image (defined above), and the logical for flip.delaunay. The alignment check draws a yellow line around the perimeter of your speciment and red circles are plotted at the pixel coordinates that will be sampled. The user provides the consensus.array (the TPS file of the consensus shape that was read in), the perimeter.map (to provide the order of points around the perimeter), an integer to indicate how many rounds of triangulations to perform, the name of tthe test image that was generated, and the logical argument for whether to flip the y-coordinate values. The sampling template will be plotted overlaying the test image to show the user how the images will be sampled. If the orientation of the sampling template needs to be flipped, the flip.delaunay logical will flip the y-coordinates. Be sure your specimen.sampling.template is defined with the correct orientation.

*Note: the circles shown in the alignment check are **not** equal to the size of the sampling circle size.*

```r
## In this example, 3 rounds of Delaunay Triangulation will be performed.
specimen.sampling.template = tri.surf(consensus.array, perimeter.map, 3, test.image, flip.delaunay = FALSE)
```

The images below show the two outcomes of the flip.delaunay logical argument.
When flip.delaunay = FALSE
![](images/test_image_flip_right.png)

```r
## If the sampling template is upside-down, set flip.delaunay = TRUE
specimen.sampling.template = tri.surf(consensus.array, perimeter.map, 3, test.image, flip.delaunay = TRUE)
```
When flip.delaunay = TRUE
![](images/test_image_flip_wrong.png)



## Visualizing the sampling template

We have included the ability to plot the sampling template generated by the *tri.surf* function. The example code below shows how to plot the template where the specimen will be sampled. You may specify the style = "points" to plot the location of the all the points (perimeter and interior) that will be sampled, style = "perimeter" will print only the perimeter points, style = "interior" will plot only interior points, and style = "triangulation" will plot the triangulation that was generated and the centroids of each triangle. For style = "triangulation" you may change the color of the triangles that were generated (wireframe.color = ), as well as the color of the centroid (point.color = ).

### No overlay on image
Plotting both the perimeter and interior points that will be sampled
```r
plot(specimen.sampling.template, style = "points")
```
![](images/plot_points.png)

Plotting only the perimeter points
```r
plot(specimen.sampling.template, style = "perimeter")
```
![](images/plot_perimeter_points.png)

Plotting only the interior points
```r
plot(specimen.sampling.template, style = "interior")
```
![](images/plot_interior_points.png)

Plotting the map of the Delaunay trinagulation and the centroids of the triangles
```r
plot(specimen.sampling.template, style = "triangulation", wireframe.color = "black", point.color = "red")
```
![](images/plots_triangulation.png)


### Overlay on image
The "triangulation" style can be plotted overlaying the test.image (defined above). The following code shows how to make this plot. The default colors for both the "triangulation" and "overlay" styles draw the triangles in black and the sampling points (centroids) in red. However, The user can change the color of the triangles and centroids using the point.color =   and wireframe.color =  arguments.
```r
plot(specimen.sampling.template, corresponding.image = test.image, style = "overlay", wireframe.color = "grey", point.color = "yellow" )
```
![](images/specimen_template_overlay.png)


## Setting the sampling circle size and measuring RGB

The *rgb.measure* function measures the RGB values of the points sampled from the unwarped specimen images (at the points identified above in the *tri.surf* function). To control the size of the sampling circle, the user provide the radius length (in pixels) out from the centroid, from which to sample the surrounding pixels. In this function, the user first provides the file path to the folder containing the unwarped (to the consensus shape) images that are to be sampled, followed by the .csv containing the image names with the 2nd column specified (unwarped image names are in the second column), next is the "specimen.sampling.template" (which provides sampling coordinates), an integer for the user-specified size of the sampling circle **radius** in pixels (px.radius = 0 will only sample the pixel located at the centroid of the triangle), and the logical argument for whether you would like to apply the linear transform (based on international standard IEC 61966-2-1:1999),to convert sRGB values to linearized values. 

```r
uncalib_RGB = rgb.measure("C:/Users/jennv/Desktop/Colormesh_Test_2/unwarped_images/", specimen.factors[,2], specimen.sampling.template, px.radius = 2, linearize.color.space = FALSE)

linear_uncalib_RGB = rgb.measure("C:/Users/jennv/Desktop/Colormesh_Test_2/unwarped_images/", specimen.factors[,2], specimen.sampling.template, px.radius = 2, linearize.color.space = TRUE)
```

##Visualizing the sampled color

The example code below will plot the color sampled using the *rgb.measure* function. The "individual = " argument allows you to plot a specific specimen. The default of style = "points" which plots the color values that were sampled from the image (perimeter and interior). Similar to the plotting options above, you have the option of only plotting the perimeter or the interior points.  To compare your plotted sampled color values to the original image the color values were sampled from, set style = "comparison". Note that a plot of sampled values where linearize.color.space = TRUE will be darker than the original image due to the application of the linear transform.

Plotting measured color at all points
```r
plot(uncalib_RGB, individual = 8, style = "points")
```
![](images/uncalib_plotted_points.png)

Plotting measured color at only the perimeter points
```r
plot(uncalib_RGB, individual = 8, style = "perimeter")
```
![](images/uncalib_plotted_perimeter.png)

Plotting measured color at only the interior points
```r
plot(uncalib_RGB, individual = 8, style = "interior")
```
![](images/uncalib_plotted_interior.png)

Plotting measured color at all points along with the image the color was sampled from 
```r
plot(uncalib_RGB, individual = 8, style = "comparison")
```
![](images/uncalib_plotted_comparison.png)

The plots hown above can be used to visuale your linearized color data as well.
*Note: Plotting the linearized measured color; these will appear darker*
```r
plot(linear_uncalib_RGB, individual = 8, style = "points")
plot(linear_uncalib_RGB, individual = 8, style = "perimeter")
plot(linear_uncalib_RGB, individual = 8, style = "interior")
plot(linear_uncalib_RGB, individual = 8, style = "comparison")
```
![](images/linear_uncalib_plotted_points.png) | ![](images/linear_uncalib_plotted_perimeter.png) | ![](images/linear_uncalib_plotted_interior.png) | ![](images/linear_uncalib_plotted_comparison.png)


# Color calibration

Color information across images can be pretty noisy due to inconsistent lighting, different camera settings, movement of the object, etc. We highly recommend adjusting for those differences by including a color standard in each image. Using the differences in color standard values between images to mitigate variation due to noise, landmarks placed on the color standard are used to sample known RGB values and adjust the sampled color of your specimen by the average deviation in each color channel.  

The *rgb.calibrate* function goes through the calibration images and samples the color standards of each image. It then creates an array of these values. The default sampling circle radius is set to px.radius = 2. Once each color of the color standard is sampled, it determines the mean deviation in values of the R,G,B color channels from the known values of each color on the standardfor that image. The overal mean deviation in each color channel is used as a correction to the R,G, and B color values measured at each sampling point within a photo.

## Checking the alignment for sampling

Prior to calibrating each image, it is important to check that the sampling locations align with the color standard in the image. The code below plots colored dots at the locations where color will be sampled in the image. The user has the option to change the size and color of the dots that are plotted. This is a simple test to confirm the y-axis coordinates are correct. In the example below, yellow points are plotted over the locations that will be sampled for color calibration.
  
```r
calib.plot(imagedir = "C:/Users/jennv/Desktop/Colormesh_Test_2/calib_images/", image.names = specimen.factors[ ,1], calib.file = calib.array, individual = 4, col = "yellow", cex = 1)
```
![](images/calib_plot_test.png)


## Calibrating your measured color

The *rgb.calibrate* function will correct each images measured RGB values based on the mean deviation of each color channel from the known RGB values of the color standard in that image. The user provides the file path to the folder containing the original images, the image names for these images, the array having the landmark coordinates of where to sample color from, whether the y-axis values need to be flipped based on the calib.plot function performed ot check sampling alignment, and the csv containing the known RGB values for the color standard.
*Note: If the calib.plot showed proper alignment,set flip.y.values = F*
```r
calib_RGB <- rgb.calibrate(uncalib_RGB, imagedir =  "C:/Users/jennv/Desktop/Colormesh_Test_2/calib_images/", image.names = specimen.factors[ ,1], calib.file = calib.array, flip.y.values = F, color.standard.values = known.rgb)

##  By default, the radius of the sampling circle is = 2. The user can change the sampling circle size by providing a different integer. 
calib_RGB <- rgb.calibrate(uncalib_RGB, imagedir =  "C:/Users/jennv/Desktop/Colormesh_Test_2/calib_images/", image.names = specimen.factors[ ,1], calib.file = calib.array, flip.y.values = F, color.standard.values = known.rgb, px.radius = 3)
```
To calibrate measure RGB where linearize.color.space = TRUE, the rgb.calibrate function is used in the same manner. The rgb.calibrate function detects that this data was linearized. When detected, both the known RGB values and the color measured from the color standard will be linearized prior to calculating the mean deviation from the known RGB values. This lienarized color correction will then be applied to the linearized values collected from the specimen images.

```r
linear_calib_RGB <- rgb.calibrate(linear_uncalib_RGB, imagedir =  "C:/Users/jennv/Desktop/Colormesh_Test_2/calib_images/", image.names = specimen.factors[ ,1], calib.file = calib.array, flip.y.values = F, color.standard.values = known.rgb)
```


##Visualizing the calibrated color

To plot your calibrated colors, you have the same options as above. With style = "points" both perimeter and interior points where color has been calibrated will be plotted. To print just the perimeter, style = "perimeter". With style = "interior" only the interior calibrated color values will be plotted. To compare your calibrated points to the uncalibrated points, set style = "comparison". 

```r
plot(calib_RGB, individual = 5, style = "points")
plot(calib_RGB, individual = 5, style = "perimeter")
plot(calib_RGB, individual = 5, style = "interior")
plot(calib_RGB, individual = 5, style = "comparison")
```



Linearized values can be plotted, as well. 
*Note: Linearized RGB values will have a darker appearance.* 

```r
plot(linear_calib_RGB, individual = 5, style = "points")
plot(linear_calib_RGB, individual = 5, style = "perimeter")
plot(linear_calib_RGB, individual = 5, style = "interior")
plot(linear_calib_RGB, individual = 5, style = "comparison")
```


## Extracting your data

We created a simple function, *make.colormesh.dataset*, to compile your data into a single dataframe. The user specifies which dataset they would like to include, the csv containing the specimen information, and lastly, a logical argument (TRUE/FALSE) as to whether perimeter point data is included. 

This dataframe will give specimens in rows and RGB color values, following by point coordinates in columns. The column names indicate the point ID, whether it is an interior or perimeter point, and the color channel (R,G, or B). Following the columns of color data, the x,y coordinates of each point are also provided. In the guppy example shown here, there were 10 specimens and therefore 10 rows. Sampling points consisted of 62 perimeter points and 780 interior points for 842 total points sampled; each of these points has 3 color channels. The number of columns totals = 4214 (4 columns with specimen identification information, 842 * 3 = 2526 color columns, plus 842 * 2 = 1684 coordinate columns).

```r
final.df.uncalibrate <- make.colormesh.dataset(df = uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F)
final.df.uncalibrate.perim <- make.colormesh.dataset(df = uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T)

final.df.calibrate <- make.colormesh.dataset(df = calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F)
final.df.calibrate.perim = make.colormesh.dataset(df = calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T)


final.df.uncalibrate.linear <- make.colormesh.dataset(df = linear_uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F)
final.df.uncalibrate.linear.perim <- make.colormesh.dataset(df = linear_uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T)

final.df.calibrate.linear <- make.colormesh.dataset(df = linear_calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F)
final.df.calibrate.linear.perim <- make.colormesh.dataset(df = linear_calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T)
```

If you would like to write this datafram to a .csv file, include the file path where you would like the file to be saved following the write2csv argument. 

```r
final.df.calibrate.saved <- make.colormesh.dataset(df = calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F, write2csv = "C:/Users/jennv/Desktop/Colormesh_Test_2/colormesh_data_calib.csv")

final.df.uncalibrate.saved <- make.colormesh.dataset(df = uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F, write2csv = "C:/Users/jennv/Desktop/Colormesh_Test_2/colormesh_data_uncalib.csv")
```

