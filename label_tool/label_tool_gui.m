function varargout = label_tool_gui(varargin)
% LABEL_TOOL_GUI MATLAB code for label_tool_gui.fig
%      LABEL_TOOL_GUI, by itself, creates a new LABEL_TOOL_GUI or raises the existing
%      singleton*.
%
%      H = LABEL_TOOL_GUI returns the handle to a new LABEL_TOOL_GUI or the handle to
%      the existing singleton*.
%
%      LABEL_TOOL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABEL_TOOL_GUI.M with the given input arguments.
%
%      LABEL_TOOL_GUI('Property','Value',...) creates a new LABEL_TOOL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before label_tool_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to label_tool_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help label_tool_gui

% Last Modified by GUIDE v2.5 11-Oct-2017 10:34:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @label_tool_gui_OpeningFcn, ...
    'gui_OutputFcn',  @label_tool_gui_OutputFcn, ...
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

% --- Executes just before label_tool_gui is made visible.
function label_tool_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to label_tool_gui (see VARARGIN)
global x1;
global y1;
global x2;
global y2;
global pos1_handles;
global pos2_handles;
global pos1_callbacks;
global pos2_callbacks;
global rect;
global rect_color;
global current_box_val;
global label_text;
global class_label_input;
class_label_input = '1';
current_box_val = 1;
rect = gobjects(0);
label_text = gobjects(0);
pos1_handles = impoint.empty;
pos2_handles = impoint.empty;
pos1_callbacks = struct('removeCallback', []);
pos2_callbacks = struct('removeCallback', []);
x1 = handles.x1_label;
y1 = handles.y1_label;

x2 = handles.x2_label;
y2 = handles.y2_label;
rect_color = 'cyan';
handles.defaultDirectory = false;
handles.pathname = '';
handles.filenames = '';
handles.imagearray = {};
%handles.point1 = impoint(handles.axes1,150,100);
%swpoint2 = impoint(handles.axes1,500,100);
%handles.point2 = impoint(handles.axes1,150,400);
%swpoint4 = impoint(handles.axes1,500,400);
% Choose default command line output for label_tool_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes label_tool_gui wait for user response (see UIRESUME)
%uiwait(handles.figure1);

function draw_rectangle()
global pos1_handles;
global pos2_handles;
global rect;
global rect_color;
global current_box_val;
global label_text;
global class_label_input;
global x1;
global x2;
global y1;
global y2;
if current_box_val == 1
    delete(rect);
    delete(label_text);
else
    if current_box_val > size(rect,2)
    else
        delete(rect(current_box_val));
        delete(label_text(current_box_val));
    end
end

pos1 = getPosition(pos1_handles(current_box_val));
pos2 = getPosition(pos2_handles(current_box_val));

set(x1,'String',num2str(pos1(1)));
set(y1,'String',num2str(pos1(2)));
set(x2,'String',num2str(pos2(1)));
set(y2,'String',num2str(pos2(2)));

rect(current_box_val) = rectangle('Position', [pos1(1) pos1(2) abs(pos1(1) - pos2(1)) abs(pos1(2) - pos2(2))], 'EdgeColor', rect_color, 'LineWidth', 0.75);
rectangle_center_x = (pos1(1) + pos2(1))/2;
rectangle_center_y = (pos1(2) + pos2(2))/2;
label_text(current_box_val) = text(rectangle_center_x, rectangle_center_y, ...
     class_label_input, ...
     'Color', rect_color, ...
     'BackgroundColor', 'white', ...
     'HorizontalAlignment', 'Center', ...
     'FontSize', 20);

