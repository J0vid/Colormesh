# Colormesh
An R package for extraction of color data from digital images.

## Installation

We strongly recommend you build the included vignette when installing the package. It provides a quick workflow with 10 images of guppies that originated from two populations to use as examples. Copy and paste the code below to install the package with the vignette:

```r
library(devtools) ############### DAVID, DOES IT MAKE SENSE TO ADD THIS?? #############
devtools::install_github("j0vid/Colormesh", build_vignettes = T)

```

The following command allows you to view the vignette:


```r
##################### I need to send you the images, csv file, and appropriate TPS files for you to include  ########################################
vignette("Guppy-images”)

```

## Using Colormesh

To prepare images for RGB color data sampling using Delaunay Triangulation, prepare the following folders and files:

  1. A .csv file containing factors to uniquely identify specimen images with column names omitted. This csv file will be used as a check to ensure the calibration correction is applied to the appropriate image, therefore the file type extension will be ignored if it is included. The first column must contain a unique image name of each original (prior to unwarping to the consensus shape) image. The second column should contain the unique image name of the "unwarped" (to the consensus shape) version of the image. The .csv file must contain at least these two columns and appear in the order described here. Any additional columns containing factors needed for your organization or identification (e.g., population name) can be included. They may be in any order as they will not be called during the color data extraction process.
  
  2. A folder containing the specimen images that were unwarped to the consensus shape AND the TPS file containing the coordinates of the landmarks for this consensus shape. The image file names must match the image names contained in the first column of the .csv file (described in #1 above). At this time, the landmark coordinates must be saved as a TPS file type. Note: This TPS file will have the X,Y coordinates of the landmarks for one specimen since unwarping to the consensus shape results in all specimens having the same landmark coordinates.  ################# NEED TO TEST THAT ORDER IN CSV FILE CAN BE DIFFERENT THAN ORDER OF IMAGES IN FILE ############################
  
  3. For color calibration, create a separate file filder containing the original specimen images (containing color standard) and the TPS file containing the coordinates of landmarks that were placed on the color standard. 
  
  4. A .csv file containing the known RGB values of the colors on the color standard in the order in which they were landmarked (omit column names). The number of columns must equal the number of landmarks placed on the color standard (i.e., the number of colors), the first row must contain the R (red) value for each color standard, the second row contains all the G (green) values, and the 3rd row the B (blue) values. These values should be on the scale of 0 to 1. Often, known values of each color channel are out of 255. For example, napthal crimson has a known RGB value of: 173/43/50. These are the red, green, and blue values, respectively, out of 255. To convert these values to the appropriate scale, divdide each value by 255: R: 173/255 = 0.6784; G: 43/255 = 0.1686; B: 50/255 = 0.1961. (See the first column of our example, known_RGB.csv).


```r
## Defining the variable described above.

## Using the read.csv function (base R), read in the csv file containing the indentification information of your specimens.
## Be sure the unique names of original images are in first column and the second column contains the unique names of the unwarped images that correspond to those in the first column. 

specimen.factors = read.csv("C:/Users/jennv/Desktop/CM_test/specimen_factors.csv", header = F) 



## Using the read.tps function (Colormesh package), read in the TPS file containing the landmark coordinates for the consensus shape

consensus.coords = read.tps(data= "C:/Users/jennv/Desktop/CM_test/consensus_LM_coords.TPS")


## Using the read.csv function (base R), read in the csv file containing the known RGB values of the colors contained in the color standard

known.rgb = read.csv("C:/Users/jennv/Desktop/CM_test/known_RGB.csv", header = F) 




## Using the read.tps function (Colormesh package), read in the TPS file containing the landmark coordinates for the consensus shape

calib.coords = read.tps(data= "C:/Users/jennv/Desktop/CM_test/calib_LM_coords.TPS")


#############################################################################################################################################################################
################################ DAVID, DOES THE READ.TPS FUNCTION NOW QUERY THE IMAGE DIMENSIONS AND SUBTRACT THE Y-VALUE TO MAKE THE Y-AXIS CORRECTION WITHIN THE FUNCTION?
#####################################################################

```
################################### DAVID, HOW TO WE MAKE THESE FILES AVAILABLE FOR PEOPLE TO DOWNLOAD SO THEY CAN WORK THROUGH THE EXAMPLE? #########################

### Color sampling

Colormesh samples color by generating a mesh overlay using Delaunay triangulation. The first round of Delaunay triangulation uses the landmark coordinates of the consensus shape (from the TPS file). The function that creates this mesh was designed to provide the user with flexibility in sampling density based on the number of rounds of triangulation (more rounds provides a greater density of sampling points). This function uses the centroids of the triangles created from the first round of Delaunay triangulation as new points for subsequent rounds of triangulation. 

Here's what it looks like:

![Triangulation example](images/DT.png)

####################### DAVID, IN THE CALL FOR THE IMAGE OUTLINE ABOVE, DO WE HAVE THE OUTLINE POINTING THE SAME DIRECTION AS THE FISH IN THE IMAGES (SNOUT TO THE RIGHT), ALSO IS THE ASPECT RATIO CORRECT? ########

### Identifying sampling location using Delaunay triangulation
To initiate the first round of Delaunay triangulation, you will need a point map. A point map is a vector that specifies the order of your landmarks.
In the image below, we placed seven initial landmarks at locations that were easily identifiable on each specimen (snout, connection points of the dorsal and tail fins, and gonopodium) followed by 55 additional landmarks that were designated as sliding landmarks during the unwarping process. These 62 total landmarks provided the outline around the specimen. Thus, our point map to make a continuous perimeter is defined as follows:

## Specify the order of the point ID's to generate an outline

perimeter.map <- c(1,8:17,2, 18:19,3,20:27,4, 28:42,5,43:52,6,53:54,7,55:62)

![Outline example](images/outline.png)


The tri.surf function (Colormesh) identifies the X,Y coordinates of the centroid for each triangle generated by Delaunay triangulation. If more than one round of triangulation is specified by the user, these centroids function as vertices for subsequent rounds of triangulation. The final matrix of coordinates generated by the user-defined number of rounds of triangulation (density of sampling) is stored for use in sampling color from the unwarped images. 



```{r}

######### DAVID CORRECTED THE DEPENDECIES SO THAT IT WILL LOAD TRIPACK and SP - DAVID, CONFIRM
## Using the tri.surf function (Colormesh), we generate a mesh of sampling locations across our specimen. This is done by identying the point map, landmark coordinates to be read by row, and number of rounds of triangulation

## This will result in a matrix of landmark coordinates for the sampling locations on the specimen. This is the X,Y coordinates of the pixel located at the centroid of each triangle that was created after performing the user-specified number of rounds of triangulation. In the example below, 2 rounds of Delaunay triangulation were performed.

specimen.sampling.template = tri.surf(consensus_LM_coords[perimeter.map,], 2)


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
