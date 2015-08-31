%% GCamp_4D (script form)
% Jeff Stafford

% This script does the same thing as the GUI, just a set of commands in the
% right order instead of making you click on things to debug.

addpath('./bfmatlab');

handles = struct();
handles.data = bfopen('April24-206843-cv2nls-13xGCaMP6s-4.lif');
% get the names of each stack
handles.stackNames = cell(size(handles.data, 1), 1);
for i = 1:size(handles.data, 1)
    dat = handles.data{i ,1};
    label = strsplit(dat{1, 2}, ';');
    handles.stackNames{i} = label{2};
end

% which stack and pass in the stacks do we want?
handles.stackSelector = 1;
handles.BGselect = 3;
handles.FGselect = 6;

% background on?
handles.backgroundOn = true;

%% open and reformat data

% grab the stack we want from the gui
whichStack = handles.stackSelector;
series = handles.data{whichStack, 1};

% take first element of metadata and figure out Z and T
stackData = strsplit(series{1, 2}, ';');
stackSize = strsplit(stackData{end-1}, '/');
% number of times we went through the stack
stackSize = str2double(stackSize{2});

timesThruStack = strsplit(stackData{end}, '/');
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
    % which image our we at in a single pass
    stackNum = mod(planeNum, stackSize) + 1;
    
    % what pass through our sample are we at
    passNum = ceil(planeNum / stackSize);
    
    % put the current plane where its supposed to go
    confocalStack(:, :, stackNum, passNum) = series{planeNum, 1};
end

% make a max projection of every pass through
sz = size(confocalStack);
handles.maxProject = zeros(sz(1), sz(2), sz(4), 'uint8');
% go through confocalStack and make a max projection for each
for stack = 1:timesThruStack
    % make max projection
    handles.maxProject(:, :, stack) = max(confocalStack(:, :, :, stack), [], 3);
end

%% make a sweet video
image3d = confocalStack(:, : , :, 1);

makeFramePerPass('passVideo', handles.maxProject);
makeUpdatingVideo('updatingVideo', confocalStack);

%%

% %% update display image and spit it out at the user
% 
% FGval = handles.FGselect;
% BGval = handles.BGselect;
% 
% FG = handles.maxProject(:, :, FGval);
% if (handles.backgroundOn)
%     BG = handles.maxProject(:, :, BGval);
%     BG = stabilizePair(FG, BG);
%     handles.dff = subtractImg(FG, BG);
% else
%     handles.dff = FG;
% end
% 
% image = handles.dff;
% percentileHI = quantile(image(:), 0.99);
% percentileLO = quantile(image(:), 0.01);
% imshow(image, [percentileLO, percentileHI]);
% 
% % create colorbar and its limits
% warning('off','MATLAB:warn_r14_stucture_assignment');
% if (handles.backgroundOn)
%     colormap(jet);
%     colorBAR = colorbar('EastOutside');
%     colorBAR.Label.String = 'Change in fluorescence (dF/F)';
% else
%     colormap(gray);
%     colorBAR = colorbar('EastOutside');
%     colorBAR.Label.String = 'Raw fluorsecence value';
% end
% drawnow;