% --- Outputs from this function are returned to the command line.
function varargout = label_tool_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pos1_handles;
global pos2_handles;
global current_box_val;
global label_text;
filename = strsplit(handles.filenames{handles.sliderval},'.');
fid = fopen(strcat(handles.pathname,filename{1},'.txt'), 'w');
for i = 1:current_box_val
    pos1 = getPosition(pos1_handles(i));
    pos2 = getPosition(pos2_handles(i));
    fprintf(fid, '%s %i %i %i %i\n', label_text(i).String , round(pos1(1)), round(pos1(2)), round(abs(pos1(1) - pos2(1))), round(abs(pos1(2) - pos2(2))));
end
fclose(fid);
set(handles.savebutton, 'Enable', 'off');
drawnow;
set(handles.savebutton, 'Enable', 'on');
guidata(hObject, handles);

function point1_function(pos)
draw_rectangle();


function point2_function(pos)
draw_rectangle();

% --- Executes on slider movement.
function imageslider_Callback(hObject, eventdata, handles)
% hObject    handle to imageslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = round(hObject.Value);
hObject.Value=val;
handles.sliderval = val;
cla(handles.axes1, 'reset');
imshow(handles.imagearray{val}, 'parent', handles.axes1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function imageslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function inputbox_Callback(hObject, eventdata, handles)
% hObject    handle to inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputbox as text
%        str2double(get(hObject,'String')) returns contents of inputbox as a double
set(handles.inputbox, 'Enable', 'off');
drawnow;
set(handles.inputbox, 'Enable', 'on');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function inputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browsebutton.
function browsebutton_Callback(hObject, eventdata, handles)
% hObject    handle to browsebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.defaultDirectory
    [filename, pathname] = uigetfile('*.png','Image Selection', 'MultiSelect', 'on', handles.pathname);
else
    [filename, pathname] = uigetfile('*.png','Image Selection', 'MultiSelect', 'on');
end
if isequal(filename,0)
    disp('User selected Cancel')
    handles.defaultDirectory = false;
else
    total_files = length(cellstr(filename));
    if(total_files > 1)
        set(handles.inputbox,'String',strcat(pathname));
        handles.imagearray = cell(1, total_files);
        for i = 1:total_files
            handles.imagearray{i} = imread(strcat(pathname, filename{i}));
        end
        handles.filenames = filename;
    else
        handles.imagearray{1} = imread(strcat(pathname, filename));
        set(handles.inputbox,'String',strcat(pathname,filename));
        handles.filenames{1} = filename;
    end
    handles.defaultDirectory = true;
    handles.pathname = pathname;
    
    sliderMin = 1;
    sliderMax = total_files;
    if sliderMax > sliderMin
        sliderStep = [1, 1] / (sliderMax - sliderMin);
        set(handles.imageslider,'visible','on')
    else
        sliderStep = [1, 1];
        set(handles.imageslider,'visible','off')
    end
    set(handles.imageslider,'Min', sliderMin);
    set(handles.imageslider,'Max', sliderMax);
    set(handles.imageslider,'SliderStep', sliderStep);
    set(handles.imageslider,'Value', sliderMin);
    handles.sliderval = 1;
    imageslider_Callback(hObject, eventdata, handles);
end
set(handles.browsebutton, 'Enable', 'off');
drawnow;
set(handles.browsebutton, 'Enable', 'on');
guidata(hObject, handles);



function class_label_input_Callback(hObject, eventdata, handles)
% hObject    handle to class_label_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of class_label_input as text
%        str2double(get(hObject,'String')) returns contents of class_label_input as a double
global class_label_input;
class_label_input = get(handles.class_label_input, 'String');
set(handles.class_label_input, 'Enable', 'off');
drawnow;
set(handles.class_label_input, 'Enable', 'on');
draw_rectangle();
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function class_label_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to class_label_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function process_user_input(hObject, eventdata, handles)
global pos1_handles;
global pos2_handles;
global pos1_callbacks;
global pos2_callbacks;
global current_box_val;
axes(handles.axes1);
[x, y] = ginput(1);
pos1_handles(current_box_val) = impoint(handles.axes1, x, y);

axes(handles.axes1);
[x, y] = ginput(1);
pos2_handles(current_box_val) = impoint(handles.axes1, x, y);

pos1_callbacks(current_box_val) = addNewPositionCallback(pos1_handles(current_box_val),@point1_function);
pos2_callbacks(current_box_val) = addNewPositionCallback(pos2_handles(current_box_val),@point2_function);
draw_rectangle();
guidata(hObject, handles);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global current_box_val;
global pos1_handles;
global pos2_handles;
global pos1_callbacks;
global pos2_callbacks;
keyPressed = eventdata.Key;
if strcmpi(keyPressed,'A')
    if isempty(eventdata.Modifier)
    elseif strcmp(eventdata.Modifier{:},'shift')
        current_box_val = current_box_val + 1;
        if current_box_val <= size(pos1_handles,2) && isvalid(pos1_handles(current_box_val))
            removeNewPositionCallback(pos1_handles(current_box_val), pos1_callbacks(current_box_val));
            delete(pos1_handles(current_box_val));
            %delete(rect(current_box_val));
        end
        if current_box_val <= size(pos2_handles,2) && isvalid(pos2_handles(current_box_val))
            removeNewPositionCallback(pos2_handles(current_box_val), pos2_callbacks(current_box_val));
            delete(pos2_handles(current_box_val));
            %delete(rect(current_box_val));
        end
        process_user_input(hObject, eventdata, handles);
    end
elseif strcmpi(keyPressed,'space')
    if isempty(eventdata.Modifier)
        if current_box_val <= size(pos1_handles,2) && isvalid(pos1_handles(current_box_val))
            for i = 1:length(pos1_callbacks)
                removeNewPositionCallback(pos1_handles(current_box_val), pos1_callbacks(current_box_val));
            end
            delete(pos1_handles);
            %delete(rect);
        end
        if current_box_val <= size(pos2_handles,2) && isvalid(pos2_handles(current_box_val))
            for i = 1:length(pos2_callbacks)
                removeNewPositionCallback(pos2_handles(current_box_val), pos2_callbacks(current_box_val));
            end
            delete(pos2_handles);
            %delete(rect);
        end
        current_box_val = 1;
    elseif strcmp(eventdata.Modifier{:},'shift')
        if current_box_val <= size(pos1_handles,2) && isvalid(pos1_handles(current_box_val))
            removeNewPositionCallback(pos1_handles(current_box_val), pos1_callbacks(current_box_val));
            delete(pos1_handles(current_box_val));
            %delete(rect(current_box_val));
        end
        if current_box_val <= size(pos2_handles,2) && isvalid(pos2_handles(current_box_val))
            removeNewPositionCallback(pos2_handles(current_box_val), pos2_callbacks(current_box_val));
            delete(pos2_handles(current_box_val));
            %delete(rect(current_box_val));
        end
    end
    process_user_input(hObject, eventdata, handles);
end
guidata(hObject, handles);


% --- Executes on selection change in rect_color_popmenu.
function rect_color_popmenu_Callback(hObject, eventdata, handles)
% hObject    handle to rect_color_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rect_color_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rect_color_popmenu
global rect_color;
str = get(handles.rect_color_popmenu, 'String');
val = get(handles.rect_color_popmenu,'Value');

switch str{val}
    case 'Red'
        rect_color = 'red';
    case 'Green'
        rect_color = 'green';
    case 'Blue'
        rect_color = 'blue';
    case 'Yellow'
        rect_color = 'yellow';
    case 'Magenta'
        rect_color = 'magenta';
    case 'Cyan'
        rect_color = 'cyan';
    case 'White'
        rect_color = 'white';
    case 'Black'
        rect_color = 'black';
end
set(handles.rect_color_popmenu, 'Enable', 'off');
drawnow;
set(handles.rect_color_popmenu, 'Enable', 'on');
draw_rectangle();
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function rect_color_popmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rect_color_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
