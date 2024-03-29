# __Colormesh (V2.0)__

An R package for generating consensus shaped specimen images and the extraction of color data from the consensus images.

# __1.  Installation__

*Colormesh* uses the *imager* package to read in images for some custom functions. If you are processing image formats other than PNG, JPEG, or BMP, you will need to install the program, ImageMagick on your computer: (https://imagemagick.org/script/download.php). Consistency is critical - image programs may behave differently from each other. Any image format conversions should be completed prior to using *Colormesh*. For example, if you convert raw image formats to a tif format, perform this conversion with the same software on all of your images (e.g., Prior to sampling images with *Colormesh*, use Photoshop to convert ALL of your images from .cr2 to .tif). If landmark placement and/or unwarping is/are performed externally (e.g., using tpsDig and/or tpsSuper), image conversions need to be completed prior to placement of landmarks and/or unwarping using external programs. Sampling color using *Colormesh* has been tested successfully on several image formats where images were converted between formats using Photoshop.    

The following example code will guide you through the process of using *Colormesh* to transform images to a consensus specimen shape and extract color from these images. The process of using *Colormesh* is divided into three major sections below. The "Using *Colormesh*" section is further divided into subsections: Preparing CSV Files, Image Processing, Color Sampling Pipeline, and Calibration. Image Processing includes both landmark placement and image transformation (generation of consensus shape specimen images). The Image Processing section provides example code to show users how to complete the process within the *Colormesh* environment, as well as importing files depending on the level of image processing completed externally. Because some users may already be familiar with existing geometric morphometric software, we have enabled *Colormesh* to import files typically generated by external processing (e.g., TPS files). *Colormesh* can be used regardless of the level of image processing that has been completed externally. The external processing examples provided below are based on use of the *TPS Series* software by James Rohlf, available for free at the Stonybrook Morphometrics website (http://www.sbmorphometrics.org/). 


### Installing Colormesh from github
```r
devtools::install_github("https://github.com/J0vid/Colormesh")
```

# __2.  Using Colormesh (V2.0)__


## *Required files for Colormesh (V2.0) Color Sampling*

The files listed below are required to proceed with the Color Sampling Pipeline (Section 2.4). Some of the required files are obtained during image processing. Image processing may be completed entirely within the *Colormesh* package. Alternatively, some or all of the image processing steps may be completed externally in your geometric morphometric program of choice given landmark data are contained in a TPS file format. Required files are:

  * A .csv file containing factors such as the specimen image names - these names must be unique and *not* contain symbols (e.g., +, %, -), puncuation, or spaces. The first column MUST contain the unique image name. This .csv file will be used as a check to ensure measured color and calibration correction (if used) are associated with the appropriate image. If image unwarping (to the consensus shape) was completed externally, include the unique image names of the unwarped images in the second column. Any additional columns containing factors needed for your organization or identification (e.g., population name) can be included after the image name column(s).
  
  * A .csv file containing the known RGB values of the colors on the color standard to be used for calibration. They should be on a scale of 0 to 1. Each row is a color on the standard, each column is a color channel; the know R, G, and B values must appear in columns 1, 2, and 3, respectively. If known RGB values are on a scale of 0-255, simply divide by 255 to convert values to the proper scale.
  
  * Two image file folders: One file folder containing the original images that have the color standard and another file folder for the unwarped images. If unwarped images were generated externally they can be stored in this unwarped file folder. if unwarping images within *Colormesh*, this folder will become populated with the unwarped images.
   
  * Two landmark coordinate data arrays: one having coordinate data for landmarks placed on the color standard and the other having landmark data for the consensus shape of the specimens. If landmark placement and unwarping of specimen images is performed within *Colormesh*, these arrays will be generated when using the functions described below. If these landmark data files are generated externally, they're typically in the form of TPS files. These TPS files are easily loaded into *Colormesh* using a function that converts them into the appropriate array format (see Section 2.2.1.2 below).  



## 2.1  Preparing the required CSV Files

  * Using base R, read in the .csv containing the specimen image names (omit file extensions such as .jpg or .tif) and identification information. The first column MUST contain unique image names. The remaining columns can contain any other information you may need to identify your specimens.

  * Using base R, read in the .csv containing the known RGB values for each of the colors on your color standard. The color channel values should be on the scale of 0 to 1; if the are out of 255, simply divide by 255. The rows of this csv should equal the number of colors sampled from the color standard. Each column should provide the known color RGB values for each of the colors on the standard. For example, if you have 5 colors on the color standard, you will have 5 rows. The first column of the csv should contain the known RED color channel values for each of the five colors, the second column should contain the known GREEN color channel values, and the third column should have the known BLUE color channel values. 

```r
specimen.factors <- read.csv("C:/Users/jennv/Desktop/Colormesh_test_jpg/specimen_factors.csv", header = T)

known.rgb <- read.csv("C:/Users/jennv/Desktop/Colormesh_test_jpg/known_RGB.csv", header = T)  
```


## 2.2  Image Processing: Landmark placement & generating consensus shaped images

### 2.2.1  Landmark placement

Landmark placement may be performed either within the *Colormesh* environment (Section 2.2.1.1, below) or externally (Section 2.2.1.2, below). The aim of landmarks placement is to generate the two arrays containing landmark coordinate data: one array having coordinate data for landmarks placed around each specimen and the other array having coordinate data for landmarks placed on the color standard. Landmarks placed within the *Colormesh* environment will automatically generate the appropriately formatted arrays. Alternatively, landmarks placed using other software that are in the TPS file format can simply be imported, as described in Option 2, below.

#### 2.2.1.1 Landmark Placement within the *Colormesh* environment

*Colormesh* calls on the image digitization ability found in the *geomorph* package to create the required landmark data array. The *landmark.images* function behaves similarly to  the *digitize2d* function within the *geomorph* package; it will temporarily convert images to jpgs solely for obtaining landmark coordinates. A plot window will open with the first image. If the user defined a scale (e.g., scale = 10), the user will be prompted to first set the scale; if no scale was defined, the user will begin placing landmarks. In the example code below, the scale = 10. To set the scale, the user will create a line segment that expands across 10mm of the scale. To draw the line segment, the user first aligns the cross-hairs on the scale to where the first of two points will be placed. Click the left mouse button to place the first point of the line segment to be drawn. To place the second point, the user aligns the cross-hairs on the scale at the distance defined in the function and clicks to place this point, drawing a line segment. The user will be prompted as to whether they would like to keep the scale - to redraw the line segment, type "n". To keep the segment, type "y". The user will now begin placing the landmarks around the specimen. Follow the prompts in the R console. After placement of each landmark, the user will be prompted as to whether they would like to keep the landmark - "y" will advance to the next landmark, "n" will allow the user to place that landmark again (the "old" landmark will appear on the specimen, however, the recorded coordinates of the old landmark are replaced with the new coordinates). IMPORTANT: Be sure you have entered a "y" before proceeding to the next landmark - omission of a landmark will require you to start over with ALL landmark placement. After placing the number of landmarks defined in the function (nlandmarks = ), the user is prompted to advance to the next specimen. Upon completion of landmark placement on all specimens, a TPS file will be written to the directory specified in the function and the array of coordinates will be stored in the R environment. 

```r
## The landmark.images function initiates the landmarking process. In this example, 62 landmarks are placed: 7 traditional landmarks and 55 semilandmarks. 
specimen.LM <- landmark.images(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/", image.names = specimen.factors[,1], nlandmarks = 62, scale = 10, writedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/", tps.filename = "specimen_LM.TPS")

## A new array is defined containing the coordinates of the landmarks placed on the color standard in each image. These coordinates identify where on the standard to sample the known color values that will be used during the calibration process.
calib.LM <- landmark.images(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/", image.names = specimen.factors[,1], nlandmarks = 5, writedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/", tps.filename = "calib_LM.TPS")

```

#### 2.2.1.2 External landmark placement imported into the *Colormesh* environment
     
Landmarks can be placed using your geometric morphometric software of choice that generates a TPS file. Two TPS files will need to be created and imported: one having the coordinate data for landmarks placed around each specimen and another TPS file where landmarks were placed on the color standard. The function *tps2array* will read in the .TPS file containing landmark coordinate data and convert the information into the required array format.   

```r
## For clarity, we added .ext in the example code below to identify these data as coordinates that were imported into the Colormesh environment.  
specimen.LM.ext <-  tps2array("C:/Users/jennv/Desktop/Colormesh_test_jpg/orig_LM_jpg.TPS")

## The code below reads in the TPS file containing the coordinates for landmarks placed on the color standard contained within each specimen image. 
calib.LM.ext <-  tps2array("C:/Users/jennv/Desktop/Colormesh_test_jpg/calib_LM_jpg.TPS")
```


### 2.2.2  Transforming images to a consensus shape within *Colormesh*

Similar to landmark placement, images can be unwarped to a consensus shape either within the Colormesh environment (described below) or in your favorite geometric morphometrics software then imported into *Colormesh* for sampling (Section 2.3, below). Here, we describe the use of the *tps.unwarp* function to transform images to a consensus shape. This process generates two of the required files needed as input for the Colormesh Sampling Pipeline (Section 2.4): the array of landmark coordinates of the consensus shape and the set of images where specimens have been unwarped to a consensus shape.

Images that are unwarped to a consensus shape within the *Colormesh* environment must be of the same pixel dimensions (height x width). For example, our images are 4368 pixels x 2912 pixels. Unwarping to a consensus shape within *Colormesh* is performed by the *tps.unwarp* function. The function first performs a Generalized Procrustes Analysis by employing the utilities of the *geomorph* package. Then, the *imager* package is used to perform a thin-plate spline (TPS) image transformation. Finally, the resulting unwarped images are saved as PNG image format files in the directory specified by the user. 
 

#### 2.2.2.1  Define perimeter map and sliding landmarks (if any) 
     
The first step is to define the perimeter map of the specimen and identifying which landmarks, if any, are sliding landmarks (semilandmarks). This perimeter map tells *Colormesh* what order to read the landmarks so that a perimeter is drawn around the specimen in a "connect-the-dots" manner. This perimeter map is used in both the unwarping process for sliding landmarks and the Delaunay triangulation (described below) to determine sampling locations. In the guppy example below, the first seven landmarks that were placed around the guppy are the traditional landmarks (placed at locations that are easily identifiable among images); the remaining 55 landmarks are referred to as semilandmarks. Semilandmarks are interspersed between the traditional landmarks and allowed to slide along the tangent of the curve they create when generating a consensus shape. The *make.sliders* function identifies which landmarks are traditional landmarks, and therefore will not slide in the calculation.

```r
## Define perimeter map (order the points occur around the perimeter)
perimeter.map <- c(1, 8:17, 2, 18:19, 3, 20:27, 4, 28:42,5,43:52, 6, 53:54, 7, 55:62)

## Define sliders (main.lms = identifies which of all 62 landmarks are the traditional landmarks and therefore will NOT slide)
sliders <- make.sliders(perimeter.map, main.lms = 1:7)
```
![](images/perimeter_line_map.jpg)


#### 2.2.2.2  Calculating the consensus shape
        
The second step is to calculate the consensus shape of the specimens. Prior to running the *tps.unwarp* function, you will need to create a file folder as a destination for the function to write the unwarped images. The information required by the function includes: the directory containing the original specimen images that are to be unwarped to the consensus shape identified by the "imagedir" argument (note: these images must all have the same pixel dimensions). Also provided to the function are the landmark coordinate data array for the landmarks that were placed around each specimen contained in these images. To associate the coordinate data with the appropriate images, you must provide the image names from the CSV file (1st column). If you have defined landmarks that are semilandmarks, and therefore allowed to slide, they also need to be identified. And finally, you must provide the directory where Colormesh will write the unwarped images. These unwarped images will be saved as PNG images, which is an uncompressed (lossless) image format.

```r
## The example code below defines the landmark coordinate array generated in Section 2.2.1.1 (above)
unwarped.jpg <- tps.unwarp(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/", landmarks = specimen.LM, image.names = specimen.factors[,1], sliders = sliders , write.dir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/unwarped_images_jpg/")


## The example code below defines the landmark coordinate array generated in Section 2.2.1.2 (above) (see landmarks = specimen.LM.ext)
unwarped.jpg <- tps.unwarp(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/", landmarks = specimen.LM.ext, image.names = specimen.factors[,1], sliders = sliders , write.dir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/unwarped_images_jpg/")
```

The output of the function is a list having two elements. The "$target" element of the list is the landmark coordinate data for the consensus shape generated by the function. The names given to the unwarped images appear as the 2nd list element. The resulting unwarped images are written to the directory given by the user; these images are sampled in the Color Sampling Pipeline (Section 2.4, below). When image files are opened, specimens will now have the same shape. Note: Some black areas near the edges of the images are expected as they are part of the unwarping process.
     
![](images/IMG_7647_unwarped.jpg)
![](images/IMG_7652_unwarped.jpg)
![](images/IMG_7658_unwarped.jpg)

## 2.3  Image Processing was performed externally - importing the required files  

If the entirety of image processing (Landmark placement and unwarping to a consensus shape) are performed externally, *Colormesh* can import all of the required files for the Color Sampling Pipeline (Section 2.4). Below, we identify the required information to prepare for color sampling. This includes: 

   * Defining the perimeter map to be used when generating the sampling template (Delaunay triangulation). 
   * The specimen factors CSV: the unique unwarped image names must appear in the 2nd column, original image names appear in the 1st column.
   * The CSV having the known RGB values of the color standard.
   * The two required arrays containing landmark coordinate data: the coordinates of landmarks placed on the color standard and the other array will be the landmark coordinate data of the __CONSENSUS__ shape. These are imported using the *tps2array* function described above.
   * The two required images sets residing in their own folders. One image set is the original images (with the color standard) and the other image set is the unwarped images.  

```r
## Defining the perimeter map - this will be used in the Color Sampling pipeline. This is the order of the row of x,y coordinates that will connect the landmarks in a "connect-the-dots" manner
perimeter.map <- c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62)

## Example code for reading in the two CSV files 
## NOTE: First column = original image names, 2nd column = unwarped names
specimen.factors.ext <- read.csv("C:/Users/jennv/Desktop/Colormesh_test_jpg/specimen_factors_ext.csv", header = T) 
known.rgb <- read.csv("C:/Users/jennv/Desktop/Colormesh_test_jpg/known_RGB.csv", header = T) 

## Example code for converting TPS files to the appropriate array format
## NOTE: CONSENSUS SHAPE COORDINATES ONLY
consensus.LM.ext <- tps2array("C:/Users/jennv/Desktop/Colormesh_test_jpg/consensus_LM_coords.TPS") 
calib.LM.ext <- tps2array("C:/Users/jennv/Desktop/Colormesh_test_jpg/calib_LM_jpg.TPS")

## Create two image folders holding the two sets of images (the original images set for the calibration process and the unwarped image set for the Color Sampling pipeline). 
```


## 2.4  Color Sampling Pipeline

To proceed with color sampling, you should now have available to *Colormesh*: 
   * The two required CSV files (image information and known RGB values of the standard). 
   * The two landmark coordinate arrays: one having land mark coordinate data of the CONSENSUS SPECIMEN SHAPE and the other having the landmark coordinate data of where to sample the color standard for the calibration process.
   * Two sets of images located in their own directories: the set of images that were unwarped to the consensus shape and the original set of images containing the color standard. 

In the Color Sampling pipeline, there are two main processes: 1) defining the sampling templae (i.e., sampling density) and 2) defining the sampling circle size and measuring RGB values. For each of the processes, we have included seveal checks along the way. These include alignment checks to confirm the orientation of the image during the sampling process and overlapping of sampling circles. In addition, we provide several options for visualizing your plots under each section.   

