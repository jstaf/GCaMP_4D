
image3d = confocalStack(:, : , : , 5);
blur = 1;
threshold = 5;

dimensions = size(image3d);
if (blur)
    gauss = fspecial('gaussian', 7, 2);
    for imageNum = 1:dimensions(3)
        image3d(:, :, imageNum) = imfilter(image3d(:, :, imageNum), gauss);
    end
end

% create plot
alloc = single(image3d);
slicePlot = slice(alloc, [], [], 1:32);
set(slicePlot, 'EdgeColor', 'none')

axis([0, dimensions(2), 0, dimensions(1), 0, dimensions(3)]);
set(gca, 'Ydir', 'reverse'); % y axis is always fucking reversed

%% manipulate view angle

% need to get it into real aspect ratio with metadata later
daspect([1, 1, 0.3]);

% set colors and transparency of the plot to be equal to the image
% intensity in that zone
alpha('color');
alphaMapping = alphamap('rampup');
% if (~blur)
%     alphaMapping = alphaMapping + 0.15;
% end
alphaMapping(1:threshold) = 0;
alphaMapping(alphaMapping > 1) = 1;
alphaMapping(alphaMapping < 0) = 0;
alphamap(alphaMapping);
% if (blur)
%     colormap('jet');
% else
%     colormap(flipud(colormap('gray')));
% end
colormap('jet');
colorBAR = colorbar('EastOutside');
colorBAR.Label.String = 'Raw fluorsecence value';

view(-20, 30)


