function sliceProject(image3d, alphaMod, voxelSizes)

% blur image to remove noise (its really hard to see whats going on otherwise)
dimensions = size(image3d);
gauss = fspecial('gaussian', 7, 2);
for imageNum = 1:dimensions(3)
    image3d(:, :, imageNum) = imfilter(image3d(:, :, imageNum), gauss);
end

% create plot

% ugh.... reverse compatibility
ver = version();
if (str2num(ver(1:3)) < 8.4)
    alloc = double(image3d);
else 
    % easier on memory
    alloc = single(image3d);
end

spread = 1;
slicePlot = slice(alloc, [], [], 1:spread:dimensions(3));
set(slicePlot, 'EdgeColor', 'none');

axis([0, dimensions(2), 0, dimensions(1), 0, dimensions(3)]);
set(gca, 'Ydir', 'reverse'); % y axis is always fucking reversed

%% manipulate viewdata

% set colors and transparency of the plot to be equal to the image
% intensity in that zone
alpha('color');
alphaMapping = alphamap('rampup');
thresh = 2;
if (alphaMod >= 0)
    alphaMapping(thresh:(thresh+alphaMod)) = 0;
    slope = 1/(64 - thresh - alphaMod);
    alphaMapping((thresh+alphaMod):64) = 0:slope:1;
end
% these values always need to be 0 or the image is opaque
alphaMapping(1:(thresh+3)) = 0;

alphaMapping(alphaMapping > 1) = 1;
alphaMapping(alphaMapping < 0) = 0;
alphamap(alphaMapping);
colormap('jet');
colorBAR = colorbar('EastOutside');
colorBAR.Label.String = 'Raw fluorsecence value';

% set aspect ratio to metadata's voxel aspect ratio
daspect(1 ./ voxelSizes);

return;