### 2.4.1  Calculating the sampling template (sampling density)

*Colormesh* uses Delaunay triangulation as an unsupervised method of determining locations to sample color from the consensus shaped specimen images. The first round of Delaunay triangulation uses the landmark coordinates of the consensus shape as the vertices of the triangles. It reads in the landmark coordinates of this consensus based on the order defined in the *perimeter.map* variable. The function that creates this mesh was designed to provide the user with flexibility in sampling density based on the number of rounds of triangulation specified by the user; more rounds provide a greater density of sampling points.

Here's what an example of two, three, and four rounds of triangulation looks like:

![Triangulation example](images/DT.jpg)


#### 2.4.1.1  Generating the sampling template and checking alignment

The sampling template is generated by the *tri.surf* function and is an integer defined by the user. The *tri.surf* function calculates the X,Y coordinates of the centroid for each triangle generated by Delaunay triangulation; Colormesh calls on the *tripack*package to perform the Delaunay triangulation. If more than one round of triangulation is specified by the user, these centroids function as vertices for subsequent rounds of triangulation. At the completion of the user-specified rounds of triangulation, the pixel coordinate for each triangle's centroid is saved as sampling coordinates. The arguments defined in the function include: the array having the coordinates of the __consensus shape__, the perimeter map, a test image to check the alignment of the sampling template, and a logical argument to address whether to flip the y-coordinates (see below). By default, flip.delaunay = FALSE. Be sure your specimen.sampling.template is defined with the correct orientation (indicated by whether the triangulation overlay is properly aligned). The alignment check draws a yellow line around the perimeter of your specimen and red circles are plotted at the pixel coordinates that will be sampled (NOTE: circles are sized to be easily visible and do not represent the number of pixels that will be sampled). 

