function sliceProject(image3d, threshold)

%waitDialog = waitbar(0, 'Computing 3D viewfield...');

% blur image to remove noise (its really hard to see whats going on otherwise)
dimensions = size(image3d);
gauss = fspecial('gaussian', 7, 2);
for imageNum = 1:dimensions(3)
    %waitbar(imageNum/(dimensions(3) + 1), waitDialog, 'Computing 3D viewfield...');
    image3d(:, :, imageNum) = imfilter(image3d(:, :, imageNum), gauss);
end

%waitbar(dimensions(3)/(dimensions(3) + 1), waitDialog, 'Creating plot...');

% create plot
alloc = single(image3d);
slicePlot = slice(alloc, [], [], 1:32);
set(slicePlot, 'EdgeColor', 'none')

axis([0, dimensions(2), 0, dimensions(1), 0, dimensions(3)]);
set(gca, 'Ydir', 'reverse'); % y axis is always fucking reversed

%% manipulate viewdata

% need to get it into real aspect ratio with metadata later
daspect([1, 1, 0.3]);

% set colors and transparency of the plot to be equal to the image
% intensity in that zone
alpha('color');
alphaMapping = alphamap('rampup');
alphaMapping(1:threshold) = 0;
% alphaMapping(alphaMapping > 1) = 1;
% alphaMapping(alphaMapping < 0) = 0;
alphamap(alphaMapping);
colormap('jet');
colorBAR = colorbar('EastOutside');
colorBAR.Label.String = 'Raw fluorsecence value';

%close(waitDialog);
drawnow;
return;


