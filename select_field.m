function varargout = select_field(varargin)
% SELECT_FIELD MATLAB code for select_field.fig
%      SELECT_FIELD, by itself, creates a new SELECT_FIELD or raises the existing
%      singleton*.
%
%      H = SELECT_FIELD returns the handle to a new SELECT_FIELD or the handle to
%      the existing singleton*.
%
%      SELECT_FIELD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_FIELD.M with the given input arguments.
%
%      SELECT_FIELD('Property','Value',...) creates a new SELECT_FIELD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_field_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_field_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_field

% Last Modified by GUIDE v2.5 27-Jan-2018 20:21:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_field_OpeningFcn, ...
                   'gui_OutputFcn',  @select_field_OutputFcn, ...
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


% --- Executes just before select_field is made visible.
function select_field_OpeningFcn(hObject, eventdata, h, fields, msg, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to select_field (see VARARGIN)
  
  set(h.choose_descr,'String',msg);
  set(h.fields_listbox,'String',fields);
  
  
% Choose default command line output for select_field
h.output = 0;

% Update handles structure
guidata(hObject, h);

% UIWAIT makes select_field wait for user response (see UIRESUME)
uiwait(h.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = select_field_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = h.output;
%  varargout{1} = handles.output;
delete(hObject);

% --- Executes on selection change in fields_listbox.
function fields_listbox_Callback(hObject, eventdata, h)
% hObject    handle to fields_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fields_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fields_listbox


% --- Executes during object creation, after setting all properties.
function fields_listbox_CreateFcn(hObject, eventdata, h)
% hObject    handle to fields_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in confirm_button.
function confirm_button_Callback(hObject, eventdata, h)
% hObject    handle to confirm_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%    get(handles.fields_listbox,'Value');
%    handles.output = get(handles.fields_listbox,'Value');
  h.output = get(h.fields_listbox,'Value');
  guidata(hObject,h);
  close()

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, h)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  h.output = 0;
  guidata(hObject,h);
%    delete(handles.figure1);
  close()

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, h)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