IMPORTANT: Test that your sampling points properly overlay your image. Image readers (e.g., EBImage & imager) place the 0,0 x,y-coordinate in the upper left corner. In contrast, the coordinates in the TPS file place 0,0 in the bottom left corner. Colormesh assumes this to be true. The example code below demonstrates how to load a test image and plot the sampling template over the image to check alignment. 


```r
## Reading in a test image using the imager package
align.test1 <- load.image("C:/Users/jennv/Desktop/Colormesh_test_jpg/unwarped_images_jpg/IMG_7658_unwarped.png")

## In the examples below, num.passes = 3 means three rounds of Delaunay Triangulation will be performed.
## Below shows example code using the consensus shape array that was calculated by the tps.unwarp function where unwarping was done within the Colormesh environment(Section 2.2.2, above). When flip.delaunay = F, the template was not aligned correctly; the tri.surp function was re-ran with flip.delaunay = T to define the specimen.sampling.template with the correct orientation.
specimen.sampling.template <- tri.surf(tri.object = unwarped.jpg$target, point.map = perimeter.map, num.passes = 3, corresponding.image = align.test1, flip.delaunay = F)
specimen.sampling.template <- tri.surf(tri.object = unwarped.jpg$target, point.map = perimeter.map, num.passes = 3, corresponding.image = align.test1, flip.delaunay = T)

## Below shows the example code if you imported the consensus specimen shape from a TPS file and converted it to an array (Section 2.3 above).
specimen.sampling.template <- tri.surf(tri.object = consensus.LM.ext, point.map = perimeter.map, num.passes = 3, corresponding.image = align.test1, flip.delaunay = T)
```

