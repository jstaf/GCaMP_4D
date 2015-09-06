function handles = display3D(hObject, handles, dataReduce)
% Display 3D image for plotting

if handles.backgroundOn
    % field subtraction
    image3d = subtractField(handles.confocalStack(:, :, :, get(handles.FGselect, 'Value')), ...
        handles.confocalStack(:, :, :, get(handles.BGselect, 'Value')), handles.ver);
    image3d = imgaussfilt3(image3d, 1); % weak gauss filter to smooth things out
else
    % straight up 3d image
    image3d = handles.confocalStack(:, :, :, get(handles.FGselect, 'Value'));
    if handles.ver < 8.5
        % looks worse for earlier versions, sorry
        gauss = fspecial('gaussian', 7, 2);
        for i = 1:size(image3d, 3);
            image3d(:, :, i) = imfilter(image3d(:, :, i), gauss);
        end
    else
        image3d = imgaussfilt3(image3d, 1);
    end
end

%% beginning of old sliceproject() code ==================================
% reduce data complexity for plotting
dimensions = size(image3d);

% ugh.... reverse compatibility
if (handles.ver < 8.5)
    % slowwwwwwwww
    alloc = zeros(ceil(dimensions(1) / dataReduce), ...
        ceil(dimensions(2) / dataReduce), ...
        dimensions(3), 'double');
else 
    % easier on memory, and faster!
    alloc = zeros(ceil(dimensions(1) / dataReduce), ...
        ceil(dimensions(2) / dataReduce), ...
        dimensions(3), 'single');
end
for x = 1:dataReduce:dimensions(1)
    for y = 1:dataReduce:dimensions(2)
        alloc(ceil(x / dataReduce), ceil(y / dataReduce), :) = image3d(x, y, :);
    end
end
% update dimensions to new, smaller size
dimensions = size(alloc);
% update aspect ratio
voxelSizes = handles.voxelSizes;
voxelSizes(1:2) = voxelSizes(1:2) * dataReduce;

spread = 1;
slicePlot = slice(alloc, [], [], 1:spread:dimensions(3));
set(slicePlot, 'EdgeColor', 'none');

axis([0, dimensions(2), 0, dimensions(1), 0, dimensions(3)]);
set(gca, 'Ydir', 'reverse'); % y axis is always fucking reversed

%% manipulate viewdata

colormap('jet');
colorBAR = colorbar('EastOutside');
colorBAR.Label.String = 'Raw fluorsecence value';
caxis([handles.filterMin, handles.filterMax]);

% set colors and transparency of the plot to be equal to the image
% intensity in that zone
alpha('color');
alphaMapping = alphamap('rampup');

%set a transparency threshold so that you can actually see through
%transparent bits... depends on subtraction mode
if ~handles.backgroundOn % standard 3D
    thresh = 2;
else % 3D subtraction
    thresh = 7;
end

% alphaMod = new alpha minimum (1 thru 64)... where on the scale of 0 thru
% filtermax is it?
alphaMod = uint32((handles.filterMin / handles.filterMax) * 64 - thresh);

alphaMapping(thresh:(thresh+alphaMod)) = 0;
slope = 1/(64 - thresh - double(alphaMod));
alphaMapping((thresh+alphaMod):64) = 0:slope:1;

% these values always need to be 0 or the image is opaque
alphaMapping(1:(thresh+2)) = 0;

alphaMapping(alphaMapping > 1) = 1;
alphaMapping(alphaMapping < 0) = 0;
alphamap(alphaMapping);

% not sure if i believe the metadata
voxelSizes(3) = voxelSizes(3) / 2;

% set aspect ratio to metadata's voxel aspect ratio
daspect(1 ./ voxelSizes);

view(handles.X_Angle, handles.Y_Angle);

% update handles with display image for autoscaling
handles.displayImage = alloc;
guidata(hObject, handles);

return;
