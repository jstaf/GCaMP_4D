function varargout = GCaMP_4D(varargin)
% GCAMP_4D MATLAB code for GCaMP_4D.fig
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

% Last Modified by GUIDE v2.5 09-Jul-2015 11:58:14

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

% Set pass selection values to impossible value (so you can check if the
% user's done anything yet).
% set(handles.BGselect, 'Value', 9999);
% set(handles.FGselect, 'Value', 9999);

% Choose default command line output for GCaMP_4D
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GCaMP_4D wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GCaMP_4D_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function BGslider_Callback(hObject, eventdata, handles)
% hObject    handle to BGslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function BGslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BGslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function FGslider_Callback(hObject, eventdata, handles)
% hObject    handle to FGslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function FGslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FGslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in openFileButton.
function openFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to openFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load the file 
handles.data = bfopen(uigetfile({'*', 'All files'}, ...
    'Select a image file to analyze...', 'MultiSelect','off'));

% get the names of each stack
handles.stackNames = cell(size(handles.data, 1), 1);
for i = 1:size(handles.data, 1)
    dat = handles.data{i ,1};
    label = strsplit(dat{1, 2}, ';');
    handles.stackNames{i} = label{2};
end

% update stackselector values
set(handles.stackSelector, 'String', handles.stackNames);

% Update handles structure
guidata(hObject, handles);


% --- Executes on key press with focus on openFileButton and none of its controls.
function openFileButton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to openFileButton (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in stackList.
function stackList_Callback(hObject, eventdata, handles)
% hObject    handle to stackList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stackList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stackList




% --- Executes during object creation, after setting all properties.
function stackList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stackList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in stackSelector.
function stackSelector_Callback(hObject, eventdata, handles)
% hObject    handle to stackSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stackSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stackSelector

contents = cellstr(get(hObject,'String'));
stackFail = strcmp('Needs file...', contents{get(hObject,'Value')});
if (~stackFail)
    % open and reformat data
    
    % grab the stack we want from the gui
    whichStack = get(hObject,'Value');
    series = handles.data{whichStack, 1};
    
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
    
    % update GUI to use new values
    set(handles.BGselect, 'String', 1:timesThruStack);
    set(handles.FGselect, 'String', 1:timesThruStack);
    guidata(hObject, handles);
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

update(handles);


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

update(handles);

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

function update(handles)

BGval = get(handles.BGselect,'Value');
FGval = get(handles.FGselect, 'Value');

% make sure the user has actually selected values for both
defaults = 'Needs stack...';
contents = cellstr(get(handles.FGselect,'String'));
FGfail = strcmp(defaults, contents{FGval});
contents = cellstr(get(handles.BGselect,'String'));
BGfail = strcmp(defaults, contents{BGval});

if (~FGfail && ~BGfail)
    %disp(['BG: ', num2str(BGval), ', FG: ', num2str(FGval)]); % testline
    
    FG = handles.maxProject(:, :, FGval);
    BG = handles.maxProject(:, :, BGval);
    
    FG = stabilizePair(BG, FG);
    handles.dff = subtractImg(FG, BG);
    
    percentile = quantile(handles.dff(:), 0.99);
    percentileLO = quantile(handles.dff(:), 0.01);
    imshow(handles.dff, [percentileLO, percentile]); % maximum is 99th percentile
    % create colorbar and its limits
    colormap(jet);
    colorBAR = colorbar('EastOutside');
    colorBAR.Label.String = 'Change in Fluorescence (dF/F)';
end