The images below show the alignment plot with the two outcomes of the flip.delaunay logical argument.

__Note: Images shown below differ from the previous images in this example - the image size and fish are different. These photos were selected to more clearly show correct/incorrect alignment.__

When flip.delaunay = FALSE and misaligned

![](images/test_image_flip_wrong.jpg)


When flip.delaunay = TRUE and aligned correctly

![](images/test_image_flip_right.jpg)


#### 2.4.1.2  Visualizing the sampling template

We have included the ability to plot the sampling template generated by the *tri.surf* function. The example code below shows how to plot the template where the specimen will be sampled. You may specify the style = "points" to plot the location of the all the points (perimeter and interior) that will be sampled, style = "perimeter" will print only the perimeter points, style = "interior" will plot only interior points, and style = "triangulation" will plot the triangulation that was generated and the centroids of each triangle. For style = "triangulation" you may change the color of the triangles that were generated (wireframe.color = ), as well as the color of the centroid (point.color = ).

_No overlay on image_

Plotting a map of all points (both the perimeter and interior) that will be sampled

```r
plot(specimen.sampling.template, style = "points")
```
![](images/template_points.jpg)

Plotting only the perimeter points
```r
plot(specimen.sampling.template, style = "perimeter")
```
![](images/template_perim.jpg)

