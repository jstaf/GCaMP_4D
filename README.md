# GCaMP_4D
An algorithm to parse and analyze 4-dimensional microscopy data

![Imgur](http://i.imgur.com/aVy7xWW.png)

## How it works

The expected input is a confocal file containing a series of passes through a specimen. The stack is opened using [BioFormats](https://www.openmicroscopy.org/site/support/bio-formats5.1/about/index.html). Using metadata included in the file, the stack is formatted into a series of 3D images, each representing one "pass" through the specimen. Each pass is then "flattened" to a single maximum projection (each pixel is the vertical maximum of all the pixels at that position in the stack) and then denoised using a gaussian filter. 

When a foreground and background pass are compared, the images are first "stabilized" using [the SURF algorithm](http://www.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html). This ensures that the features in each pass actually line up, even though the specimen may have moved. Once stabilization is complete, the difference between the images is computed and displayed back to the user.

The basic forumula used to compute the difference between images is: 

**delta_image = (foreground ./ background) * 100 - 100**

## Installation

Either download this package or clone this repository using git (recommended). Run GCaMP_4D.m or GCaMP_4D.fig in MATLAB. It's that easy.

## Use

To analyze a 4D confocal video
+ Open a file with the `Open file` button.
+ Select a stack to analyze in the drop down box
+ Select a foreground pass
+ Select a background pass

The display should automatically update as you change the `Foreground Pass` or `Background Pass` dialogs.
