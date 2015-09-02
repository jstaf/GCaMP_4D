function varargout = GCaMP_4D(varargin)
% GCAMP_4D MATLAB code for GCaMP_4D.fig
%       
%      Created by Jeff Stafford
%
%      GCAMP_4D, by itself, creates a new GCAMP_4D or raises the existing
%      singleton*.
%
%      H = GCAMP_4D returns the handle to a new GCAMP_4D or the handle to
%      the existing singleton*.
%
%      GCAMP_4D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GCAMP_4D.M with the given input arguments.
%
%      GCAMP_4D('Property','Value',...) creates a new GCAMP_4D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GCaMP_4D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GCaMP_4D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GCaMP_4D

% Last Modified by GUIDE v2.5 01-Sep-2015 16:38:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GCaMP_4D_OpeningFcn, ...
                   'gui_OutputFcn',  @GCaMP_4D_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GCaMP_4D is made visible.
function GCaMP_4D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GCaMP_4D (see VARARGIN)

% need to add the bioformats package to our PATH (so MATLAB knows where it
% is)
addpath('./bfmatlab');

% Choose default command line output for GCaMP_4D
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = GCaMP_4D_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% FILE SELECTION ==================================================
% --- Executes on button press in openFileButton.
function openFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to openFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load the file 
[filename, path] = uigetfile({'*', 'All files'}, ...
    'Select a image file to analyze...', 'MultiSelect','off');

% open metadata and get stack names
handles.reader = bfGetReader([path, filename]);
handles.omeMeta = handles.reader.getMetadataStore();
nStacks = handles.omeMeta.getImageCount();
handles.stackNames = cell(nStacks, 1);
try
    for i = 0:(nStacks-1) % java indices
        handles.stackNames{i + 1} = char(handles.omeMeta.getImageName(i));
    end
catch
    % might be no label names present so just make up stack numbers
    handles.stackNames = 1:nStacks;
end

% update stackselector values and open first stack
set(handles.stackSelector, 'String', handles.stackNames);
set(handles.stackSelector, 'Value', 1);
set(handles.BGselect, 'Value', 1);
set(handles.FGselect, 'Value', 1);
guidata(hObject, handles);
selectStack(hObject, handles);

