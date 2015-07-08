% We are going to try opening the .lif files and get them into a useable
% format.

% need to add the bioformats package to our PATH (so MATLAB knows where it
% is)
addpath('./bfmatlab');

% load the file 
data = bfopen(uigetfile({'*', 'All files'}, ...
    'Select a image file to analyze...', 'MultiSelect','off'));

disp(['There are ', num2str(size(data, 1)), ' confocal stacks in this file']);
% which stack number do we want?
whichStack = 2;

% each row is a confocal stack

%as for columns...
% 1st column is the actual confocal stack
% 2nd column is the metadata
% 3rd column is color lookup tables for each stack (not sure what those
% are)
% 4th column has the individual pixel sizes (in um or whatever units) of
% each stack

% lets take the first confocal stack
series = data{whichStack, 1};

%% reformat data
% lets create a container to hold all of our data in a sensible format

% take first element of metadata and figure out Z and T
stackData = strsplit(series{1, 2}, ';');
stackSize = strsplit(stackData{4}, '/');
% number of times we went through the stack
stackSize = str2double(stackSize{2}); 

timesThruStack = strsplit(stackData{5}, '/');
timesThruStack = str2double(timesThruStack{2}); 

% warn if final stack is incomplete
if (timesThruStack ~= (size(series, 1) / stackSize))
    warning('Warning, calculated number of stacks DOES NOT MATCH metadata');
end

% whats the size of the first image plane
resolution = size(series{1, 1});

% preallocate memory to make things faster
confocalStack = zeros(resolution(1), resolution(2), stackSize, timesThruStack, 'uint8');
% fill in confocalStack with our data
for planeNum = 1:size(series, 1) 
    % grab image plane
    plane = series{planeNum, 1};
    
    % which image our we at in a single pass
    stackNum = mod(planeNum, stackSize) + 1; % remainder of division
    
    % what pass through our sample are we at
    passNum = ceil(planeNum / stackSize); % division, rounded up
    
    % put the plane where its supposed to go
    confocalStack(:, :, stackNum, passNum) = plane;
end

%% make a max projection of every pass through

sz = size(confocalStack);
maxProject = zeros(sz(1), sz(2), sz(4), 'uint8');
% go through confocalStack and make a max projection for each
for stack = 1:timesThruStack
    % make max projection
    project = max(confocalStack(:, :, :, stack), [], 3);
    
    maxProject(:, :, stack) = project;
end

%% show all max projections

% figure;
% hold on;
% for i = 1:size(maxProject, 3)
%     subplot(4, 4,i), subimage(maxProject(:,:, i));
% end
% hold off;

%% try making a heatmap as dF/F using the max projections

% first number is the baseline you are comparing against 
numbers = [3, 5]; % have a way of picking which things to compare

dff = double(maxProject(:, :, numbers(2))) ./ double(maxProject(:, :, numbers(1)));
dff = dff * 100; %change to percent
%dff = medfilt2(dff);

% fix division by 0 artifacts
dff(isnan(dff(:))) = 0;
dff(isinf(dff(:))) = 0;

handle = figure('Name', 'dF/F');
imshow(dff, [0, 400]); %TODO automatically set
% create colorbar and its limits
colormap(jet);
c = colorbar('EastOutside');
c.Label.String = 'Change in Fluorescence (dF/F)';

%imshow(maxProject(:, :, numbers(2)));





