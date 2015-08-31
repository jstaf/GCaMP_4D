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

% Last Modified by GUIDE v2.5 31-Aug-2015 15:05:29

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

% make sure image subtraction is turned on
handles.backgroundOn = 1;

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

% --- Executes on button press in openFileButton.
function openFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to openFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load the file 
[filename, path] = uigetfile({'*', 'All files'}, ...
    'Select a image file to analyze...', 'MultiSelect','off');
handles.data = bfopen([path, filename]);

% get the names of each stack
handles.stackNames = cell(size(handles.data, 1), 1);
for i = 1:size(handles.data, 1)
    dat = handles.data{i ,1};
    label = strsplit(dat{1, 2}, ';');
    handles.stackNames{i} = label{2};
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
    % open and reformat data
    
    % grab the stack we want from the gui
    whichStack = get(hObject,'Value');
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
    handles.confocalStack = zeros(resolution(1), resolution(2), stackSize, timesThruStack, 'uint8');
    % fill in confocalStack with our data
    for planeNum = 1:size(series, 1)
        % which image our we at in a single pass
        stackNum = mod(planeNum, stackSize) + 1;
        
        % what pass through our sample are we at
        passNum = ceil(planeNum / stackSize);
        
        % put the current plane where its supposed to go
        handles.confocalStack(:, :, stackNum, passNum) = series{planeNum, 1};
    end
    
    % make a max projection of every pass through
    sz = size(handles.confocalStack);
    handles.maxProject = zeros(sz(1), sz(2), sz(4), 'uint8');
    % go through confocalStack and make a max projection for each
    for stack = 1:timesThruStack
        % make max projection
        handles.maxProject(:, :, stack) = max(handles.confocalStack(:, :, :, stack), [], 3);
    end
    
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
            sliceProject(handles, 5);
            view(handles.X_Angle, handles.Y_Angle);
        otherwise
            % do nothing
    end
end

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
    colormap(jet);
    colorBAR = colorbar('EastOutside');
    colorBAR.Label.String = 'Change in fluorescence (dF/F)';
else
    colormap(gray);
    colorBAR = colorbar('EastOutside');
    colorBAR.Label.String = 'Raw fluorsecence value';
end
drawnow;


% --- Executes on button press in exportDisplay.
function exportDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to exportDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure('Name', 'dF/F');
switch handles.mode
    case 1
        try
            display2d(handles)
        catch
            % dont do anything... works as intended even though its throwing an
            % error here.
        end
    case 2
        % do nothing (yet)
end



% --- Executes on button press in enableBackground.
function enableBackground_Callback(hObject, eventdata, handles)
% hObject    handle to enableBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enableBackground
handles.backgroundOn = get(hObject,'Value');
guidata(hObject, handles);
update(hObject, handles);


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
