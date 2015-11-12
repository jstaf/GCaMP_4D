[filename, path] = uigetfile({'*', 'All files'}, ...
    'Select a image file to analyze...', 'MultiSelect','off');

whichStack = 0;

handles = struct();
% open metadata and get stack names
handles.reader = bfGetReader([path, filename]);
handles.omeMeta = handles.reader.getMetadataStore();

% [X, Y] = x/y resolution of our image planes
resolution = [handles.omeMeta.getPixelsSizeY(whichStack).getNumberValue().doubleValue(), ...
    handles.omeMeta.getPixelsSizeX(whichStack).getNumberValue().doubleValue()];
% Z = size of stack
sizeZ = handles.omeMeta.getPixelsSizeZ(whichStack).getNumberValue().doubleValue();
% T = number of times we went through the stack (action repeated)
sizeT = handles.omeMeta.getPixelsSizeT(whichStack).getNumberValue().doubleValue();
% N = total number of planes in our stack / number of channels
totalPlanes = handles.omeMeta.getPlaneCount(whichStack) / ...
    handles.omeMeta.getPixelsSizeC(whichStack).getNumberValue().doubleValue();

% [x, y, z] = retrieve absolute voxel sizes in uM
handles.voxelSizes = [ ...
    handles.omeMeta.getPixelsPhysicalSizeX(whichStack).value(ome.units.UNITS.MICROM).doubleValue(), ...
    handles.omeMeta.getPixelsPhysicalSizeY(whichStack).value(ome.units.UNITS.MICROM).doubleValue(), ...
    handles.omeMeta.getPixelsPhysicalSizeZ(whichStack).value(ome.units.UNITS.MICROM).doubleValue()];

%% open file
% preallocate memory to make things faster
handles.confocalStack = zeros(resolution(1), resolution(2), sizeZ * sizeT, 'uint8');

handles.reader.setSeries(whichStack);

progressBar = waitbar(0, 'Opening stack...');
% fill in confocalStack with our data
for plane = 1:totalPlanes
    waitbar(plane / totalPlanes, progressBar, ...
        ['Opening plane ', num2str(plane), ' of ', num2str(totalPlanes)]);
    
    % which image our we at in a single pass?
    Zn = mod(plane, sizeZ) + 1;
    
    % what pass through our sample are we at?
    Tn = ceil(plane / sizeZ);
    
    idx = handles.reader.getIndex(Zn - 1, 0, Tn - 1) + 1;
    
    % individually grab plane and put it where its supposed to go
    handles.confocalStack(:, :, plane) = ...
        bfGetPlane(handles.reader, idx);
end
close(progressBar);

%% make video

makeFramePerPass('raw.avi', handles.confocalStack)