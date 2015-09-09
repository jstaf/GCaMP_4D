# GCaMP_4D
An algorithm to parse and analyze 4-dimensional microscopy data. 

GCaMP4D allows you to view and analyze microscopy data in a truly 3D manner, allowing you to use older equipment like confocal microscopes in a manner that has previously only been possible with newer equipment (like light-sheet microscopes). This is particularly useful when paired with temporal data such as that produced by the GCaMP calcium sensor. Whereas traditional data analysis (or the human eye) might be unable to find changes in fluorescence between two timepoints, GCaMP_4D is much more sensitive, and considers the entire 3D field. Can't tell if one or more cell bodies are doing something because they're all on top of each other? No problem, GCaMP_4D can see through the mess and identify if any given cell is up to something. You can even make videos of the entire 3D space over time.

![Imgur](http://i.imgur.com/7sx1GVZ.png)

A screenshot of the program displaying a Z-stack of several neurons and their projections in 3D. You can see 2D and 3D differences between this pass and a later timepoint below (theres a gif of the changes over time at the very bottom of this readme).

## How it works

The expected input is any microscopy file that can be opened using [BioFormats](http://www.openmicroscopy.org/site/support/bio-formats5.1/supported-formats.html). Using metadata included in the file, the stack is formatted into a series of 3D images, each representing one "pass" through the specimen. Passes can be viewed in either 2D or 3D. When viewing in 2D, each pass is "flattened" to a single maximum projection (each pixel is the vertical maximum of all the pixels at that position in the stack).

Importantly, this algorithm is able to perform 3D field subtraction. An entire 3D foreground pass can be compared to a 3D background pass. To make this possible, every image in each Z-stack/pass are first "stabilized" using [the SURF/MSAC algorithms](http://www.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html). This ensures that the features in each pass actually line up, even though the specimen may have shaken or moved during imaging. Once stabilization is complete, the difference between the images is computed and displayed back to the user after gaussian denoising. This 3D field subtraction algorithm is applied regardless of whether or not you are viewing a sample in 2D or 3D. The formula for image subtraction is as follows (and occurs on a per-pixel basis): 

```{MATLAB} 
(foreground - background) ./ background * 100
```

**2D subtraction**  

![Imgur](http://i.imgur.com/oyG6aWa.png)

**3D subtraction**  

![Imgur](http://i.imgur.com/S5EFoV7.png)

## Installation

Either download this package or clone this repository using git (recommended). Run GCaMP_4D.m or GCaMP_4D.fig in MATLAB. It's that easy. (Pretty sure you'll need the Image Processing and Computer Vision toolboxes though.)

If you don't have MATLAB, you can get standalone versions of this software [here](https://github.com/kazi11/GCaMP_4D/releases).

## How to use

To analyze a new piece of data
+ Open a file with the `Open file` button.
+ Select a stack to analyze in the drop down box
+ Select a viewing mode
+ Select a foreground pass
+ Select a background pass if you want to perform image subtraction. If you turn the background pass on with the checkbox, subtraction will be performed.
+ The colorspace settings control how fluorescence/changes in fluorescence are displayed. You can change the axes limits here, and in 3D mode, this will control the transparency of 3D objects, allowing you to filter out and see through dimmer objects. You can automatically set these values using the "Autoscale" button.
+ You can rotate the 3D display using the sliders next to the display (does nothing in 2D mode).
+ You can export an image using the "Export Display" button.
+ You can export a video using the "Export Video" button. The program will then create a video  with one frame for every pass through the specimen (framerate is time it took to image each pass, determined using metadata in the file). If subtraction is turned on, all passes will be compared to the background you have selected. The colorspace settings will remain the same throughout the video.

The display should automatically update as you change the `Foreground Pass` or `Background Pass` dialogs.

If you want to view an individual pass, uncheck the box next to the background pass. Only the foreground pass will be displayed. You can toggle between modes with that checkbox.

![](http://i.imgur.com/ZoiiUio.png)

Raw, unfiltered "single-pass" fluorescence.

### Tips 

+ If an image appears misaligned (there are two identically shaped features in close proximity, but one is blue and one is red), it probably *is* misaligned. Just reselect the passes you are analyzing and it will attempt to re-align things. This fixes bad alignments most of the time.
+ If you want to export an image (either for comparison to another image or to just save), hit the `Export Display` button. This creates an identical copy of what you're seeing in a new window all by itself. This has the added benefit of if you make changes to the image before you export it, it won't mess up the rest of the application (the application is a MATLAB figure, and can be messed up if you start trying to change axes/colormaps there).
+ After using this software quite a bit, I feel pretty confident in saying that df/f values need to be above 150-200% and across a decent-sized area before you should consider them "real". There's definitely the potential for false positives in 2D mode, so use the 3D subtraction mode to verify things (with the colorspace minimum set at 150-200).  
+ To alter the colormap (besides just changing the axes limits with the colorspace dialog), right click on it and select `Interactive Colormap Shift`. You can now change the colormap by clicking and dragging. You can alternatively select an entirely different colormap with `Standard Colormaps`.
+ If you are seeing a bunch of orange text when you load an image, it's because BioFormats thinks MATLAB hasn't allocated enough Java heap space. Follow the directions in the orange text to fix this.

![](http://i.imgur.com/YRFScQS.gif)

A video exported by the GCaMP_4D program of two neurons fluorescing in response to a stimulus. (Sorry for the potato quality .gifs, but they're the only way GitHub will let me show a video- the actual videos are nicer looking.)
