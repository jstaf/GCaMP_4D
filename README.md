# GCaMP_4D
An algorithm to parse and analyze 4-dimensional microscopy data

![Imgur](http://i.imgur.com/exyLUPW.gifv)

A pair of neuronal projections fluorescing in response to a stimuli in a 3D viewfield. (Sorry for the potato quality .gifs, but they're the only way GitHub will let me show a video.)

## How it works

The expected input is a confocal file containing a series of passes through a specimen. The stack is opened using [BioFormats](https://www.openmicroscopy.org/site/support/bio-formats5.1/about/index.html). Using metadata included in the file, the stack is formatted into a series of 3D images, each representing one "pass" through the specimen. Passes can be viewed in either 2D or 3D. When viewing in 2D, each pass is "flattened" to a single maximum projection (each pixel is the vertical maximum of all the pixels at that position in the stack).

Importantly, this algorithm is able to perform 3D field subtraction. An entire 3D foreground pass can be compared to a 3D background pass. To make this possible, every image in each Z-stack/pass are first "stabilized" using [the SURF/MSAC algorithms](http://www.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html). This ensures that the features in each pass actually line up, even though the specimen may have shaken or moved during imaging. Once stabilization is complete, the difference between the images is computed and displayed back to the user after gaussian denoising. This 3D field subtraction algorithm is applied regardless of whether or not you are viewing a sample in 2D or 3D. The formula for image subtraction is as follows (and occurs on a per-pixel basis): 

```{MATLAB} 
(foreground - background) ./ background * 100
```

**2D subtraction**
![](http://i.imgur.com/YRFScQS.gifv)

**3D subtraction**
![](http://i.imgur.com/ClR0ubh.gifv)

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

![](http://i.imgur.com/ZoiiUio.png)

Raw, unfiltered "single-pass" fluorescence.

### Tips 

+ If an image appears misaligned (there are two identically shaped features in close proximity, but one is blue and one is red), it probably *is* misaligned. Just reselect the passes you are analyzing and it will attempt to re-align things. This fixes bad alignments most of the time.
+ If you want to export an image (either for comparison to another image or to just save), hit the `Export Display` button. This creates an identical copy of what you're seeing in a new window all by itself. This has the added benefit of if you make changes to the image before you export it, it won't mess up the rest of the application (the application is a MATLAB figure, and can be messed up if you start trying to change axes/colormaps there).
+ To alter the colormap, right click on it and select `Interactive Colormap Shift`. You can now change the colormap by clicking and dragging. You can alternatively select an entirely different colormap with `Standard Colormaps`.
+ If you are seeing a bunch of orange text when you load an image, it's because BioFormats thinks MATLAB hasn't allocated enough Java heap space. Follow the directions in the orange text to fix this.