Plotting only the interior points
```r
plot(specimen.sampling.template, style = "interior")
```
![](images/template_inter.jpg)

Plotting the map of the Delaunay trinagulation and the centroids of the triangles
```r
plot(specimen.sampling.template, style = "triangulation", wireframe.color = "black", point.color = "red")
```
![](images/template_triang.jpg)


_Overlay on image_

The "triangulation" style can be plotted overlaying the *align.test1* image (defined above). The following code shows how to make this plot. The default colors for both the "triangulation" and "overlay" styles draw the triangles in black and the sampling points (centroids) in red. However, The user can change the color of the triangles and centroids using the point.color =   and wireframe.color =  arguments.

__Note: The image used to show the "overlay" option differs from those used in the *tps.unwarp* example above. Here we used a cropped image, and different fish, to demonstrate this visualization option. __

```r
plot(specimen.sampling.template, corresponding.image = align.test1, style = "overlay", wireframe.color = "grey", point.color = "yellow" )

## NEED TO UPDATE IMAGE
```

![](images/specimen_template_overlay.jpg)


### 2.4.2 Setting the sampling circle size and measuring RGB

#### 2.4.2.1  Checking for overlapping sampling circles

Because sampling circle size is controlled by the user, we offer a diagnostic tool with the function *point.overlap*. The example code below demonstrates the use of this function to determine whether sampling circles of a given pixel radius (px.radius = ) will overlap. For example, a sampling circle with px.radius = 2 will have a sampling circle diameter of 5 pixels; the radius is 2 pixels out from the centroid pixel defined by the sampling template. If the sampling template (defined in Section 2.4.1) is dense, this may result in the overlap of sampling circles depending on their size. This function checks for overlap of sampling circles and produces a dataframe with the sampling point ID and the distance between the centroid pixels of those that overlap. This function also produces a plot showing sampling circles that overlap in red (Note: the circles of the plot are not drawn to scale).

