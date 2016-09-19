% VISUALIZATION_GUI display arm gesture data.
%
% Example:
%    visualization_gui(6, 3, gestures, gesture_names);
% shows the 3rd sequence of the 6th gesture type.
%
function varargout = visualization_gui(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualization_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @visualization_gui_OutputFcn, ...
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

% --- Executes just before visualization_gui is made visible.
function visualization_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visualization_gui (see VARARGIN)

% Choose default command line output for visualization_gui
handles.output = hObject;

% UIWAIT makes visualization_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Initialize dataset
dataset = varargin{1};
handles.dataset = dataset;
%set(handles.datatext,'String',names{class_num});
%current_dataset = dataset{class_num};
%curr_seq = current_dataset{sequence_num};

initialize_slider(eventdata, handles);
% Update handles structure
guidata(hObject, handles);


function [classid sequenceid] = getIds(handles)
contents = cellstr(get(handles.popupmenuClass,'String'));
classid = str2num(contents{get(handles.popupmenuClass,'Value')});
contents = cellstr(get(handles.popupmenuSequence,'String'));
sequenceid = str2num(contents{get(handles.popupmenuSequence,'Value')});


function initialize_slider(eventdata, handles)
[classid sequenceid] = getIds(handles);
curr_seq = handles.dataset{classid}{sequenceid};

% Initialize slider
frame_num = size(curr_seq,2);
slider_step(1) = 1/(frame_num-1);
slider_step(2) = 2/(frame_num-1);

set(handles.slider1,'sliderstep',slider_step,'min',1,'max',frame_num,'Value',1);
slider1_Callback(handles.slider1, eventdata, handles);




% --- Outputs from this function are returned to the command line.
function varargout = visualization_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%Grab value on the slider
i = ceil(get(hObject,'Value'));
%display this value in the text box next to it
%so that users can see which frame is on display
set(handles.text1,'String',num2str(i))

%display the frame
axes(handles.axes1);
[classid sequenceid] = getIds(handles);
curr_seq = handles.dataset{classid}{sequenceid};
current_frame = curr_seq(:,i);

rotate3d on
draw_pose(current_frame);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenuSequence.
function popupmenuSequence_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSequence contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSequence
initialize_slider(eventdata, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuSequence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', 1:30);


% --- Executes on selection change in popupmenuClass.
function popupmenuClass_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuClass contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuClass
initialize_slider(eventdata, handles);


% --- Executes during object creation, after setting all properties.
function popupmenuClass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', 1:9);