% --- Executes on key press with focus on openFileButton and none of its controls.
function openFileButton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to openFileButton (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


%% STACK SELECTION ================================================
% --- Executes on selection change in stackSelector.
function stackSelector_Callback(hObject, eventdata, handles)
% hObject    handle to stackSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stackSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stackSelector
selectStack(hObject, handles);

% created so that stack selection can be called programmatically
function selectStack(hObject, handles)

contents = cellstr(get(hObject,'String'));
stackFail = strcmp('Needs file...', contents{get(hObject,'Value')});
if (~stackFail)
    %% parse metadata
    % grab the stack we want from the gui
    whichStack = get(hObject,'Value') - 1; % java indices for metadata store
    
    % [X, Y] = x/y resolution of our image planes
    resolution = [handles.omeMeta.getPixelsSizeY(whichStack).getNumberValue().doubleValue(), ...
        handles.omeMeta.getPixelsSizeX(whichStack).getNumberValue().doubleValue()];
    % Z = size of stack
    stackSize = handles.omeMeta.getPixelsSizeZ(whichStack).getNumberValue().doubleValue();
    % T = number of times we went through the stack / action repeated
    timesThruStack = handles.omeMeta.getPixelsSizeT(whichStack).getNumberValue().doubleValue();
    % N = total number of planes in our stack
    totalPlanes = handles.omeMeta.getPlaneCount(whichStack);
    
    % [x, y, z] = retrieve absolute voxel sizes in uM
    handles.voxelSizes = [ ...
        handles.omeMeta.getPixelsPhysicalSizeX(whichStack).value(ome.units.UNITS.MICROM).doubleValue(), ...
        handles.omeMeta.getPixelsPhysicalSizeY(whichStack).value(ome.units.UNITS.MICROM).doubleValue(), ...
        handles.omeMeta.getPixelsPhysicalSizeZ(whichStack).value(ome.units.UNITS.MICROM).doubleValue()];
    
    %% open file
    % preallocate memory to make things faster
    handles.confocalStack = zeros(resolution(1), resolution(2), stackSize, timesThruStack, 'uint8');
    timeSinceLast = zeros(totalPlanes, 1);
    
    % needs to be set or we open the first series every time
    handles.reader.setSeries(whichStack);
    
    progressBar = waitbar(0, 'Opening stack...');
    % fill in confocalStack with our data
    for planeNum = 1:totalPlanes
        waitbar(planeNum / totalPlanes, progressBar, ...
            ['Opening plane ', num2str(planeNum), ' of ', num2str(totalPlanes)]);
        
        % which image our we at in a single pass?
        stackNum = mod(planeNum, stackSize) + 1;
        
        % what pass through our sample are we at?
        passNum = ceil(planeNum / stackSize);
        
        % individually grab plane and put it where its supposed to go
        handles.confocalStack(:, :, stackNum, passNum) = bfGetPlane(handles.reader, planeNum);
        
        % get time since last frame... weird how this one uses java indices
        % and bfGetPlane does not...
        timeSinceLast(planeNum) = handles.omeMeta.getPlaneDeltaT(whichStack, planeNum - 1).value();
    end
    % determine framerate
    handles.framerate = round(mean(timeSinceLast(2:end)));
    
    %% make a max projection of every pass through for quick 2D viewing
    sz = size(handles.confocalStack);
    handles.maxProject = zeros(sz(1), sz(2), sz(4), 'uint8');
    % go through confocalStack and make a max projection for each
    for stack = 1:timesThruStack
        waitbar(planeNum / totalPlanes, progressBar, ...
            'Creating max projections');
        % make max projection
        handles.maxProject(:, :, stack) = max(handles.confocalStack(:, :, :, stack), [], 3);
    end
    
    close(progressBar);
    
    % update GUI to use new values
    set(handles.BGselect, 'String', 1:timesThruStack);
    set(handles.FGselect, 'String', 1:timesThruStack);
    
    guidata(hObject, handles);
    update(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function stackSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stackSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% PASS SELECTION ==================================================
% --- Executes on selection change in BGselect.
function BGselect_Callback(hObject, eventdata, handles)
% hObject    handle to BGselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BGselect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BGselect

update(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BGselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BGselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FGselect.
function FGselect_Callback(hObject, eventdata, handles)
% hObject    handle to FGselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FGselect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FGselect

update(hObject, handles);

% --- Executes during object creation, after setting all properties.
function FGselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FGselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% UPDATE DISPLAY ================================================
% update the delta frame
function update(hObject, handles)

BGval = get(handles.BGselect,'Value');
FGval = get(handles.FGselect, 'Value');

% make sure the user has actually selected values for both
defaults = 'Needs stack...';
contents = cellstr(get(handles.FGselect,'String'));
FGfail = strcmp(defaults, contents{FGval});
contents = cellstr(get(handles.BGselect,'String'));
BGfail = strcmp(defaults, contents{BGval});

if (~FGfail && ~BGfail)
    % update and display data
    guidata(hObject, handles);
    switch handles.mode
        case 1
            display2d(handles);
        case 2
            display3d(handles, 1);
    end
end

%% DISPLAY 2D IMAGE ===============================================
% displays the data
function display2d(handles)

BGval = get(handles.BGselect,'Value');
FGval = get(handles.FGselect, 'Value');

FG = handles.maxProject(:, :, FGval);
if (handles.backgroundOn)
    BG = handles.maxProject(:, :, BGval);
    BG = stabilizePair(FG, BG);
    image = subtractImg(FG, BG);
else
    image = FG;
end

percentileHI = quantile(image(:), 0.99);
percentileLO = quantile(image(:), 0.01);
imshow(image, [percentileLO, percentileHI]);

% create colorbar and its limits
warning('off','MATLAB:warn_r14_stucture_assignment');
if (handles.backgroundOn)
    colormap('jet');
    colorBAR = colorbar('EastOutside');
    colorBAR.Label.String = 'Change in fluorescence (dF/F)';
else
    colormap('gray');
    colorBAR = colorbar('EastOutside');
    colorBAR.Label.String = 'Raw fluorsecence value';
end
drawnow;

%% DISPLAY 3D IMAGE ================================================
function display3d(handles, dataReduce)

if ~handles.backgroundOn
    image3d = handles.confocalStack(:, :, :, get(handles.FGselect, 'Value'));
    image3d = imgaussfilt3(image3d, 1);
else
    image3d = subtractField(handles.confocalStack(:, :, :, get(handles.FGselect, 'Value')), ...
        handles.confocalStack(:, :, :, get(handles.BGselect, 'Value')));    
end
sliceProject(image3d, handles.alphaMod, handles.voxelSizes, dataReduce);
view(handles.X_Angle, handles.Y_Angle);


%% EXPORT DISPLAY =================================================
% --- Executes on button press in exportDisplay.
function exportDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to exportDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure('Name', 'Display copy');
switch handles.mode
    case 1
        try
            display2d(handles)
        catch
            % dont do anything... works as intended even though its throwing an
            % error here.
        end
    case 2
        % higher res export version
        display3d(handles, 1); 
end


%% BACKGROUND SUBTRACTION ====================================
% --- Executes during object creation, after setting all properties.
function enableBackground_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enableBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.backgroundOn = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in enableBackground.
function enableBackground_Callback(hObject, eventdata, handles)
% hObject    handle to enableBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enableBackground
handles.backgroundOn = get(hObject,'Value');
guidata(hObject, handles);
update(hObject, handles);

%% SLIDERS ======================================================
% --- Executes on slider movement.
function Y_Angle_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Y_Angle_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.Y_Angle = get(hObject,'Value');
if (handles.mode == 2) 
    view(handles.X_Angle, handles.Y_Angle);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Y_Angle_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_Angle_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
handles.Y_Angle = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on slider movement.
function X_Angle_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to X_Angle_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.X_Angle = get(hObject,'Value');
if (handles.mode == 2) 
    view(handles.X_Angle, handles.Y_Angle);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function X_Angle_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to X_Angle_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
handles.X_Angle = get(hObject,'Value');
guidata(hObject, handles);

%% MODE SELECTOR ==============================================
% --- Executes on selection change in ModeSelector.
function ModeSelector_Callback(hObject, eventdata, handles)
% hObject    handle to ModeSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ModeSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ModeSelector
handles.mode = get(hObject,'Value');
guidata(hObject, handles);
update(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ModeSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ModeSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.mode = get(hObject,'Value');
guidata(hObject, handles);


%% ALPHA MODIFIER ===============================================
function AlphaModifier_Callback(hObject, eventdata, handles)
% hObject    handle to AlphaModifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AlphaModifier as text
%        str2double(get(hObject,'String')) returns contents of AlphaModifier as a double
if (isnan(str2double(get(hObject,'String'))))
    warning('You must enter valid a number');
else
    handles.alphaMod = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    update(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function AlphaModifier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AlphaModifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.alphaMod = str2double(get(hObject,'String'));
guidata(hObject, handles);