```r
## The sampling template (specimen.sampling.template2) shown below is the result of 4 Delaunay triangulations and therefore more dense. A pixel radius of 2 (px.radius = 2) results in some sampling circles that overlap (see diagnostic plot below). The point ID is supplied in a dataframe produced by the function.

overlap = point.overlap(delaunay.map = specimen.sampling.template2, px.radius = 2, style = "points")
```
![](images/overlap.jpg)

#### 2.4.2.2  Measuring RGB values
The *rgb.measure* function measures the RGB values of the points sampled from the unwarped specimen images (at the points identified above in the *tri.surf* function). To control the size of the sampling circle, the user provides the radius length (in pixels) out from the centroid, from which to sample the surrounding pixels. In this function, the user first provides the file path to the folder containing the unwarped (to the consensus shape) images that are to be sampled, followed unwarped image names, next is the "specimen.sampling.template" (which provides sampling coordinates), an integer for the user-specified size of the sampling circle **radius** in pixels (px.radius = 0 will only sample the centroid pixel), and the logical argument for whether you would like to apply the linear transform (based on international standard IEC 61966-2-1:1999),to convert sRGB values to linearized values. 

```r
## The example code below uses the unwarped image names generated within Colormesh by the tps.unwarp function (Section 2.2.2, above)
## NOTE: We use the specimen.sampling.template defined by 3 rounds of Delaunay trinagulation below
uncalib_RGB <- rgb.measure(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/unwarped_images_jpg/", image.names = unwarped.jpg$unwarped.names, delaunay.map = specimen.sampling.template, px.radius = 2, linearize.color.space = FALSE)

## If unwarped images were generated externally, the image names will come from the 2nd column of the csv file
uncalib_RGB <- rgb.measure(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/unwarped_images_jpg/", image.names = specimen.factors[,2], delaunay.map = specimen.sampling.template, px.radius = 2, linearize.color.space = FALSE)


## If the color values of the image are in sRGB colorspace, the values can be linearized setting linearie.color.space = TRUE 
linear_uncalib_RGB <- rgb.measure(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/unwarped_images_jpg/", image.names = unwarped.jpg$unwarped.names, delaunay.map = specimen.sampling.template, px.radius = 2, linearize.color.space = TRUE)
```

