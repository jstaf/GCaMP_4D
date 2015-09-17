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
%      Running this function will start the GCaMP_4D GUI program. This
%      software has only been tested with Leica .lif files, but *should*
%      work with any imaging format that can be opened by BioFormats.

% Last Modified by GUIDE v2.5 06-Sep-2015 14:06:00

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


%% INITIALIZATION ========================================================
% --- Executes just before GCaMP_4D is made visible.
function GCaMP_4D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GCaMP_4D (see VARARGIN)

% detect version for later use
handles.ver = version();
handles.ver = str2num(handles.ver(1:3));
if handles.ver < 8.5
    warning('You are using an older version of MATLAB than is recommended, see compatibility.txt.');
end

% need to add the bioformats package to our PATH (so MATLAB knows where it
% is)
addpath('./bfmatlab');
% initialization code from bfopen()
status = bfCheckJavaPath(true);
assert(status, ['Missing Bio-Formats library. Either add bioformats_package.jar '...
    'to the static Java path or add it to the Matlab path.']);
% log4j gets mad otherwise
javaMethod('enableLogging', 'loci.common.DebugTools', 'INFO');

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

% catch canceled file opening
if filename ~= 0
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
        % might be no label names present so just use stack numbers instead
        handles.stackNames = 1:nStacks;
    end
    
    % update stackselector values and open first stack
    set(handles.stackSelector, 'String', handles.stackNames);
    set(handles.stackSelector, 'Value', 1);
    set(handles.BGselect, 'Value', 1);
    set(handles.FGselect, 'Value', 1);
    guidata(hObject, handles);
    selectStack(hObject, handles);
end


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
    handles.confocalStack = zeros(resolution(1), resolution(2), sizeZ, sizeT, 'uint8');
    timeSinceLast = zeros(totalPlanes, 1);
    
    % needs to be set or we open the first series every time
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
        handles.confocalStack(:, :, sizeZ + 1 - Zn, Tn) = ... 
            bfGetPlane(handles.reader, idx);
        
        % get time since last frame... weird how this one uses java indices
        % and bfGetPlane does not...
        timeSinceLast(plane) = handles.omeMeta.getPlaneDeltaT(whichStack, plane - 1).value();
    end
    % determine framerate for videos
    handles.framerate = round(mean(timeSinceLast(2:end))) / sizeZ;
    
    close(progressBar);
    
    % update GUI to use new values
    set(handles.BGselect, 'String', 1:sizeT);
    set(handles.FGselect, 'String', 1:sizeT);
    
    % need this for movies :P
    handles.timesThruStack = sizeT;
    
    % set the y angle snap to control the number of slices
    handles.Y_Angle_Slider.SliderStep = [1 / sizeZ, 1 / sizeZ];
    
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
    set(handles.whichSliceText, 'Visible', 'off');
    guidata(hObject, handles);
    switch handles.mode
        case 1
            handles = display2D(hObject, handles);
        case 2
            handles = display2D(hObject, handles);
        case 3
            reduce = ceil(max(size(handles.confocalStack)) / 256);
            handles = display3D(hObject, handles, reduce);
    end
    guidata(hObject, handles);
end


%% EXPORT DISPLAY =================================================
% --- Executes on button press in exportDisplay.
function exportDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to exportDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure('Name', 'Display copy');
switch handles.mode
    case 1
        handles = display2D(hObject, handles);
    case 2
        handles = display2D(hObject, handles);
    case 3
        reduce = ceil(max(size(handles.confocalStack)) / 250);
        handles = display3D(hObject, handles, reduce); 
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
if (handles.mode == 3) 
    view(handles.X_Angle, handles.Y_Angle);
end
guidata(hObject, handles);
if (handles.mode == 2)
    handles = display2D(hObject, handles);
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
if (handles.mode == 3) 
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


%% FILTER MODIFIERS ===============================================
function filterMinSet_Callback(hObject, eventdata, handles)
% hObject    handle to filterMinSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterMinSet as text
%        str2double(get(hObject,'String')) returns contents of filterMinSet as a double
if (isnan(str2double(get(hObject,'String'))))
    warning('You must enter valid a number');
else
    if str2double(get(hObject,'String')) < handles.filterMax
        handles.filterMin = str2double(get(hObject,'String'));
        guidata(hObject, handles);
        update(hObject, handles);
    else
        disp('Invalid value. Plot minimum must be less than maximum.');
    end
end


% --- Executes during object creation, after setting all properties.
function filterMinSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterMinSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.filterMin = str2double(get(hObject,'String'));
guidata(hObject, handles);


function filterMaxSet_Callback(hObject, eventdata, handles)
% hObject    handle to filterMaxSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterMaxSet as text
%        str2double(get(hObject,'String')) returns contents of filterMaxSet as a double
if (isnan(str2double(get(hObject,'String'))))
    warning('You must enter valid a number');
else
    if handles.filterMin < str2double(get(hObject,'String'))
        handles.filterMax = str2double(get(hObject,'String'));
        guidata(hObject, handles);
        update(hObject, handles);
    else
        disp('Invalid value. Plot minimum must be less than maximum.');
    end
end


% --- Executes during object creation, after setting all properties.
function filterMaxSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterMaxSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.filterMax = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes on button press in autoscaleSet.
function autoscaleSet_Callback(hObject, eventdata, handles)
% hObject    handle to autoscaleSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoscaleSet

if handles.mode == 1 % 2D
    [handles.filterMin, handles.filterMax] = autoscale(handles.displayImage, 0.1, 0.999);
else % 3D
    if handles.backgroundOn == 0 % plain display
        [handles.filterMin, handles.filterMax] = autoscale(handles.displayImage, 0.1, 0.9999);
    else % subtraction
        [handles.filterMin, handles.filterMax] = autoscale(handles.displayImage, 0.95, 0.9999);
    end
end

set(handles.filterMinSet, 'String', handles.filterMin);
set(handles.filterMaxSet, 'String', handles.filterMax);
set(handles.filterMinSet, 'Value', handles.filterMin);
set(handles.filterMaxSet, 'Value', handles.filterMax);

% update display
guidata(hObject, handles);
update(hObject, handles);


% --- Executes on button press in exportVideo.
function exportVideo_Callback(hObject, eventdata, handles)
% hObject    handle to exportVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[output_name,path] = uiputfile('.avi');
if output_name ~= 0 % did file saving dialog get closed?
    try 
        if handles.mode == 1
            fig = figure(); 
        else
            fig = figure('Position', [100, 100, 800, 500]);
        end
        writer = VideoWriter([path, output_name]);
        writer.FrameRate = handles.framerate;
        open(writer);
        % programmatically make plots and export them as images
        for frameNum = 1:handles.timesThruStack
            set(handles.FGselect, 'Value', frameNum);
            update(hObject, handles);
            writeVideo(writer, getframe(fig));
        end
        close(writer);
        close(fig);
    catch % close resources if something went wrong
        if exist('fig', 'var') ~= 0
            close(fig);
        end
        if exist('writer', 'var') ~= 0
            close(writer);
        end
    end
end
