# Colormesh
An R package for extraction of color data from digital images.

## Installation

We strongly recommend you build the included vignette when installing the package. It provides a quick workflow with 10 images of guppies that originated from two populations to use as examples. Copy and paste the code below to install the package with the vignette:

```r
devtools::install_github("j0vid/Colormesh", build_vignettes = T)
```

The following command allows you to view the vignette:


```r
##################### I need to send you the images, csv file, and appropriate TPS files for you to include  ########################################
vignette("Guppy-images”)

```

### Using Colormesh (V1.0)

At this time, Colormesh requires that image processing using geometric morphometrics software take place prior to use. The guppy examples provided in the vignette were processed using the TPS Series software by James Rohlf, availble for free at the Stonybrook Morphometrics website (http://www.sbmorphometrics.org/). The TPS software was used for landmark placement and unwarping of images to a consensus shape. The rersulting files described below include TPS files, which contain landmark x,y coordinates, and the resulting unwarped images of each specimen to be sampled by Colormesh. 

### Required files for Colormesh (V1.0)
To prepare images for RGB color data sampling using Delaunay Triangulation, prepare the following folders and files:

  1. A .csv file containing factors that uniquely identify specimen images. This .csv file should omit the row names and column headers. This .csv file will be used as a check to ensure the calibration correction is applied to the appropriate image. The first column MUST be the image name of the original images (prior to unwarping to the consensus shape) used to place landmarks on the color standard; the names of these original images MUST be unique. The second column MUST contain the unique image name of the "unwarped" (to the consensus shape) version of the specimen image. This .csv file must contain at least these two columns and appear in the order described here. Any additional columns containing factors needed for your organization or identification (e.g., population name) can be included after these two columns.
  
  2. A .csv file containing the known RGB values of the colors on the color standard to be used for calibration. They should be on a scale of 0 to 1. Each column is a color on the standard, each row is a color channel; the know R, G, and B values must appear in rows 1, 2, and 3, respectively. If known RGB values are on a scale of 0-255, simply divide by 255 to convert values to the proper scale.
  
  3. A file folder containing: the original images that show the color standard AND the TPS file that was generated by placing landmarks on each of the colors of the standard. The image names must match the names that appear in the 1st column of the .csv (#1 above). 

  4. A file containing: the unwarped (to a consensus shape) images of each specimen AND the TPS file containing the coordinates of the landmarks for this consensus shape. The image names must match the name that appear in the 2nd column of the .csv file (#1 above). These images are produced by image processing in a geometric morphometrics program (ex. tpsSuper). Since all images were unwarped to this consensus shape, this TPS will only contain the number of coordinates equal to the number of landmarks placed around your specimen.


### Reading in .csv files
Code below loads in the two csv files needed to use the Colormesh package to extract color data: 

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
### Reading in .TPS files

The function "tps2array" will read in the .TPS file which contains landmark coordinates and converts the information 
   into an array to be used in later functions.

```r

## The code below reads in the coordinates of the consensus specimen shape

consensus.array = tps2array(data= "C:/Users/jennv/Desktop/Colormesh_Test_2/consensus_LM_coords.TPS")


## The code below reads in the TPS file containing the coordinates for landmarks placed on the color
## standard contained withing the original images. 

calib.array = tps2array("C:/Users/jennv/Desktop/Colormesh_Test_2/calib_images/calib_LM_coords.TPS")

```


### Determining sampling density

Colormesh uses Delaunay triangulation to determine locations to samples color. The first round of Delaunay triangulation uses the landmark coordinates of the consensus shape as the vertices of the triangles. The function that creates this mesh was designed to provide the user with flexibility in sampling density based on the number of rounds of triangulation specified by the user; more rounds provides a greater density of sampling points. This is accomplished by using the centroids of the triangles created from the first round of Delaunay triangulation as the vertices for subsequent rounds of triangulation. 

Here's what an example of two, three, and four rounds of triangulation looks like:

![Triangulation example](images/DT.png)


### Generating the sampling template

Colormesh needs to know what order to read the landmarks in so that a perimeter is drawn around the specimen in a "connect-the-dots" manner.

```{r}

perimeter.map <- c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62)

```

## Generating and checking alignment of the sampling template

## IMPORTANT: Test that your sampling mesh properly overlays on your image you want to sample. 
## Image readers place the 0,0 x,y-coordinate in the upper left corner. In contrast, the coordinates in the TPS
## file place 0,0 in the bottom left corner. Colormesh assumes this to be true. To check this, the code below
## is used to read in a test image and then plot the Delaunay triangulation wire-frame on top of the image to
## ensure that you're properly sampling the image. This code will generate a plot for you to visualize your
## proposed sampling locations.



### Identifying sampling location using Delaunay triangulation
To initiate the first round of Delaunay triangulation, you will need a point map. A point map is a vector that specifies the order of your landmarks.
In the image below, we placed seven initial landmarks at locations that were easily identifiable on each specimen (snout, connection points of the dorsal and tail fins, and gonopodium) followed by 55 additional landmarks that were designated as sliding landmarks during the unwarping process. These 62 total landmarks provided the outline around the specimen. Thus, our point map to make a continuous perimeter is defined as follows:

## Specify the order of the point ID's to generate an outline

perimeter.map <- c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62)

![Outline example](images/outline.png)


The tri.surf function (within the Colormesh package) identifies the X,Y coordinates of the centroid for each triangle generated by Delaunay triangulation. If more than one round of triangulation is specified by the user, these centroids function as vertices for subsequent rounds of triangulation. The final matrix of coordinates generated by the user-defined number of rounds of triangulation (density of sampling) is stored for use in sampling color from the unwarped images. 



```{r}

######### DAVID CORRECTED THE DEPENDECIES SO THAT IT WILL LOAD TRIPACK and SP - DAVID, CONFIRM
## Using the tri.surf function (Colormesh), we generate a mesh of sampling locations across our specimen. This is done by identying the point map, landmark coordinates to be read by row, and number of rounds of triangulation

## This will result in a matrix of landmark coordinates for the sampling locations on the specimen. This is the X,Y coordinates of the pixel located at the centroid of each triangle that was created after performing the user-specified number of rounds of triangulation. In the example below, 2 rounds of Delaunay triangulation were performed.

specimen.sampling.template = tri.surf(consensus.coords[perimeter.map,], 2)


```

################## DAVID, THIS IS WHERE THE NEW FUNCTION WOULD GO ##########################

Using the sampling template generated with the tri.surf function above, the user now will define the size of the sampling circle in pixels. The pixels identified by the tri.surf function are used as the focus (center) of the circle having a radius defined by the user. This provides the user with control over the level of pixel averaging. If sampling circles overlap and therefore a pixel is re-sampled, the user will be notified. The output of the davids.measure.function below is calculated by sampling averaging each color channel for the pixels contained within the sampling circle. 

```{r}

########################### NEW FUNCTION HERE #################################
##
uncalibrated.color.sample = <what ever function parameters needed, will need consensus_image_file_location, unwarped_image_name (which is column 2 from the csv, specimen_sampling_template to get the coords of the pixels to sample, and sampling.circle(2) to allow the user to specify sample circle size


################## The output should be a matrix with the number of rows equal to the number of specimens. Columns would equal the RED value sampled from each of the points (defined by the number of triangulations, cbind to the Green, cbind to the Blue.


```

### Color calibration

Color information across images can be pretty noisy due to inconsistent lighting, different camera settings, movement of the object, etc. We highly recommend adjusting for those differences by including a color standard in each image. Using the differences in color standard values between images to mitigate variation due to noise, landmarks placed on the color standard are used to sample known RGB values and adjust the sampled color of your specimen by the average deviation in each color channel. (see ```vignette("Calibrate-images")```). 

####################################### THIS WILL BE A NEW FUNCTION BY DAVID THAT WILL TAKE CARE OF THE UGLY R CODE #######################################
####################################### DAVID SEE COMMENTS BELOW
######### Above, the user already define the variables: known.RGB and calib.coords
######### THIS INCORPORATES A SAMPLING CIRCLE FUNCTION, SET DEFAULT TO 2 PIX, BUT HAVE OPTION FOR USER TO CHANGE THE SAMPLING CIRCLE RADIUS

```{r}

########################### NEW FUNCTION HERE #################################
########################### DAVID, CAN A CHECK BE PERFORMED HERE THAT THE DEVIATION MEASURED IN THE CALIBRATION IMAGE (COLUMN 1 of the factors.csv file) IS BEING APPLIED TO THE CORRECT VECTOR OF COLOR SAMPLED  FROM THE UNWARPED IMAGE (COLUMN 2 OF THE FACTORS.CSV)? 

corrected.color.sample = <what ever the new function is> (will need uncalibrated.color.sample, known.RGB, factors.csv?, calibration_sampling_circle_size)


################## The output should be a new matrix, same dimensions as the uncalibrated.color.sample matrix. However, it will have the correction applied. As a check, I compare these to make sure some adjustment has happened.


```
### Visualizing the color sampled and the correction to the color following the calibration process.

############################## DAVID, SEE COMMENTS BELOW
############### Have the option to show the plot even if someone didn't do color calibration. I can think of some instances where images will not have a color standard included. 
############### Create a before and after plotting function to show original image (based on original measurements collected from DT collection of data, vs the image plot showing the values after the calibration correction was applied. So there is a side by side comparison)

###### DAVID, SHOULD PROBABLY Set something up for the bibtex so that if someone uses it, it will provide how to cite the package