#### 2.4.2.3 Visualizing the sampled color

The example code below will plot the color sampled using the *rgb.measure* function. The "individual = " argument allows you to plot a specific specimen. The default of style = "points" which plots the color values that were sampled from the image (perimeter and interior). Similar to the plotting options above, you have the option of only plotting the perimeter or the interior points.  To compare your plotted sampled color values to the original image the color values were sampled from, set style = "comparison". Note that a plot of sampled values where linearize.color.space = TRUE will be darker than the original image due to the application of the linear transform.

Plotting measured color at all points
```r
plot(uncalib_RGB, individual = 8, style = "points")
```
![](images/uncalib_points.jpg)

Plotting measured color at only the perimeter points
```r
plot(uncalib_RGB, individual = 8, style = "perimeter")
```
![](images/uncalib_perim.jpg)

Plotting measured color at only the interior points
```r
plot(uncalib_RGB, individual = 8, style = "interior")
```
![](images/uncalib_inter.jpg)

Plotting measured color at all points along with the image the color was sampled from 
```r
plot(uncalib_RGB, individual = 8, style = "comparison")
```
![](images/uncalib_comp.jpg)

The plots shown above can be used to visualize your linearized color data as well. We show the "points" plot below.
*Note: Plotting the linearized measured color; these will appear darker*
```r
plot(linear_uncalib_RGB, individual = 8, style = "points")
```
![](images/linear_uncalib_points.jpg)


## 2.5  Color calibration

Color information across images can be pretty noisy due to inconsistent lighting, different camera settings, movement of the object, etc. We highly recommend adjusting for those differences by including a color standard in each image. Using the differences in color standard values between images to mitigate variation due to noise, landmarks placed on the color standard are used to sample known RGB values and adjust the sampled color of your specimen by the average deviation in each color channel.  

*Colormesh* uses the coordinates of landmarks placed on the standard in each image to sample known color values. Prior to calibration, it is important to check the alignment of the sampling coordinates and the images. Once you have determined whether an alignment correction must be made, the *rgb.calibrate* function can then be used to correct each image's measured RGB values. The function samples the color standards of each image at the coordinates supplied by the calibration array. An image-specific color correction vector is calculated based on the mean deviation of each color channel from the known RGB values of the color standard in that image. The correction vector is then applied to the measured RGB values of each image. 


### 2.5.1  Checking the alignment for sampling

Prior to calibrating each image, it is important to check that the sampling locations align with the color standard in the image. The code below plots colored dots at the locations where color will be sampled in the image. The user has the option to change the size and color of the dots that are plotted. This is a simple test to confirm the y-axis coordinates are correct. In the example below, yellow points are plotted over the locations that will be sampled for color calibration. By default, the logical argument for flip.y.values = F; if your points appear at the top of your image (bottom image), set flip.y.values = T. The images below demonstrate what to expect for the F/T argument. The calib.plot function enables the user to determine what this parameter should be set to in the rgb.calibrate function (below). 
  
```r
## Plot a test image to check that the landmark coordinates are aligned correctly over the standard. We specified the point color and size to make them visible
calib.plot(imagedir = "C:/Users/jennv/Desktop/Colormesh_test_jpg/", image.names = specimen.factors[ ,1], calib.file = calib.LM, individual = 3, col = "yellow", cex = 1, flip.y.values = F)
```
![](images/calib_align.jpg)
![](images/calib_align_2.jpg)

### 2.5.2  Calibrating the measured RGB values

For the *rgb.calibrate* function, the user first provides the name of the data that is to be calibrated, for example, "uncalib_RGB". Then the user provides the file path to the folder containing the original images (imagedir =). Next, "image.names = " is defined by providing the column containing the calibration image names from the csv containing this information. The coordinates of where to sample the color standard are defined as "calib.file = ". The logical argument for "flip.y.values" is available if the test image that is plotted shows that the y-coordinates need to be corrected (determined in the previous step with the calib.plot function). Finally, "color.standard.values = " is defined as the csv containing the known RGB values for the color standard. By default, the sampling circle that samples each color standard has a default radius = 2 pixels. You can change the size of the sampling circle with an integer when defining "px.radius = " as shown in the example code below. 
*Note: If the calib.plot function showed proper alignment, set flip.y.values = F*

