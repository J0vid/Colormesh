# Colormesh
An R package for extraction of color data from digital images.

## Installation

The following example code will guide you through the process of using Colormesh to extract color from your digital photos. The process of using Colormesh is divided into three major sections below: Preparing CSV Files, Image Processing, and Color Sampling. Image processing includes both landmark placement and image deformation (genertion of a consensus shape specimen). The Image Processing section is further divided into two subsections: one describing image processing within the Colormesh environment nad the other showing how to import files with varying amounts of processing performed externally. Because some users may already be familiar with existing geometric morphometric software, we have enabled Colormesh to import files typically generatied by external processing (e.g., TPS files). Colormesh can be used regardless of the level of image processing that has been completed externally. The external processing examples provided below used the *TPS Series* software by James Rohlf, availble for free at the Stonybrook Morphometrics website (http://www.sbmorphometrics.org/). 


## Installing Colormesh from github
```r
## Need to make sure this is updated
devtools::install_github("https://github.com/J0vid/Colormesh")
```

# Using Colormesh (V2.0)


## Required files for Colormesh (V2.0) Color Sampling
The files listed below are required in order to sample color from digital images that have been unwarped to a consensus shape. Some of the required files are obtained during image processing. Image processing may be completed entirely within the Colormesh package. Alternatively, some or all of the image processing steps may be completed externally in your geometric morphometric program of choice given landmark data are contained in a TPS file format. Required files are:

  1. A .csv file containing factors such as the specimen image names - these names must be unique. The first column MUST contain the unique image name. This .csv file will be used as a check to ensure measured color and calibration correction (if used) are associated with the appropriate image. If image unwarping (to the consensus shape) was completed externally, include the unique image names of the unwarped images in the second column. Any additional columns containing factors needed for your organization or identification (e.g., population name) can be included after the image name column(s).
  
  2. A .csv file containing the known RGB values of the colors on the color standard to be used for calibration. They should be on a scale of 0 to 1. Each row is a color on the standard, each column is a color channel; the know R, G, and B values must appear in columns 1, 2, and 3, respectively. If known RGB values are on a scale of 0-255, simply divide by 255 to convert values to the proper scale.
  
  3. Two image file folders: One file folder containing the original images that have the color standard and another file folder for the unwarped images. If unwarped images were generated externally they can be stored in this unwarped file folder. if unwarping images within Colormesh, this folder will become populated with the unwarped images.
   
  4. Two landmark coordinate data arrays: one having coordinate data for landmarks placed on the color standard and the other having landmark data for the consensus shape of the specimens. If landmark placement and unwarping of specimen images is performed within Colormesh, these arrays will be generated when using the functions described below. If these landmark data files are generated externally, they're typically in the form of TPS files. These TPS files are easily loaded into Colormesh using a function that converts them into the appropriate array format (see below).  




# I. Preparing CSV Files

 1. Using base R, read in the .csv containing the specimen image names (omit file extensions such as .jpg or .tif) and identification information. The first column MUST contain unique image names. If images were unwarped to a consensus shape outside of Colormesh, include the unique names of the unwarped images in the send column of this csv. The remaining columns can contain any other information you may need to identify your specimens.

 2. Using base R, read in the .csv containing the known RGB values for each of the colors on your color standard. The color channel values should be on the scale of 0 to 1; if the are out of 255, simply divide by 255. The rows of this csv should be the different colors found on your color standard. Each column should provide the known color RGB values for each of the colors on the standard. For example, if you have 5 colors in your color standard, you will have 5 rows. The first column of the csv should contain the known RED value for each of the five colors. The second column should contain the GREEN color channel values for each of the five colors on the standard. The third column should have the BLUE color channel values for each of the five known colors on the standard. 

```r
specimen.factors <- read.csv("C:/Users/jennv/Desktop/Colormesh_test_jpg/specimen_factors.csv", header = T)

known.rgb <- read.csv("C:/Users/jennv/Desktop/Colormesh_test_jpg/known_RGB.csv", header = T)  
```



# II. Image Processing: Landmark placement & generating consensus shaped images


## A. Landmark placement
Landmark placement may be performed either within the Colormesh environment or externally. The aim of landmarks placement is to generate the two arrays containing landmark coordinate data. Landmarks placed within the Colormesh environment will automatically generate the appropriate arrays. Alternatively, landmarks placed using other software that are in the TPS file format can simply be imported, as described below.

### Option 1) Landmark Placement within the Colormesh environment

Colormesh calls on the image digitization ability found in the *geomorph* package to create the required landmark data array. The *landmark.images* function will temporarily convert images to jpgs solely for obtaining the coordinates of the landmarks that are placed. A plot window will open with the first image and the user will be prompted to set the scale......
To avoid accidental sampling of the compressed jpg images, the logical argument, dump.tmp.images is set = T which will remove these temporary images. The array of landmark coordinate data is saved in the global environment and is written as a TPS file to the directory you provided. 

```{r}
## we left the arguments, "writedir" and "dump.tmp.images" = NULL because we were not interested in saving the temporary images.
specimen.LM <- landmark.images(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/",image.names = specimen.factors[ ,1], nlandmarks = 62, writedir = "C:/Users/jennv/Desktop/Colormesh_test_tif/", dump.tmp.images = T, scale = 10)

calib.LM <- landmark.images(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_tif/", image.names = specimen.factors.tif[ ,1], nlandmarks = 5, writedir = "C:/Users/jennv/Desktop/Colormesh_test_tif/", dump.tmp.images = T)

```

### Option 2) Landmark placement performed externally, then imported into the Colormesh environment

When landmarks are placed using other geometric morphometric software, coordinate data are typically saved as a TPS file. The function *tps2array* will read in the .TPS file containing landmark coordinatedata and convert the information into the required array format. You will need to import the coordinate data for landmarks that were placed on the color standard. You will also need to import the coordinates for the landmarks placed around each of the specimen images; unwarping images to the consensus shape within the Colormesh environment will produce the other required landmark coordinate data set: the coordinates for the consensus shape (see the *tps.unwarp* function below). 

```r
## The code below reads in the TPS file generated in the TPSdig software. This TPS file contains 62 landmark coordinates that were placed around each of the three specimens. 

specimen.LM.ext <-  tps2array("C:/Users/jennv/Desktop/Colormesh_test_jpg/orig_LM_jpg.TPS")


## The code below reads in the TPS file generated in the TPSdig software. This TPS file contains the coordinates for landmarks placed on the color standard contained within each specimen image. These landmarks will identify where the image will be sampled for the calibration process. 

calib.LM.ext <-  tps2array("C:/Users/jennv/Desktop/Colormesh_test_jpg/calib_LM_jpg.TPS")

```


## B. Generating consensus shape images 
Similar to landmarking, images can be unwarped to a consensus shape either within the Colormesh environment or in your favorite geometric morphometrics software, then imported into Colormesh for sampling. Below, we describe these two options. The aim of generating the consensus shaped images is to standardize the shape of the specimen. This process generates two of the required files needed as input for the Colormesh sampling pipeline: a set of landmark coordinates of the consensus shape and the set of images where specimens have a consensus shape.  

### Option 1) Within the Colormesh environment 

Images that are unwarped to a consensus shape within the Colormesh environment must have the same pixel dimensions (height x width). Unwarping to a consensus shape within Colormesh is performed by the *tps.unwarp* function. The function first performs a Generalized Procrustes Analysis utilizingemploying the utilities of the *geomorph* package to generate a consensus shape. Then, the *imager* package is used to to perform a thin-plate spline (TPS) image transformation. Finally, the resulting unwarped images are saved as PNG image format files in the directory identified by the user.  

The first step is to define the perimeter map of the specimen and identifying which landmarks, if any, are sliding landmarks (semilandmarks). This perimeter map tells Colormesh the order in which to connect the points so a perimeter is drawn. This perimeter map is used in both the unwarping process (landmark sliding) and the Delaunay triangulation (described below) to determine sampling locations. The code below tells Colormesh what order to read the landmarks in so that a perimeter is drawn around the specimen in a "connect-the-dots" manner. In the guppy example below, the first seven landarks that were placed around the guppy were at traditional landmark locations (easily identifiable between images); the remaining 55 landmarks are referred to as semilandmarks. Semilandmarks are interspersed between the traditional landmarks and allowed to slide along the tangent of the curve they create when generating a consensus shape.

```r
## Define perimeter map (order the points occur around the perimeter)
perimeter.map <- c(1, 8:17, 2, 18:19, 3, 20:27, 4, 28:42,5,43:52, 6, 53:54, 7, 55:62)

## Define sliders (main.lms identifies which of all 62 landmarks are the tranditional landmarks and therefore will not slide)
sliders <- make.sliders(perimeter.map, main.lms = 1:7)
```
![](images/perimeter_line_map.png)


Prior to running the *tps.unwarp* function, you will need to create a file folder as a destination for writing the unwarped images. The information required by the function includes: the directory containing the original specimen images that are to be unwarped to the concensus shape identified by the "imagedir" argument (note: these images must all have the same pixel dimensions). Also provided to the function are the landmark coordinate data array for the landmarks that were placed around each specimen contained in these images. To align the coordinate data with the appropriate images, you must provide the image names from the CSV file (1st column). If you have defined landmarks that are semilandmarks, and therefore allowed to slide, they also need to be identified. And finally, you must provide the directory where Colormesh will write the unwarped images. These unwarped images will be saved as PNG images, which is an uncompressed image format.

```{r}
## Example code using landmark coordinate data array generated by placing landmarks within the Colormesh environment
unwarped.jpg <- tps.unwarp(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/", landmarks = specimen.LM, image.names = specimen.factors[,1], sliders = sliders , write.dir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/unwarped_images_jpg/")

## Example code using landmark coordinate data array that was imported using the tps2array function (landmarks were placed in an external program)
unwarped.jpg.ext <- tps.unwarp(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/", landmarks = specimen.LM.ext, image.names = specimen.factors[,1], sliders = sliders , write.dir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/unwarped_images_jpg/")
```
The output of the function is a list having two elements. The "target" element of the list is the landmark coordinate data for the consensus shape generated by the function. The names given to the unwarped images appear as the 2nd list element. The resulting unwarped images are written to the directory given by the user and specimens. When image files are opened, specimens will now have the same shape. Some black areas near the edges of the images are expected as they are part of the unwarping process.


### Option 2) Preparing for the Colormesh sampling pipeline using images that were unwarped to a consensus shape outside the Colormesh environment 
Colormesh can be used to sample color from consensus shaped images even if the entirity of image processing has occured externally. When generating the consensus images externally, you will then need to provide some of the required information to Colormesh by simply importing what is needed. 
This includes: 
     1. Defining the perimeter map to prepare the dataset for Delaunay triangulation. 
     2. The two CSV files described above. However, the image information CSV should have the unique names of the unwarped images as the 2nd column of the CSV file.
     3. The two required arrays containing landmark coordinate data: the coordinates of landmarks placed on the color standard and the other array will be the 
         landmark coordinate data of the CONSENSUS shape. These can be imported using the *tps2array* function described above.
     4. The two required images sets residing in their own folders. One image set will include the original image (with the color standard) and the other image 
         set is the unwarped images.  

```{r}
## Defining the perimeter map - this will be used in the Color Sampling pipeline
perimeter.map <- c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62)

## Example code for reading in the CSV files
specimen.factors <- read.csv("C:/Users/jennv/Desktop/Colormesh_test_jpg/specimen_factors.csv", header = T) ## First column = original image names, 2nd column = unwarped names
known.rgb <- read.csv("C:/Users/jennv/Desktop/Colormesh_test_jpg/known_RGB.csv", header = T) 

## Example code for reading in the TPS files and converting them to the appropriate array format
consensus.LM = tps2array("C:/Users/jennv/Desktop/Colormesh_test_jpg/consensus_LM_coords.TPS") ## NOTE: CONSENSUS SHAPE COORDINATES ONLY
calib.LM.ext <-  tps2array("C:/Users/jennv/Desktop/Colormesh_test_jpg/calib_LM_jpg.TPS")

## Two image file folders are also needed. 
```


# Color Sampling
To proceed with color sampling, you should now have availble to Colormesh: 
   1. The two required CSV files. 
   2. The two landmark coordinate arrays: one having land mark coordinate data of the CONSENSUS SPECIMEN SHAPE and the other having the landmark coordinate 
       data of where to sample the color standard for the calibration process.
   3. Two sets of images located in their own directories: the set of images that were unwarped to the consensus shape and the original set of images containing 
       the color standard. 

## Determining sampling density

Colormesh uses Delaunay triangulation to determine locations to samples color. The first round of Delaunay triangulation uses the landmark coordinates of the consensus shape as the vertices of the triangles. It reads in the landmark coordinates of this consensus based on the order defined in the perimeter.map variable. The function that creates this mesh was designed to provide the user with flexibility in sampling density based on the number of rounds of triangulation specified by the user; more rounds provides a greater density of sampling points. This is accomplished by using the centroids of the triangles created from the first round of Delaunay triangulation as the vertices for subsequent rounds of triangulation. In the images below, the centroids are shown as the red dots within the triangles.

Here's what an example of two, three, and four rounds of triangulation looks like:

![Triangulation example](images/DT.png)


# Checking alignment and generating the sampling template

IMPORTANT: Test that your sampling points properly overlay your image. Image readers (e.g., EBImage & imager) place the 0,0 x,y-coordinate in the upper left corner. In contrast, the coordinates in the TPS file place 0,0 in the bottom left corner. Colormesh assumes this to be true. To check this, the code below is used to read in a test image, calculate the sampling template, then plot the Delaunay triangulation wire-frame on top of the image to ensure that you are properly sampling the image. 

## Reading in a test image

To check that Colormesh will be sampling your speciment correctly, first read in one of the unwarped images from your image file. This uses the load.image function from the *imager* package.

```r
align.test1 <- load.image("C:/Users/jennv/Desktop/Colormesh_test_jpg/unwarped_images_jpg/IMG_7647_unwarped.png")
```
![](images/TULPAAM03_1015_un.jpg)


## Calculating sample location and checking alignment 

The density of sampling points is determined by Colormesh's *tri.surf* function and is an integer defined by the user. The *tri.surf* function identifies the X,Y coordinates of the centroid for each triangle generated by Delaunay triangulation. If more than one round of triangulation is specified by the user, these centroids function as vertices for subsequent rounds of triangulation. At the completion of the user-specified rounds of triangulation, the pixel coordinate for each triangle's centroid is saved as sampling coordinates. 


## Generating the sampling template

The alignment check draws a yellow line around the perimeter of your speciment and red circles are plotted at the pixel coordinates that will be sampled (circles are sized to be easily visible and do not represent the number of pixels that will be sampled). The user provides the consensus.array (the TPS file of the consensus shape that was read in), the perimeter.map (to provide the order of points around the perimeter), an integer to indicate how many rounds of triangulations to perform, the name of the test image that was generated, and the logical argument for whether to flip the y-coordinate values. The sampling template will be plotted overlaying the test image to show the user how the images will be sampled. If the orientation of the sampling template needs to be flipped, the flip.delaunay logical will flip the y-coordinates. By default, flip.delaunay = FALSE since imager assumed 0,0 to be in the upper left and most TPS file generators assume 0,0 to be in the lower left. Be sure your specimen.sampling.template is defined with the correct orientation (in dicated by whether the traingulation overlay is properly aligned).

*Note: the circles shown in the alignment check are **not** equal to the size of the sampling circle size.*

```r
## In this example, 3 rounds of Delaunay Triangulation will be performed.
specimen.sampling.template <- tri.surf(unwarped.jpg$target, point.map = perimeter.map, 3, align.test1, flip.delaunay = F)
```

The images below show the two outcomes of the flip.delaunay logical argument.
When flip.delaunay = FALSE
![](images/test_image_flip_right.png)

```r
## If the sampling template is upside-down, set flip.delaunay = TRUE
specimen.sampling.template <- tri.surf(unwarped.jpg$target, point.map = perimeter.map, 3, align.test1, flip.delaunay = T)
```
When flip.delaunay = TRUE
![](images/test_image_flip_wrong.png)



## Visualizing the sampling template

We have included the ability to plot the sampling template generated by the *tri.surf* function. The example code below shows how to plot the template where the specimen will be sampled. You may specify the style = "points" to plot the location of the all the points (perimeter and interior) that will be sampled, style = "perimeter" will print only the perimeter points, style = "interior" will plot only interior points, and style = "triangulation" will plot the triangulation that was generated and the centroids of each triangle. For style = "triangulation" you may change the color of the triangles that were generated (wireframe.color = ), as well as the color of the centroid (point.color = ).

### No overlay on image
Plotting a map of all points (both the perimeter and interior) that will be sampled
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

## Visualizing the sampled color

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

The plots hown above can be used to visualize your linearized color data as well.
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

The *rgb.calibrate* function will correct each image's measured RGB values based on the mean deviation of each color channel from the known RGB values of the color standard in that image. First, the user provides the name of the data that is to be calibrated, for example, "uncalib_RGB". Then the user provides the file path to the folder containing the original images (imagedir =). Next, "image.names = " is defined by providing the column containing the calibration image names from the csv containing this information. The coordinates of where to sample the color standard are defined as "calib.file = ". The logical argument for "flip.y.values" is availble if the test image that is plotted shows that the y-coordinates need to be corrected (determined in the previous step with the calib.plot function). Finally, "color.standard.values = " is defined as the csv containing the known RGB values for the color standard. By default, the sampling circle that samples each color standard has a default radius = 2 pixels. You can change the size of the sampling circle with an integer when defining "px.radius = " as shown in the example code below.
*Note: If the calib.plot function showed proper alignment, set flip.y.values = F*
```r
calib_RGB <- rgb.calibrate(uncalib_RGB, imagedir =  "C:/Users/jennv/Desktop/Colormesh_Test_2/calib_images/", image.names = specimen.factors[ ,1], calib.file = calib.array, flip.y.values = F, color.standard.values = known.rgb)

##  By default, the radius of the sampling circle is = 2. The user can change the sampling circle size by providing a different integer. 
calib_RGB <- rgb.calibrate(uncalib_RGB, imagedir =  "C:/Users/jennv/Desktop/Colormesh_Test_2/calib_images/", image.names = specimen.factors[ ,1], calib.file = calib.array, flip.y.values = F, color.standard.values = known.rgb, px.radius = 3)
```
To calibrate measured RGB values where linearize.color.space = TRUE, the *rgb.calibrate function* is used in the same manner. The *rgb.calibrate* function detects that this data was linearized. When detected, both the known RGB values and the color measured from the color standard will be linearized prior to calculating the mean deviation from the known RGB values. This lienarized color correction will then be applied to the linearized values collected from the specimen images.

```r
linear_calib_RGB <- rgb.calibrate(linear_uncalib_RGB, imagedir =  "C:/Users/jennv/Desktop/Colormesh_Test_2/calib_images/", image.names = specimen.factors[ ,1], calib.file = calib.array, flip.y.values = F, color.standard.values = known.rgb)
```


##Visualizing the calibrated color

To plot your calibrated colors, you have the same options as above. With style = "points" both perimeter and interior points where color has been calibrated will be plotted. To print just the perimeter, style = "perimeter". With style = "interior" only the interior calibrated color values will be plotted. To compare your calibrated points to the uncalibrated points, set style = "comparison". 

Plotting calibrated color values with style = "points"
```r
plot(calib_RGB, individual = 5, style = "points")
```
![](images/calib_plot.png)

Plotting calibrated color values with style = "perimeter"
```r
plot(calib_RGB, individual = 5, style = "perimeter")
```
![](images/calib_perimeter.png)

Plotting calibrated color values with style = "interior"
```r
plot(calib_RGB, individual = 5, style = "interior")
```
![](images/calib_interior.png)

Plotting calibrated color values with style = "comparison"
```r
plot(calib_RGB, individual = 5, style = "comparison")
```
![](images/calib_uncalib_comparison.png)




Linearized values can be plotted, as well. 
*Note: Linearized RGB values will have a darker appearance.* 

Plotting linearized calibrated color values with style = "points"
```r
plot(linear_calib_RGB, individual = 5, style = "points")
```
![](images/linear_calib_plot.png)

Plotting linearized calibrated color values with style = "perimeter"
```r
plot(linear_calib_RGB, individual = 5, style = "perimeter")
```
![](images/linear_calib_perimeter.png)

Plotting linearized calibrated color values with style = "interior"
```r
plot(linear_calib_RGB, individual = 5, style = "interior")
```
![](images/linear_calib_interior.png)

Plotting linearized calibrated color values with style = "comparison"
```r
plot(linear_calib_RGB, individual = 5, style = "comparison")
```
![](images/lienar_calib_linear_uncalib_comparison.png)





## Extracting your data

We created a simple function, *make.colormesh.dataset*, to compile your data into a single dataframe. The user specifies which dataset they would like to include, the csv containing the specimen information, and lastly, a logical argument (TRUE/FALSE) as to whether perimeter point data is included. 

This dataframe will give specimens in rows and RGB color values, following by point coordinates in columns. The column names indicate the point ID, whether it is an interior or perimeter point, and the color channel (R,G, or B). Following the columns of color data, the x,y coordinates of each point are also provided. In the guppy example shown here, there were 10 specimens and therefore 10 rows. Sampling points consisted of 62 perimeter points and 780 interior points for 842 total points sampled; each of these points has 3 color channels. The number of columns totals = 4214 (4 columns with specimen identification information, 842 * 3 = 2526 color columns, plus 842 * 2 = 1684 coordinate columns).

```r
final.df.uncalibrate = make.colormesh.dataset(df = uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F)
final.df.uncalibrate.perim = make.colormesh.dataset(df = uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T)

final.df.calibrate = make.colormesh.dataset(df = calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F)
final.df.calibrate.perim = make.colormesh.dataset(df = calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T)


final.df.uncalibrate.linear = make.colormesh.dataset(df = linear_uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F)
final.df.uncalibrate.linear.perim = make.colormesh.dataset(df = linear_uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T)

final.df.calibrate.linear = make.colormesh.dataset(df = linear_calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F)
final.df.calibrate.linear.perim = make.colormesh.dataset(df = linear_calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T)
```

If you would like to write this datafram to a .csv file, include the file path where you would like the file to be saved following the write2csv argument. 

```r
final.df.calibrate.saved = make.colormesh.dataset(df = calib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F, write2csv = "C:/Users/jennv/Desktop/Colormesh_Test_2/colormesh_data_calib.csv")

final.df.uncalibrate.saved = make.colormesh.dataset(df = uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = F, write2csv = "C:/Users/jennv/Desktop/Colormesh_Test_2/colormesh_data_uncalib.csv")
```

