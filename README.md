# GCaMP_4D
An algorithm to parse and analyze 4-dimensional microscopy data

![Imgur](http://i.imgur.com/aVy7xWW.png)

## How it works

The expected input is a confocal file containing a series of passes through a specimen. The stack is opened using [BioFormats](https://www.openmicroscopy.org/site/support/bio-formats5.1/about/index.html). Using metadata included in the file, the stack is formatted into a series of 3D images, each representing one "pass" through the specimen. Each pass is then "flattened" to a single maximum projection (each pixel is the vertical maximum of all the pixels at that position in the stack) and then denoised using a gaussian filter. 

When a foreground and background pass are compared, the images are first "stabilized" using [the SURF/MSAC algorithms](http://www.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html). This ensures that the features in each pass actually line up, even though the specimen may have moved. Once stabilization is complete, the difference between the images is computed and displayed back to the user. The formula for image subtraction is as follows: 

```{MATLAB} 
(foreground - background) ./ background * 100
```

## Installation

Either download this package or clone this repository using git (recommended). Run GCaMP_4D.m or GCaMP_4D.fig in MATLAB. It's that easy.

## How to use

To analyze a 4D confocal video
+ Open a file with the `Open file` button.
+ Select a stack to analyze in the drop down box
+ Select a foreground pass
+ Select a background pass

The display should automatically update as you change the `Foreground Pass` or `Background Pass` dialogs.

If you want to view an individual pass, uncheck the box next to the background pass. Only the foreground pass will be displayed. You can toggle between modes with that checkbox.

![Imgur](http://i.imgur.com/ZoiiUio.png)

### Tips 

+ If an image appears misaligned (there are two identically shaped features in close proximity, but one is blue and one is red), it probably *is* misaligned. Just reselect the passes you are analyzing and it will attempt to re-align things. This fixes bad alignments most of the time.
+ If you want to export an image (either for comparison to another image or to just save), hit the `Export Display` button. This creates an identical copy of what you're seeing in a new window all by itself. This has the added benefit of if you make changes to the image before you export it, it won't mess up the rest of the application (the application is a MATLAB figure, and can be messed up if you start trying to change axes/colormaps there).
+ To alter the colormap, right click on it and select `Interactive Colormap Shift`. You can now change the colormap by clicking and dragging. You can alternatively select an entirely different colormap with `Standard Colormaps`.
+ If you are seeing a bunch of orange text when you load an image, it's because BioFormats thinks MATLAB hasn't allocated enough Java heap space. Follow the directions in the orange text to fix this.