```r
calib_RGB <- rgb.calibrate(uncalib_RGB, imagedir =  "C:/Users/jennv/Desktop/Colormesh_test_jpg/", image.names = specimen.factors[ ,1], calib.file = calib.LM.ext, flip.y.values = F, color.standard.values = known.rgb)

##  By default, the radius of the sampling circle is = 2. The user can change the sampling circle size by providing a different integer. 
calib_RGB <- rgb.calibrate(uncalib_RGB, imagedir =  "C:/Users/jennv/Desktop/Colormesh_test_jpg/", image.names = specimen.factors[ ,1], calib.file = calib.LM.ext, flip.y.values = F, color.standard.values = known.rgb, px.radius = 3)
```

To calibrate measured RGB values where linearize.color.space = TRUE, the *rgb.calibrate* function is used in the same manner. The *rgb.calibrate* function detects that this data was linearized  because the logical in the list produced from the *rgb.measure* function = TRUE. When detected, both the known RGB values and the color measured from the color standard will be linearized prior to calculating the mean deviation from the known RGB values. This linearized color correction will then be applied to the linearized values collected from the specimen images.

```r
linear_calib_RGB <- rgb.calibrate(linear_uncalib_RGB, imagedir =  "C:/Users/jennv/Desktop/Colormesh_test_jpg/", image.names = specimen.factors[ ,1], calib.file = calib.LM.ext, flip.y.values = F, color.standard.values = known.rgb)
```


### 2.5.3  Visualizing the calibrated color

To plot your calibrated colors, you have the same options as above. With style = "points" both perimeter and interior points where color has been calibrated will be plotted. To print just the perimeter, style = "perimeter". With style = "interior" only the interior calibrated color values will be plotted. The __exception__ is with the comparison plot. In the comparison plot, it compares the calibrated points to the uncalibrated points when style = "comparison". 


```r
## Plotting calibrated color values with style = "points"
plot(calib_RGB, individual = 5, style = "points")

## Plotting calibrated color values with style = "perimeter"
plot(calib_RGB, individual = 5, style = "perimeter")

## Plotting calibrated color values with style = "interior"
plot(calib_RGB, individual = 5, style = "interior")

## EXCEPTION: This plot compares uncalibrated and calibrated color values
##Plotting calibrated color values with style = "comparison"
plot(calib_RGB, individual = 5, style = "comparison")
```
![](images/calib_uncalib_comparison.jpg)

Linearized values can be plotted, as well. 
*Note: Linearized RGB values will have a darker appearance.* 

```r
## Plotting linearized calibrated color values with style = "points"
plot(linear_calib_RGB, individual = 3, style = "points")

## Plotting linearized calibrated color values with style = "perimeter"
plot(linear_calib_RGB, individual = 3, style = "perimeter")

##Plotting linearized calibrated color values with style = "interior"
plot(linear_calib_RGB, individual = 3, style = "interior")

##Plotting linearized calibrated color values with style = "comparison"
plot(linear_calib_RGB, individual = 3, style = "comparison")
```


# __3. Extracting your data__

We created a simple function, *make.colormesh.dataset*, to compile your data into a single dataframe. The user specifies which dataset they would like to include, the csv containing the specimen information, and lastly, a logical argument (TRUE/FALSE) as to whether perimeter point data is included. 

This dataframe will give individual specimens in rows. It will combine the image information csv file to the beginning of the data set. Following these columns, the measured values specific to each sampling point will be provided. After these columns, the x,y coordinate of each sampling point will be given. 

```r
## Saves to your R environment
final.df.uncalib <- make.colormesh.dataset(df = uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T)

## If you would like to write this datafram to a .csv file, include the file path where you would like the file to be saved following the write2csv argument. 
final.df.uncalib.saved <- make.colormesh.dataset(df = uncalib_RGB, specimen.factors = specimen.factors, use.perimeter.data = T, write2csv = "C:/Users/jennv/Desktop/Colormesh_test_jpg/colormesh_data_uncalib.csv")
```

