function varargout = ROI_matching(varargin)
% ROI_MATCHING MATLAB code for ROI_matching.fig
%      ROI_MATCHING, by itself, creates a new ROI_MATCHING or raises the existing
%      singleton*.
%
%      H = ROI_MATCHING returns the handle to a new ROI_MATCHING or the handle to
%      the existing singleton*.
%
%      ROI_MATCHING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_MATCHING.M with the given input arguments.
%
%      ROI_MATCHING('Property','Value',...) creates a new ROI_MATCHING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_matching_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_matching_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_matching

% Last Modified by GUIDE v2.5 05-Sep-2018 12:16:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_matching_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_matching_OutputFcn, ...
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


% --- Executes just before ROI_matching is made visible.
function ROI_matching_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_matching (see VARARGIN)
  
  
  %% process input
  mouse = varargin{1};
  h.pathMouse = pathcat('/home/wollex/Data/Documents/Uni/2016-XXXX_PhD/Japan/Work/Data/',sprintf('%d',mouse));
  
  %%% set h.data, footprint, xdata
  appdata = get(0,'ApplicationData');
  if nargin == 6
    footprints = varargin{3};
    h.data = varargin{4};
    setappdata(0,'footprints',footprints)
    setappdata(0,'data',h.data)
  elseif isfield(appdata,'footprints')
    footprints = getappdata(0,'footprints');
    h.data = getappdata(0,'data');
  else
    if nargin < 5
      nSes = [];
    else
      nSes = varargin{2};
    end
    [h.data footprints] = match_loadSessions(h.pathMouse,nSes);
    setappdata(0,'footprints',footprints)
    setappdata(0,'data',h.data)
  end
  
  if nargin == 7
    xdata = varargin{4};
    setappdata(0,'xdata',xdata)
  elseif isfield(appdata,'xdata')
    xdata = getappdata(0,'xdata');
  else
    [xdata, histo, para] = match_analyzeData(footprints,h.data.nSes,12);      %% calculate distances and footprint correlation
    [model,histo] = match_buildModel(xdata,histo,para,h.data.nSes,h.pathMouse);
  %    [ROC] = estimate_model_accuracy(histo,model,para,pathMouse);
    
    %% and assigning probabilities to each (close) pair
    xdata = match_assign_prob(xdata,h.data,model,para);
    setappdata(0,'xdata',xdata)
  end
  
  %%% set h.status
  h.status = struct;
  
  h.plots = struct;
  
  h.plots.c1 = struct;
  h.plots.c1.textbox = annotation('textbox',[0.25 0.44 0.06 0.035],'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
  h.plots.c1.ROI_textbox = annotation('textbox',[0 0 0 0],'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
  h.plots.c1.clusterstats_textbox = annotation('textbox',[0 0 0 0],'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
  h.plots.c1.picked = struct('cluster',[],'ROI',[NaN NaN],'ROI_stat',[NaN NaN]);
  
  h.plots.c2 = struct;
  h.plots.c2.ROI_textbox = annotation('textbox',[0 0 0 0],'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
  h.plots.c2.textbox = annotation('textbox',[0.69 0.44 0.06 0.035],'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
  h.plots.c2.clusterstats_textbox = annotation('textbox',[0 0 0 0],'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
  h.plots.c2.picked = struct('cluster',[],'ROI',[NaN NaN],'ROI_stat',[NaN NaN]);
  
  h.plots.c1.ax_ROI_display = h.ax_ROI_display;
  h.plots.c1.ax_ROI_display_stats = h.ax_ROI_display_stats;
  h.plots.c1.ax_clusterstats = h.ax_clusterstats;
  h.plots.c1.slider = h.slider_choose_cluster_ID_1;
  
  h.plots.c2.ax_ROI_display = h.ax_ROI_display2;
  h.plots.c2.ax_ROI_display_stats = h.ax_ROI_display_stats2;
  h.plots.c2.ax_clusterstats = h.ax_clusterstats2;
  h.plots.c2.slider = h.slider_choose_cluster_ID_2;
  
  h.parameter = struct('ROI_thr',0);
  
  h.dblclick = tic;
  
  % Choose default command line output for ROI_matching
  h.output = hObject;

  % Update handles structure
  guidata(hObject, h);

% UIWAIT makes ROI_matching wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_matching_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_clustering.
function button_clustering_Callback(hObject, eventdata, h)
% hObject    handle to button_clustering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
    
  disp('ROI_clustering...')
  
  appdata = get(0,'ApplicationData');
  pre_clustering(h);
  
  clusters = getappdata(0,'clusters');
  
  h = cluster2handle(h,clusters);
  
  
  %% after total number of clusters is known
  nCluster = 200;%length(clusters);
  h.data.nCluster = nCluster;
  
  h.plots.cluster = struct('thickness',cell(nCluster,1),'color',cell(nCluster,1));
  
  h.data.cluster_ct = zeros(h.data.nCluster,1);
  h.data.cluster_score = zeros(h.data.nCluster,1);
  h.data.cluster_centroids = zeros(h.data.nCluster,2);
  
  
  h.status.active = true(h.data.nCluster,1);
  h.status.completed = false(h.data.nCluster,1);
  h.status.deleted = false(h.data.nCluster,1);
  h.status.cluster_multiROI = false(h.data.nCluster,1);
  h.status.cluster_polyROI = false(h.data.nCluster,1);
  h.status.session = struct('deleted',cell(h.data.nSes,1),'visible',cell(h.data.nSes,1));
  
  for s = 1:h.data.nSes
    h.status.session(s).visible = true;
    h.status.session(s).deleted = false(h.data.session(s).nROI,1);
  end
  
  set(h.slider_choose_cluster_ID_1,'Min',0,'Max',h.data.nCluster,'SliderStep',[1/h.data.nCluster,10/h.data.nCluster],'Value',0)
  set(h.slider_choose_cluster_ID_2,'Min',0,'Max',h.data.nCluster,'SliderStep',[1/h.data.nCluster,10/h.data.nCluster],'Value',0)
  
  
  %% first run of updating data for all
  for c = 1:nCluster
    h = DUF(h,c,false);
  end
  clusters = getappdata(0,'clusters');
  h.data.cluster_centroids(1:nCluster,:) = cat(1,clusters.centroid);

  
  disp(sprintf('number of ROI_clusters: %d',nCluster))
  disp(sprintf('number of real ROI_clusters: %d',sum(h.data.cluster_ct > 1)))
  
  
  %%% initial plotting of all clusters
  load('/home/wollex/Data/Documents/Uni/2016-XXXX_PhD/Japan/Work/Data/884/Session01/reduced_MF1_LK1.mat','max_im')
  imagesc(h.ax_cluster_display,max_im,'Hittest','off')
  colormap(h.ax_cluster_display,'gray')
  
  for c = 1:nCluster
    h.plots.cluster_handles(c) = cluster_plot_blobs(h.ax_cluster_display,full(clusters(c).A),[],h.parameter.ROI_thr,'-',h.plots.clusters(c).color,h.plots.clusters(c).thickness);
  end
  xlim(h.ax_cluster_display,[1,h.data.imSize(2)])
  ylim(h.ax_cluster_display,[1,h.data.imSize(1)])
  
  set(h.ax_cluster_display,'ButtonDownFcn',@pickCluster,'Hittest','on','PickableParts','All');
  
  %% plot overall stats
  h.plots.histo_ct = histogram(h.ax_matchstats,h.data.cluster_ct(1:h.data.nCluster));
  xlim(h.ax_matchstats,[0,16])
  xlabel(h.ax_matchstats,'# Sessions')
  ylabel(h.ax_matchstats,'# clusters')
  
  h.plots.histo_score = histogram(h.ax_matchstats2,h.data.cluster_score(1:h.data.nCluster),linspace(0,1,21));
  xlim(h.ax_matchstats2,[0,1])
  xlabel(h.ax_matchstats2,'score')
  ylabel(h.ax_matchstats2,'# clusters')
  
  guidata(hObject, h);
  
  %% some GUI updates
  set(h.radio_plot_to_left,'Value',true)
  
  set(h.entry_cluster_ID_1,'enable','on')
  set(h.entry_cluster_ID_2,'enable','on')
  
  set(h.dropdown_filter_type,'enable','on')
  set(h.dropdown_filter_ll_gg,'enable','on')
  set(h.entry_filter_value,'enable','on')
  
  
  
  

function entry_display_session_Callback(hObject, eventdata, h)
% hObject    handle to entry_display_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of entry_display_session as text
%        str2double(get(hObject,'String')) returns contents of entry_display_session as a double
  
  for s = 1:h.data.nSes
    h.status.session(s).visible = false;
  end
  
  s_vis = str2num(get(h.entry_display_session,'String'));
  if isempty(s_vis)
    s_vis = 0;
    set(h.entry_display_session,'String',sprintf('%d',s_vis))
  elseif s_vis
    h.status.session(s_vis).visible = true;
    if s_vis == h.data.nSes
      set(h.button_next_session,'enable','off')
    else
      set(h.button_next_session,'enable','on')
    end
    set(h.button_prev_session,'enable','on')
  elseif ~s_vis
    set(h.button_prev_session,'enable','off')
  end
  guidata(hObject,h)
  
  if get(h.radio_plot_to_left,'Value');
    ax_handle = h.plots.c1;
  else
    ax_handle = h.plots.c2;
  end
  display_sessions(h,ax_handle)
  
  
% --- Executes during object creation, after setting all properties.
function entry_display_session_CreateFcn(hObject, eventdata, h)
% hObject    handle to entry_display_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_prev_session.
function button_prev_session_Callback(hObject, eventdata, h)
% hObject    handle to button_prev_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  %% remove earlier visibility
  s_vis = str2num(get(h.entry_display_session,'String'));
  if isempty(s_vis)
    s_vis = 0;
    for s = 1:h.data.nSes
      h.status.session(s).visible = false;
    end
  else
    h.status.session(s_vis).visible = false;
  
    %% add updated visibility
    s_vis = s_vis-1;
  end
  
  if s_vis
    h.status.session(s_vis).visible = true;
  end
  set(h.entry_display_session,'String',sprintf('%d',s_vis))
  guidata(hObject,h)
  
  if get(h.radio_plot_to_left,'Value');
    ax_handle = h.plots.c1;
  else
    ax_handle = h.plots.c2;
  end
  display_sessions(h,ax_handle)
  
  if s_vis == 0
    set(h.button_prev_session,'enable','off')
  else
    set(h.button_prev_session,'enable','on')
  end
  set(h.button_next_session,'enable','on')

% --- Executes on button press in button_next_session.
function button_next_session_Callback(hObject, eventdata, h)
% hObject    handle to button_next_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  %% remove earlier visibility
  s_vis = str2num(get(h.entry_display_session,'String'));
  if isempty(s_vis)
    s_vis = 0;
    for s = 1:h.data.nSes
      h.status.session(s).visible = false;
    end
  else
    if s_vis
      h.status.session(s_vis).visible = false;
    end
    
    %% add updated visibility
    s_vis = s_vis+1;
  end
  h.status.session(s_vis).visible = true;
  
  set(h.entry_display_session,'String',sprintf('%d',s_vis))
  guidata(hObject,h)
  
  if get(h.radio_plot_to_left,'Value');
    ax_handle = h.plots.c1;
  else
    ax_handle = h.plots.c2;
  end
  display_sessions(h,ax_handle)
  
  if s_vis == h.data.nSes
    set(h.button_next_session,'enable','off')
  else
    set(h.button_next_session,'enable','on')
  end
  set(h.button_prev_session,'enable','on')

% --- Executes on button press in checkbox_show_all_sessions.
function checkbox_show_all_sessions_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_show_all_sessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_all_sessions
  
  if get(h.checkbox_show_all_sessions,'Value')
    for s = 1:h.data.nSes
      h.status.session(s).visible = true;
    end
    set(h.button_next_session,'enable','off')
    set(h.button_prev_session,'enable','off')
    set(h.entry_display_session,'enable','off')
  else
    for s = 1:h.data.nSes
      h.status.session(s).visible = false;
    end
    s_vis = str2num(get(h.entry_display_session,'String'));
    if isempty(s_vis) || ~s_vis
      s_vis = 0;
      set(h.entry_display_session,'String',sprintf('%d',s_vis))
    else
      h.status.session(s_vis).visible = true;
    end
    
    if s_vis < h.data.nSes
      set(h.button_next_session,'enable','on')
    end
    
    if s_vis > 0
      set(h.button_prev_session,'enable','on')
    end
    
    set(h.entry_display_session,'enable','on')
  end
  
  if get(h.radio_plot_to_left,'Value');
    ax_handle = h.plots.c1;
  else
    ax_handle = h.plots.c2;
  end
  display_sessions(h,ax_handle)
  guidata(hObject,h)



% --- Executes during object creation, after setting all properties.
function entry_thr_occurence_CreateFcn( hObject, eventdata, handles)
% hObject    handle to entry_thr_occurence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_rotate3d.
function checkbox_rotate3d_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rotate3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_rotate3d


% --- Executes on button press in button_discard_cluster.
function button_discard_cluster_Callback(hObject, eventdata, h)
% hObject    handle to button_discard_cluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  if get(h.radio_plot_to_left,'Value');
    c = h.plots.c1.picked.cluster;
  else
    c = h.plots.c2.picked.cluster;
  end
  
  h = remove_cluster(h,c);
  guidata(hObject,h)
  

% --- Executes on button press in radio_clusterdisplay_2D.
function radio_clusterdisplay_2D_3D_Callback(hObject, eventdata, h)
% hObject    handle to radio_clusterdisplay_2D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_clusterdisplay_2D
  
  if get(h.radio_plot_to_left,'Value');
    c = h.plots.c1.picked.cluster;
    if ~isempty(c)
      [h, ax_handle] = plot_cluster(h,h.plots.c1,c);
      h.plots.c1 = ax_handle;
    end
  else
    c = h.plots.c2.picked.cluster;
    if ~isempty(c)
      [h, ax_handle] = plot_cluster(h,h.plots.c2,c);
      h.plots.c2 = ax_handle;
    end
  end
  guidata(hObject,h);
  
  

% --- Executes on button press in checkbox_checked.
function checkbox_checked_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_checked (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_checked



function entry_ROI_adjacency_Callback(hObject, eventdata, h)
% hObject    handle to entry_ROI_adjacency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of entry_ROI_adjacency as text
%        str2double(get(hObject,'String')) returns contents of entry_ROI_adjacency as a double
  
  if get(h.radio_plot_to_left,'Value');
    c = h.plots.c1.picked.cluster;
    if ~isempty(c)
      [h, ax_handle] = plot_cluster(h,h.plots.c1,c);
      h.plots.c1 = ax_handle;
    end
  else
    c = h.plots.c2.picked.cluster;
    if ~isempty(c)
      [h, ax_handle] = plot_cluster(h,h.plots.c2,c);
      h.plots.c2 = ax_handle;
    end
  end
  guidata(hObject,h);
  

% --- Executes on button press in radio_clusterstats_dist.
function radio_clusterstats_Callback(hObject, eventdata, h)
% hObject    handle to radio_clusterstats_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_clusterstats_dist
  
  clusters = getappdata(0,'clusters');
  
  if get(h.radio_plot_to_left,'Value');
    c = h.plots.c1.picked.cluster;
    if ~isempty(c)
      h.plots.c1 = PUF_cluster_stats(h,h.plots.c1,clusters(c),c)
    end
  else
    c = h.plots.c2.picked.cluster;
    if ~isempty(c)
      h.plots.c2 = PUF_cluster_stats(h,h.plots.c2,clusters(c),c);
    end
  end
  guidata(hObject,h);
  
  
  
% --- Executes on button press in checkbox_filter_active.
function checkbox_filter_active_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_filter_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_filter_active
  
  filter_active = get(h.checkbox_filter_active,'Value');
  filter_type_val = get(h.dropdown_filter_type,'Value');
  filter_val = str2double(get(h.entry_filter_value,'String'));
  if filter_active && filter_type_val>1 && ~isnan(filter_val) || ~filter_active
    h = apply_filter(h);
    guidata(hObject,h)
  end
  



% --- Executes on selection change in dropdown_filter_type.
function dropdown_filter_type_Callback(hObject, eventdata, h)
% hObject    handle to dropdown_filter_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dropdown_filter_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdown_filter_type
  
  filter_active = get(h.checkbox_filter_active,'Value');
  filter_type_val = get(h.dropdown_filter_type,'Value');
  filter_val = str2double(get(h.entry_filter_value,'String'));
  if filter_active && filter_type_val>1 && ~isnan(filter_val)
    h = apply_filter(h);
    guidata(hObject,h)
  end
  
  if filter_type_val>1 && ~isnan(filter_val)
    act = 'on';
  else
    act = 'off';
    set(h.checkbox_filter_active,'Value',0)
  end
  set(h.checkbox_filter_active,'enable',act)
  set(h.dropdown_filter2_type,'enable',act)
  set(h.dropdown_filter2_ll_gg,'enable',act)
  set(h.entry_filter2_value,'enable',act)
  

% --- Executes during object creation, after setting all properties.
function dropdown_filter_type_CreateFcn(hObject, eventdata, h)
% hObject    handle to dropdown_filter_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end
  dropdown_filter_type_string = cellstr(['Specify filter 1...';...
                                         'Session occurence  ';...
                                         'ROI score          ';...
                                         'finished process   ';...
                                         'Multi-assignment   ';...
                                         'Polygamous ROIs    ']);
  
  set(hObject,'String',dropdown_filter_type_string,'Value',1);
  

% --- Executes on selection change in dropdown_filter_ll_gg.
function dropdown_filter_ll_gg_Callback(hObject, eventdata, h)
% hObject    handle to dropdown_filter_ll_gg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dropdown_filter_ll_gg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdown_filter_ll_gg
  
  filter_active = get(h.checkbox_filter_active,'Value');
  filter_type_val = get(h.dropdown_filter_type,'Value');
  filter_val = str2double(get(h.entry_filter_value,'String'));
  if filter_active && filter_type_val>1 && ~isnan(filter_val)
    h = apply_filter(h);
    guidata(hObject,h)
  end
  
  if filter_type_val>1 && ~isnan(filter_val)
    act = 'on';
  else
    act = 'off';
    set(h.checkbox_filter_active,'Value',0)
  end
  set(h.checkbox_filter_active,'enable',act)
  set(h.dropdown_filter2_type,'enable',act)
  set(h.dropdown_filter2_ll_gg,'enable',act)
  set(h.entry_filter2_value,'enable',act)
  
  
% --- Executes during object creation, after setting all properties.
function dropdown_filter_ll_gg_CreateFcn(hObject, eventdata, h)
% hObject    handle to dropdown_filter_ll_gg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end
  dropdown_filter_ll_gg_string = cellstr(['<';'>']);
  set(hObject,'String',dropdown_filter_ll_gg_string,'Value',2);


function entry_filter_value_Callback(hObject, eventdata, h)
% hObject    handle to entry_filter_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of entry_filter_value as text
%        str2double(get(hObject,'String')) returns contents of entry_filter_value as a double

  filter_active = get(h.checkbox_filter_active,'Value');
  filter_type_val = get(h.dropdown_filter_type,'Value');
  filter_val = str2double(get(h.entry_filter_value,'String'));
  if filter_active && filter_type_val>1 && ~isnan(filter_val)
    h = apply_filter(h);
    guidata(hObject,h)
  end
  
  if filter_type_val>1 && ~isnan(filter_val)
    act = 'on';
  else
    act = 'off';
    set(h.checkbox_filter_active,'Value',0)
  end
  set(h.checkbox_filter_active,'enable',act)
  set(h.dropdown_filter2_type,'enable',act)
  set(h.dropdown_filter2_ll_gg,'enable',act)
  set(h.entry_filter2_value,'enable',act)
  


% --- Executes on selection change in dropdown_filter2_ll_gg.
function dropdown_filter2_ll_gg_Callback(hObject, eventdata, h)
% hObject    handle to dropdown_filter2_ll_gg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dropdown_filter2_ll_gg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdown_filter2_ll_gg

  filter_active = get(h.checkbox_filter_active,'Value');
  filter_type_val = get(h.dropdown_filter2_type,'Value');
  filter_val = str2double(get(h.entry_filter2_value,'String'));
  if filter_active && filter_type_val>1 && ~isnan(filter_val)
    h = apply_filter(h);
    guidata(hObject,h)
  end
  

% --- Executes during object creation, after setting all properties.
function dropdown_filter2_ll_gg_CreateFcn(hObject, eventdata, h)
% hObject    handle to dropdown_filter2_ll_gg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end
  dropdown_filter_ll_gg_string = cellstr(['<';'>']);
  set(hObject,'String',dropdown_filter_ll_gg_string,'Value',2);


function entry_filter2_value_Callback(hObject, eventdata, h)
% hObject    handle to entry_filter2_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of entry_filter2_value as text
%        str2double(get(hObject,'String')) returns contents of entry_filter2_value as a double
  
  filter_active = get(h.checkbox_filter_active,'Value');
  filter_type_val = get(h.dropdown_filter2_type,'Value');
  filter_val = str2double(get(h.entry_filter2_value,'String'));
  if filter_active && filter_type_val>1 && ~isnan(filter_val)
    h = apply_filter(h);
    guidata(hObject,h)
  end


% --- Executes on selection change in dropdown_filter2_type.
function dropdown_filter2_type_Callback(hObject, eventdata, h)
% hObject    handle to dropdown_filter2_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dropdown_filter2_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdown_filter2_type

  filter_active = get(h.checkbox_filter_active,'Value');
  filter_type_val = get(h.dropdown_filter2_type,'Value');
  filter_val = str2double(get(h.entry_filter2_value,'String'));
  if filter_active && filter_type_val>1 && ~isnan(filter_val)
    h = apply_filter(h);
    guidata(hObject,h)
  end
  

% --- Executes during object creation, after setting all properties.
function dropdown_filter2_type_CreateFcn(hObject, eventdata, h)
% hObject    handle to dropdown_filter2_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end
  dropdown_filter_type_string = cellstr(['Specify filter 2...';...
                                         'Session occurence  ';...
                                         'ROI score          ';...
                                         'finished process   ';...
                                         'Multi-assignment   ';...
                                         'Polygamous ROIs    ']);
  
  set(hObject,'String',dropdown_filter_type_string,'Value',1);
  
  

  

function entry_cluster_ID_1_Callback(hObject, eventdata, h)
% hObject    handle to entry_cluster_ID_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of entry_cluster_ID_1 as text
%        str2double(get(hObject,'String')) returns contents of entry_cluster_ID_1 as a double
  
  c = str2num(get(h.entry_cluster_ID_1,'String'));
  h = choose_cluster(h,c,'left');
  guidata(hObject,h)
 
  
  
% --- Executes on button press in checkbox_finished.
function checkbox_finished_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_finished (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_finished
  
  if get(h.radio_plot_to_left,'Value')
    c = h.plots.c1.picked.cluster;
  else
    c = h.plots.c2.picked.cluster;
  end
  h.status.completed(c) = logical(get(h.checkbox_finished,'Value'));
  
  if h.status.completed(c)
    set(h.plots.cluster_handles(c),'LineStyle',':')
  else
    set(h.plots.cluster_handles(c),'LineStyle','-')
  end
  DUF_process_info(h)
  guidata(hObject,h)


% --- Executes on button press in button_multi_remove_IDs.
function button_multi_remove_IDs_Callback(hObject, eventdata, h)
% hObject    handle to button_multi_remove_IDs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  if get(h.radio_plot_to_left,'Value')
    c = h.plots.c1.picked.cluster;
  else
    c = h.plots.c2.picked.cluster;
  end
  
  xdata = getappdata(0,'xdata');
  
  for s = 1:h.data.nSes
    for i = 1:h.data.clusters(c).occupancy(s)
      n = h.data.clusters(c).session(s).list(i);
      h = clear_ID(h,xdata,c,s,n);
    end
  end
  
  h = DUF_cluster_status(h,c);
  PUF_assignment_stats(h,get_axes(h,c),c)
  guidata(hObject,h)
  


% --- Executes on button press in checkbox_ROI_unsure.
function checkbox_ROI_unsure_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_ROI_unsure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ROI_unsure


% --- Executes on button press in button_active_clusters_finished.
function button_active_clusters_finished_Callback(hObject, eventdata, h)
% hObject    handle to button_active_clusters_finished (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of button_active_clusters_finished
  
  idx = find(h.status.active);
  
  if all(~h.status.completed(h.status.active))
    h.status.completed(h.status.active) = true;
    
    for c = idx
      set(h.plots.cluster_handles(c),'LineStyle',':')
    end
  else
    h.status.completed(h.status.active) = false;
    
    for c = idx
      set(h.plots.cluster_handles(c),'LineStyle','-')
    end
  end
  DUF_process_info(h)
  guidata(hObject,h)
  
  
% --- Executes on slider movement.
function slider_choose_cluster_ID_2_Callback(hObject, eventdata, h)
% hObject    handle to slider_choose_cluster_ID_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
  
  c = round(get(hObject, 'Value'));
  
  direction = sign(c-h.plots.c2.picked.cluster);
  
  %% find next active
  while ~h.status.active(c)
    if direction > 0
      c = mod(c,h.data.nCluster)+1;
    else
      c = mod(c-2,h.data.nCluster)+1;
    end
    
  end
  
  set(hObject, 'Value', c);
  set(h.entry_cluster_ID_2,'String',sprintf('%d',c))
  
  h = choose_cluster(h,c,'right');
  guidata(hObject,h)

% --- Executes during object creation, after setting all properties.
function slider_choose_cluster_ID_2_CreateFcn(hObject, eventdata, h)
% hObject    handle to slider_choose_cluster_ID_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
  if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor',[.9 .9 .9]);
  end
  
  set(hObject,'enable','off')

  
% --- Executes on slider movement.
function slider_choose_cluster_ID_1_Callback(hObject, eventdata, h)
% hObject    handle to slider_choose_cluster_ID_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
  
  c = round(get(hObject, 'Value'));
  %% get direction
  direction = sign(c-h.plots.c1.picked.cluster);
  
  %% find next active
  while ~h.status.active(c)
    if direction > 0
      c = mod(c,h.data.nCluster)+1;
    else
      c = mod(c-2,h.data.nCluster)+1;
    end
    
  end
  
  set(hObject, 'Value', c);
  set(h.entry_cluster_ID_1,'String',sprintf('%d',c))
  
  h = choose_cluster(h,c,'left');
  guidata(hObject,h)

% --- Executes during object creation, after setting all properties.
function slider_choose_cluster_ID_1_CreateFcn(hObject, eventdata, h)
% hObject    handle to slider_choose_cluster_ID_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
  if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor',[.9 .9 .9]);
  end
  
  set(hObject,'enable','off')
  
  
% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, h)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10



function entry_cluster_ID_2_Callback(hObject, eventdata, h)
% hObject    handle to entry_cluster_ID_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of entry_cluster_ID_2 as text
%        str2double(get(hObject,'String')) returns contents of entry_cluster_ID_2 as a double

  c = str2num(get(h.entry_cluster_ID_2,'String'));
  h = choose_cluster(h,c,'right');
  guidata(hObject,h)
  
  
% --- Executes during object creation, after setting all properties.
function entry_cluster_ID_2_CreateFcn(hObject, eventdata, h)
% hObject    handle to entry_cluster_ID_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radio_plot_to_left.
function radio_plot_to_left_Callback(hObject, eventdata, h)
% hObject    handle to radio_plot_to_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_plot_to_left
  
  set(h.radio_plot_to_right,'Value',~get(hObject,'Value'))


% --- Executes on button press in radio_plot_to_right.
function radio_plot_to_right_Callback(hObject, eventdata, h)
% hObject    handle to radio_plot_to_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_plot_to_right
  
  set(h.radio_plot_to_left,'Value',~get(hObject,'Value'))



% --- Executes on button press in button_remove_ROIs.
function button_remove_ROIs_Callback(hObject, eventdata, h)
% hObject    handle to button_remove_ROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  if get(h.radio_plot_to_left,'Value')
    c = h.plots.c1.picked.cluster;
  else
    c = h.plots.c2.picked.cluster;
  end
  
  for s = 1:h.data.nSes
    for n = h.data.clusters(c).session(s).list
      h = remove_ROI(h,s,n)
    end
  end
  
  h = remove_cluster(h,c);
  guidata(hObject,h)



%%% -------------------------------------- other functions -------------------------------------%%%

function h = choose_cluster(h,c,side)

  if nargin == 3
    side_left = strcmp(side,'left');
  else
    side_left = get(h.radio_plot_to_left,'Value');
  end
  
  if isempty(c) || isnan(c) || c < 1 || c > h.data.nCluster
    c = [];
  end
  
  if side_left;
    if ~isempty(h.plots.c1.picked.cluster)
      set(h.plots.cluster_handles(h.plots.c1.picked.cluster),'Color',h.plots.clusters(h.plots.c1.picked.cluster).color)
    end
    h.plots.c1.picked.cluster = c;
    PUF_cluster_textbox(h,h.plots.c1,c)
    [h, ax_handle] = plot_cluster(h,h.plots.c1,c);
    h.plots.c1 = ax_handle;
    set(h.entry_cluster_ID_1,'String',sprintf('%d',c))
  else
    if ~isempty(h.plots.c2.picked.cluster)
      set(h.plots.cluster_handles(h.plots.c2.picked.cluster),'Color',h.plots.clusters(h.plots.c2.picked.cluster).color)
    end
    h.plots.c2.picked.cluster = c;
    PUF_cluster_textbox(h,h.plots.c2,c)
    [h, ax_handle] = plot_cluster(h,h.plots.c2,c);
    h.plots.c2 = ax_handle;
    set(h.entry_cluster_ID_2,'String',sprintf('%d',c))
  end
  
  
  
  if ~isempty(c)
    set(h.plots.cluster_handles(c),'Color','m')
    
    set(h.checkbox_finished,'Value',h.status.completed(c),'enable','on')
    if side_left
      set(h.plots.c1.slider,'Value',c)
    else
      set(h.plots.c2.slider,'Value',c)
    end
  else
    set(h.checkbox_finished,'Value',0,'enable','off')
    if side_left
      set(h.plots.c1.slider,'Value',0)
    else
      set(h.plots.c2.slider,'Value',0)
    end
  end


function h = apply_filter(h)
  
  filter_active = get(h.checkbox_filter_active,'Value');
  
  filter_type_val = get(h.dropdown_filter_type,'Value');
  filter_type_str = get(h.dropdown_filter_type,'String');
  filter_type = filter_type_str{filter_type_val};
  
  filter_ll_gg_val = get(h.dropdown_filter_ll_gg,'Value');
  filter_ll_gg_str = get(h.dropdown_filter_ll_gg,'String');
  filter_ll_gg = filter_ll_gg_str{filter_ll_gg_val};
  
  filter_val = str2double(get(h.entry_filter_value,'String'));
  
  if filter_active && filter_type_val>1 && ~isempty(filter_val) 
    
    filter2_type_val = get(h.dropdown_filter2_type,'Value');
    filter2_type_str = get(h.dropdown_filter2_type,'String');
    filter2_type = filter2_type_str{filter2_type_val};
    
    filter2_ll_gg_val = get(h.dropdown_filter2_ll_gg,'Value');
    filter2_ll_gg_str = get(h.dropdown_filter2_ll_gg,'String');
    filter2_ll_gg = filter2_ll_gg_str{filter2_ll_gg_val};
    
    filter2_val = str2double(get(h.entry_filter2_value,'String'));
    
    switch filter_type
      case 'Session occurence'
        stats = h.data.cluster_ct;
      case 'ROI score'
        stats = h.data.cluster_score;
      case 'Multi-assignment'
        stats = h.status.cluster_multiROI;
      case 'finished process'
        stats = h.status.completed;
      case 'Polygamous ROIs'
        stats = h.status.cluster_polyROI;
    end
    
    switch filter_ll_gg
      case '<'
        h.status.active = stats < filter_val & ~h.status.deleted;
      case '>'
        h.status.active = stats > filter_val & ~h.status.deleted;
    end
    
    if filter2_type_val>1 && ~isempty(filter2_val)
      switch filter2_type
        case 'Session occurence'
          stats = h.data.cluster_ct;
        case 'ROI score'
          stats = h.data.cluster_score;
        case 'Multi-assignment'
          stats = h.status.cluster_multiROI;
        case 'finished process'
          stats = h.status.completed;
        case 'Polygamous ROIs'
          stats = h.status.cluster_polyROI;
      end
      
      switch filter2_ll_gg
        case '<'
          h.status.active = h.status.active & stats < filter2_val & ~h.status.deleted;
        case '>'
          h.status.active = h.status.active & stats > filter2_val & ~h.status.deleted;
      end
    end
    
    if ~h.status.active(h.plots.c1.picked.cluster)
      h = choose_cluster(h,[],'left');
    end
    if ~h.status.active(h.plots.c2.picked.cluster)
      h = choose_cluster(h,[],'right');
    end
    
  else
    h.status.active = ~h.status.deleted;
  end
  
  for c = 1:h.data.nCluster
    if ~h.status.deleted(c)
      if h.status.active(c)
        set(h.plots.cluster_handles(c),'Visible','on')
      else
        set(h.plots.cluster_handles(c),'Visible','off')
      end
    end
  end
  DUF_process_info(h)


  
function display_sessions(h,ax_handle)
  
  c = ax_handle.picked.cluster;
  
  for s = 1:h.data.nSes
    if length(ax_handle.session(s).ROI_ID)
      if h.status.session(s).visible
        vis = 'on';
      else
        vis = 'off';
      end
      for i = 1:length(ax_handle.session(s).ROI_ID)
        n = ax_handle.session(s).ROI_ID(i);
        if ~ismember(n,h.data.clusters(c).session(s).list)
          set(ax_handle.session(s).ROI(i),'Visible',vis)
        end
      end
    end
  end
  
  
  
function [disallowRotation] = myRotateFilter(obj,eventdata)
  disallowRotation = false;
  % if a ButtonDownFcn has been defined for the object, then use that
  if isfield(get(obj),'ButtonDownFcn')
      disallowRotation = ~isempty(get(obj,'ButtonDownFcn'));
  end
  
  
  
function click_ROI(hObject,eventdata,ID,ax_ID)
  
  h = guidata(hObject);
% ID contains: (c,s,n)
  c = ID(1);
  s = ID(2);
  n = ID(3);
  
  t = toc(h.dblclick);
  
  f = hObject.Parent.Parent;
  if ~strcmp(f.SelectionType, 'alt')
    
    if ax_ID == 1 && t < 0.3   %% doubleclick (not on clusterstats)
      if eq(hObject.Parent,h.plots.c1.ax_ROI_display) || eq(hObject.Parent,h.plots.c1.ax_clusterstats)
        toggle_belong(hObject,eventdata,ID);
        h = guidata(hObject);
      else
        toggle_belong(hObject,eventdata,ID);
        h = guidata(hObject);
      end
      h.dblclick = tic-2; %% disable double click trigger for next click
    else
      if eq(hObject.Parent,h.plots.c1.ax_ROI_display) || eq(hObject.Parent,h.plots.c1.ax_clusterstats)
        [h ax_handle] = display_ROI_info(h,h.plots.c1,hObject,ax_ID,ID);
        h.plots.c1 = ax_handle;
      else
        [h ax_handle] = display_ROI_info(h,h.plots.c2,hObject,ax_ID,ID);
        h.plots.c2 = ax_handle;
      end
      
      h.dblclick = tic;
    end
    
    guidata(hObject,h)
  end
  
  
function pickCluster(hObject,eventdata)

  h = guidata(hObject);
  
  clusters = getappdata(0,'clusters');
  coords = get(hObject,'CurrentPoint');
  
  if get(h.radio_plot_to_left,'Value')
    c_old = h.plots.c1.picked.cluster;
  else
    c_old = h.plots.c2.picked.cluster;
  end
  
  [min_val c_idx] = min(sum((h.data.cluster_centroids(h.status.active,1)-coords(1,2)).^2 + (h.data.cluster_centroids(h.status.active,2)-coords(1,1)).^2,2));
  idxes = find(h.status.active);
  c = idxes(c_idx);
  
  if sqrt(min_val) < 10
    pt = hgconvertunits(gcf, [get(gcf, 'CurrentPoint') 1 1], ...
                    get(gcf, 'Units'), 'Normalized', gcf);
    if c == c_old
      c = [];
    end
    h = choose_cluster(h,c);
    guidata(hObject,h)
  end
  
  

function h = clear_ID(h,xdata,c,s,n)
  
  clusters = getappdata(0,'clusters');
  
  for c_other = setdiff(h.data.session(s).ROI(n).cluster_ID,c)
    ax_handle = get_axes(h,c_other);
    
    cluster_IDs = setdiff(h.data.clusters(c_other).session(s).list,n);
    
    h.data.clusters(c_other).session(s).list = cluster_IDs;
    clusters(c_other).session(s).list = cluster_IDs;
    
    h = DUF_cluster_occupancy(h,c_other);
    h = DUF_cluster_status(h,c_other);
    [h,clusters(c_other)] = DUF_cluster_stats(h,xdata,clusters(c_other),c_other);
    clusters = DUF_cluster_shape(h,clusters,c_other);
    
    delete(h.plots.cluster_handles(c_other))
    h.plots.cluster_handles(c_other) = cluster_plot_blobs(h.ax_cluster_display,full(clusters(c_other).A),[],h.parameter.ROI_thr,'-','m',h.plots.clusters(c_other).thickness);
    
    PUF_assignment_stats(h,ax_handle,c_other)
    PUF_ROI_face(h,ax_handle,[c_other,s,n])
    PUF_cluster_textbox(h,ax_handle,c_other)
    
  end
  h.data.session(s).ROI(n).cluster_ID = c;
  
  setappdata(0,'clusters',clusters)
  
  for c_other = setdiff(h.data.session(s).ROI(n).cluster_ID,c)
    ax_handle = get_axes(h,c_other);
    
    h = DUF_cluster_occupancy(h,c_other);
    h = DUF_cluster_status(h,c_other);
    PUF_assignment_stats(h,ax_handle,c_other)
    PUF_ROI_face(h,ax_handle,[c_other,s,n])
  end
  
  

function h = remove_cluster(h,c)
 
 %% popupmsg to notify, that a cluster has been removed
  disp(sprintf('Uh oh, cluster %d was stripped of all of its ROIs. Removing!',c))
  
  clusters = getappdata(0,'clusters');
    
  clusters(c).session = [];
  clusters(c).score: NaN;
  clusters(c).ct = 0;
  clusters(c).A = [];
  clusters(c).centroid = [NaN NaN];
  
  h.data.clusters(c).session = [];
  h.data.clusters(c).occupancy = [];
  h.data.clusters(c).polyROI = [];
  
  setappdata(0,'clusters',clusters)
  
  %% remove cluster plot from overview
  delete(h.plots.cluster_handles(c))
  
  %% set all status value to false (not changeable by filters or smth)
  h.status.clusters_polyROI(c) = false;
  h.status.cluster_multiROI(c) = false;
  h.status.active(c) = false;
  h.status.completed(c) = false;
  h.status.deleted(c) = true;
  
  h.data.cluster_ct(c) = NaN;
  h.data.cluster_score(c) = NaN;
  
  if h.plots.c1.picked.cluster == c
    h.plots.c1.picked.cluster = [];
  elseif h.plots.c2.picked.cluster == c
    h.plots.c2.picked.cluster = [];
  end
  
  %% update status values and texts
  DUF_process_info(h)
  
    
function ax_handle = get_axes(h,c)
  if h.plots.c1.picked.cluster == c
    ax_handle = h.plots.c1;
  elseif h.plots.c2.picked.cluster == c
    ax_handle = h.plots.c2;
  else
    ax_handle = [];
  end
  
  
  
  
%%% ---------------------------------- end: other functions ------------------------------------%%%


%%% ------------------------------ start: data updating functions (DUF) ------------------------------%%%


function h = DUF(h,c,calc)
  
  if nargin == 3
    h.status.clusters(c) = struct('calc_occupancy',calc,'calc_status',calc,'calc_shape',calc,'calc_stats',calc);
  end
  
  h = DUF_cluster_occupancy(h,c);
  h = DUF_cluster_status(h,c);
  
  if ~h.status.clusters(c).calc_shape || ~h.status.clusters(c).calc_stats
    clusters = getappdata(0,'clusters');
    clusters(c) = DUF_cluster_shape(h,clusters(c),c);
    [h, clusters(c)] = DUF_cluster_stats(h,clusters(c),c);
    setappdata(0,'clusters',clusters)
  end
  
  DUF_process_info(h)
  
  
function h = DUF_cluster_occupancy(h,c)   %% 1st
  
  if ~h.status.clusters(c).calc_occupancy
    h.data.clusters(c).occupancy = zeros(h.data.nSes,1);
    for s = 1:h.data.nSes
      h.data.clusters(c).occupancy(s) = length(h.data.clusters(c).session(s).list);
    end
    h.data.cluster_ct(c) = nnz(h.data.clusters(c).occupancy);
    h.plots.clusters(c).thickness = h.data.cluster_ct(c)/h.data.nSes * 3;

    if ~h.data.cluster_ct(c)
      h = remove_cluster(h,c);
    end
    h.status.clusters(c).calc_occupancy = true;
  end
  
  
function h = DUF_cluster_status(h,c)    %% 2nd
  
  if ~h.status.clusters(c).calc_status
    h.status.cluster_multiROI(c) = any(h.data.clusters(c).occupancy>1); %% multiple ROIs assigned in any session?
    
    h.status.cluster_polyROI(c) = false;
    h.data.clusters(c).polyROI = zeros(h.data.nSes,1);
    
    for s = 1:h.data.nSes
      for i = 1:h.data.clusters(c).occupancy(s)
        n = h.data.clusters(c).session(s).list(i);
        polyROI = length(h.data.session(s).ROI(n).cluster_ID);
        h.data.clusters(c).polyROI(s) = max(h.data.clusters(c).polyROI(s),polyROI);
        h.status.cluster_polyROI(c) = h.status.cluster_polyROI(c) || polyROI>1;
      end
    end
    h.status.clusters(c).calc_status = true;
  end
  
  
function clusters = DUF_cluster_shape(h,clusters,c)   %% 3rd
  
  if ~h.status.clusters(c).calc_shape
    footprints = getappdata(0,'footprints');
    
    clusters.A = sparse(h.data.imSize(1),h.data.imSize(2));
    
    for s = 1:h.data.nSes
      for i = 1:h.data.clusters(c).occupancy(s)
        n = h.data.clusters(c).session(s).list(i);
        clusters.A = clusters.A + footprints.session(s).ROI(n).A;
      end
    end
    clusters.A = sparse(clusters.A/sum(clusters.A(:)));
    clusters.centroid = [sum((1:h.data.imSize(1))*clusters.A),sum(clusters.A*(1:h.data.imSize(2))')];
    
    h.status.clusters(c).calc_shape = true;
  end
  
function [h, clusters] = DUF_cluster_stats(h,clusters,c)    % 4th
  
  if ~h.status.clusters(c).calc_stats
    
    xdata = getappdata(0,'xdata');
    
    if h.data.cluster_ct(c) > 1
      %% preparing data
      width = max(h.data.clusters(c).occupancy);
      for s = 1:h.data.nSes
        for i = 1:h.data.clusters(c).occupancy(s)
          clusters.session(s).ROI(i).dist = zeros(h.data.nSes,width);
          clusters.session(s).ROI(i).corr = zeros(h.data.nSes,width);
          clusters.session(s).ROI(i).prob = zeros(h.data.nSes,width);
        end
      end
      
      %% writing and calculating stats
      prob = [];
      for s = 1:h.data.nSes
        for i = 1:h.data.clusters(c).occupancy(s)
          n = h.data.clusters(c).session(s).list(i);
          
          for sm = 1:h.data.nSes
            for j = 1:h.data.clusters(c).occupancy(sm)
              m = h.data.clusters(c).session(sm).list(j);
              
              if all([s n] == [sm m])
                continue
              end
              clusters.session(s).ROI(i).dist(sm,j) = xdata(s,sm).dist(n,m);
              clusters.session(s).ROI(i).corr(sm,j) = xdata(s,sm).corr(n,m);
              clusters.session(s).ROI(i).prob(sm,j) = xdata(s,sm).prob(n,m);
            end
          end
          clusters.session(s).ROI(i).mean_dist = sum(clusters.session(s).ROI(i).dist(:))/(sum(h.data.clusters(c).occupancy) - 1);
          clusters.session(s).ROI(i).mean_corr = sum(clusters.session(s).ROI(i).corr(:))/(sum(h.data.clusters(c).occupancy) - 1);
          clusters.session(s).ROI(i).mean_prob = sum(clusters.session(s).ROI(i).prob(:))/(sum(h.data.clusters(c).occupancy) - 1);
          prob = [prob clusters.session(s).ROI(i).mean_prob];
        end
      end
      
      cluster_score = mean(prob)^(1+var(prob));
      h.data.cluster_score(c) = cluster_score;
      clusters.score = cluster_score;
      
      h.plots.clusters(c).color = [1-clusters.score,clusters.score,0];
      
    else
      h.data.cluster_score(c) = NaN;
      clusters.score = NaN;
      
      h.plots.clusters(c).color = [NaN, NaN, NaN];
    end
    h.status.clusters(c).calc_stats = true;
  end
  
  
function DUF_process_info(h)
  
  str_active = sprintf('Clusters displayed: %d / %d',nnz(h.status.active),nnz(~h.status.deleted));
  set(h.text_now_active,'String',str_active)
  str_completed = sprintf('Clusters completed: %d / %d',nnz(h.status.completed),nnz(~h.status.deleted));
  set(h.text_now_completed,'String',str_completed)
  
  del = 0;
  for s = 1:h.data.nSes
    del = del + nnz(h.status.session(s).deleted);
  end
  str_deleted = sprintf('ROIs deleted: %d / %d',del,sum([h.data.session.nROI]));
  set(h.text_now_deleted,'String',str_deleted)


  
  
%%% ------------------------------- end: data updating functions -------------------------------%%%
  
%%% ------------------------------ start: plot updating functions ----------------------------------%%% 



function [h, ax_handle] = plot_cluster(h,ax_handle,c)

%    what other methods are there to find bad clusters?
  
  %% resetting everything in the plot and on ROI-stats
  cla(ax_handle.ax_ROI_display)
  cla(ax_handle.ax_ROI_display_stats)
  cla(ax_handle.ax_clusterstats)
  
  %% resetting textbox
  [h ax_handle] = display_ROI_info(h,ax_handle,[],1,[]);
  [h ax_handle] = display_ROI_info(h,ax_handle,[],2,[]);
  
  ax_handle.session = [];
  
  if ~isempty(c)
    dist_thr = str2double(get(h.entry_ROI_adjacency,'String'));
    margin = dist_thr + 10;
    
    %% getting data
    footprints = getappdata(0,'footprints');
    
    centr = round(h.data.cluster_centroids(c,:));
    x_lims = [max(1,centr(2)-margin),min(512,centr(2)+margin)];
    y_lims = [max(1,centr(1)-margin),min(512,centr(1)+margin)];
    
    
    plot_3D = get(h.radio_clusterdisplay_3D,'Value');
    if plot_3D
      [X,Y] = meshgrid(1:diff(x_lims)+1,1:diff(y_lims)+1);
    end
    
    %% plotting cluster
    hold(ax_handle.ax_ROI_display,'on')
    
    for s = 1:h.data.nSes
      ax_handle.session(s).ROI_ID = [];
      for i = 1:h.data.clusters(c).occupancy(s)
        n = h.data.clusters(c).session(s).list(i);
        
        if plot_3D
          %%% here comes 3D plotting
          A_tmp = full(footprints.session(s).ROI(n).A(y_lims(1):y_lims(2),x_lims(1):x_lims(2)));
          A_tmp(A_tmp==0) = NaN;
          
          ax_handle.session(s).ROI(i) = surf(ax_handle.ax_ROI_display,X,Y,-2*A_tmp+s);
        else
          %%% here comes 2D plotting
          col = ones(3,1)*4*s/(5.*h.data.nSes);
          ax_handle.session(s).ROI(i) = cluster_plot_blobs(ax_handle.ax_ROI_display,full(footprints.session(s).ROI(n).A),[],h.parameter.ROI_thr,'-',col,1);
        end
        idx = length(ax_handle.session(s).ROI_ID)+1;
        ax_handle.session(s).ROI_ID(idx) = n;
        set(ax_handle.session(s).ROI(i),'ButtonDownFcn',{@click_ROI,[c s n],1},'HitTest','on');
        create_ROI_menu(h,ax_handle.session(s).ROI(idx),[c s n])
      end  
    end
    
    
    %% plotting adjacent, non-cluster ROIs
    for s = 1:h.data.nSes
    
      dist = sqrt(sum((h.data.cluster_centroids(c,1)-footprints.session(s).centroids(:,1)).^2 + (h.data.cluster_centroids(c,2)-footprints.session(s).centroids(:,2)).^2,2));
      
      idx_plot = find(dist < dist_thr);
      idx = h.data.clusters(c).occupancy(s);
      
      for n = idx_plot'
        if ~ismember(n,h.data.clusters(c).session(s).list)
          idx = idx + 1;
          
          if plot_3D
            A_tmp = full(footprints.session(s).ROI(n).A(y_lims(1):y_lims(2),x_lims(1):x_lims(2)));
            A_tmp(A_tmp==0) = NaN;
            
            ax_handle.session(s).ROI(idx) = surf(ax_handle.ax_ROI_display,X,Y,-2*A_tmp+s,'FaceAlpha',0.4,'EdgeAlpha',0.4);
          else
            ax_handle.session(s).ROI(idx) = cluster_plot_blobs(ax_handle.ax_ROI_display,full(footprints.session(s).ROI(n).A),[],h.parameter.ROI_thr,'--','r',0.75);
          end
          set(ax_handle.session(s).ROI(idx),'ButtonDownFcn',{@click_ROI,[c s n],1},'HitTest','on');
          create_ROI_menu(h,ax_handle.session(s).ROI(idx),[c s n])
          ax_handle.session(s).ROI_ID(idx) = n;
        end
      end
      
      if ~idx
        ax_handle.session(s).ROI = [];
      end
    end
    
    hold(ax_handle.ax_ROI_display,'off')
    
    %% overall plot settings
    if plot_3D
      view(ax_handle.ax_ROI_display,[-165,30])
      r3d = rotate3d(ax_handle.ax_ROI_display);
      r3d.Enable = 'on';
      zlim(ax_handle.ax_ROI_display,[0,h.data.nSes+1])
      set(ax_handle.ax_ROI_display,'ZDir','reverse')
      set(r3d,'ButtonDownFilter',@myRotateFilter);    %% kinda ugly, as it maintains the rotate cursor everywhere and rotates other axes as well
      
      
      x_low = floor(x_lims(1)/10)*10;
      x_high = ceil(x_lims(2)/10)*10;
      x_steps = (x_high-x_low)/10+1;
      xtick_arr = linspace(x_low,x_high,x_steps);
      x0_arr = linspace(x_low - x_lims(1),x_high - x_lims(1),x_steps);
      
      y_low = floor(y_lims(1)/10)*10;
      y_high = ceil(y_lims(2)/10)*10;
      y_steps = (y_high-y_low)/10+1;
      ytick_arr = linspace(y_low,y_high,y_steps);
      y0_arr = linspace(y_low - y_lims(1),y_high - y_lims(1),y_steps);
      
      xticks(ax_handle.ax_ROI_display,x0_arr)
      xticklabels(ax_handle.ax_ROI_display,xtick_arr)

      yticks(ax_handle.ax_ROI_display,y0_arr)
      yticklabels(ax_handle.ax_ROI_display,ytick_arr)
      
      xlim(ax_handle.ax_ROI_display,[0 x_lims(2)-x_lims(1)])
      ylim(ax_handle.ax_ROI_display,[0 y_lims(2)-y_lims(1)])
      set(h.checkbox_rotate3d,'Value',1)
    else
      rotate3d(ax_handle.ax_ROI_display,'off')
      set(h.checkbox_rotate3d,'Value',0)
      view(ax_handle.ax_ROI_display,2)
      xlim(ax_handle.ax_ROI_display,x_lims)
      ylim(ax_handle.ax_ROI_display,y_lims)
    end
    
    
    %% adjust visibility of adjacent ROIs
    display_sessions(h,ax_handle)
    
    %% plotting occupation of each session
    dat = zeros(h.data.nSes,2);
    ax_handle.session_occ_poly = barh(ax_handle.ax_ROI_display_stats,dat);
    ax_handle.session_occ_poly(1).FaceColor = 'b';
    ax_handle.session_occ_poly(2).FaceColor = 'r';
    
    xlim(ax_handle.ax_ROI_display_stats,[0,5])
    set(ax_handle.ax_ROI_display_stats,'YDir','reverse')
    
    %% plotting stats
    h = DUF(h,c);
    clusters = getappdata(0,'clusters');
    
    ax_handle = PUF_cluster_stats(h,ax_handle,clusters(c),c);
    PUF_assignment_stats(h,ax_handle,c)
    
    set(ax_handle.slider,'enable','on')
    
  else
    set(ax_handle.slider,'enable','off')
  end


function ax_handle = PUF_cluster_stats(h,ax_handle,clusters,c)  %% updating is more pain than replotting it completely
  
  cla(ax_handle.ax_clusterstats,'reset')
  
  hold(ax_handle.ax_clusterstats,'on')
  for s = 1:h.data.nSes
    for i = 1:h.data.clusters(c).occupancy(s)
      n = h.data.clusters(c).session(s).list(i);
      if get(h.radio_clusterstats_dist,'Value')
        ax_handle.session(s).ROI_stat(i) = plot(ax_handle.ax_clusterstats,s,clusters.session(s).ROI(i).mean_dist,'ks','HitTest','off');
        ylim(ax_handle.ax_clusterstats,[0 5])
        ylabel(ax_handle.ax_clusterstats,'distance')
      elseif get(h.radio_clusterstats_corr,'Value')
        ax_handle.session(s).ROI_stat(i) = plot(ax_handle.ax_clusterstats,s,clusters.session(s).ROI(i).mean_corr,'ks','HitTest','off');
        ylim(ax_handle.ax_clusterstats,[0.5 1])
        ylabel(ax_handle.ax_clusterstats,'footprint correlation')
      elseif get(h.radio_clusterstats_prob,'Value')
        ax_handle.session(s).ROI_stat(i) = plot(ax_handle.ax_clusterstats,s,clusters.session(s).ROI(i).mean_prob,'kS','HitTest','off');
        ylim(ax_handle.ax_clusterstats,[0.5 1])
        ylabel(ax_handle.ax_clusterstats,'p_{same}')
      end
      set(ax_handle.session(s).ROI_stat(i),'ButtonDownFcn',{@click_ROI,[c s n],2},'HitTest','on');
    end
  end
  hold(ax_handle.ax_clusterstats,'off')
  xticks(ax_handle.ax_clusterstats,1:h.data.nSes)
  xticklabels(ax_handle.ax_clusterstats,1:h.data.nSes)
  xlim(ax_handle.ax_clusterstats,[0,h.data.nSes+1])
  
  
  
function PUF_assignment_stats(h,ax_handle,c)
  set(ax_handle.session_occ_poly(1),'YData',h.data.clusters(c).occupancy);
  set(ax_handle.session_occ_poly(2),'YData',h.data.clusters(c).polyROI);
  
  
  
function [h ax_handle] = display_ROI_info(h,ax_handle,hObject,ax_ID,ID)
  
  vis_bool = ~isempty(ID);
  
  if vis_bool
    c = ID(1);
    s = ID(2);
    n = ID(3);
  end
  
  if ax_ID == 1       %% ROI_ax
    vis_bool = vis_bool && ~(strcmp(ax_handle.ROI_textbox.Visible,'on') && all(ax_handle.picked.ROI == [s n]));
    textbox_handle = ax_handle.ROI_textbox;
  elseif ax_ID == 2   %% clusterstats
    vis_bool = vis_bool && ~(strcmp(ax_handle.clusterstats_textbox.Visible,'on') && all(ax_handle.picked.ROI_stat == [s n]));
    textbox_handle = ax_handle.clusterstats_textbox;
  end
  
  if ~isempty(ID) && ~any(isnan(ax_handle.picked.ROI))
    idx = find(ax_handle.session(ax_handle.picked.ROI(1)).ROI_ID==ax_handle.picked.ROI(2));
    set(ax_handle.session(ax_handle.picked.ROI(1)).ROI(idx),'EdgeColor','k')
  end
  
  if vis_bool
    vis = 'on';
    
    %% get cursor position
    pt = hgconvertunits(gcf, [get(gcf, 'CurrentPoint') 1 1], ...
                    get(gcf, 'Units'), 'Normalized', gcf);
    
    height = 0.02*(1+length(h.data.session(s).ROI(n).cluster_ID));
    pos = [pt(1)+0.005 pt(2)+0.005 0.15 height];
    
    %% preparing string
    str = sprintf('session %d, neuron %d',s,n);
    for c = h.data.session(s).ROI(n).cluster_ID
      str = sprintf('%s\n cluster ID: %d',str,c);
    end
    ECol = 'r';
    
    if ax_ID == 1
      ax_handle.picked.ROI = [s n];
    elseif ax_ID == 2
      ax_handle.picked.ROI_stat = [s n];
    end
      
  else
    vis = 'off';
    str = '';
    pos = [0 0 0 0];
    ECol = 'k';
    
    if ax_ID == 1
      ax_handle.picked.ROI = [NaN NaN];
    elseif ax_ID == 2
      ax_handle.picked.ROI_stat = [NaN NaN];
    end
  end
  set(textbox_handle,'String',str,'Position',pos,'Visible',vis)
  
  if ~isempty(hObject) && ax_ID == 1
    set(hObject,'EdgeColor',ECol)
  end
  



function PUF_match_stats(h)
  set(h.plots.histo_ct,'Data',h.data.cluster_ct(1:h.data.nCluster))
  set(h.plots.histo_score,'Data',h.data.cluster_score(1:h.data.nCluster))
  
  

function PUF_cluster_textbox(h,ax_handle,c)
  
  if ~isempty(c)
    str = sprintf('cluster %d \nscore: %5.3g',c,h.data.cluster_score(c));
    set(ax_handle.textbox,'String',str,'Visible','on')
  else
    set(ax_handle.textbox,'Visible','off')
  end
  
  
  
function PUF_ROI_face(h,ax_handle,ID)
  
  c = ID(1);
  s = ID(2);
  n = ID(3);
  
  idx = find(ax_handle.session(s).ROI_ID==n);
  handle = ax_handle.session(s).ROI(idx);
  
  if ~ismember(n,h.data.clusters(c).session(s).list)
    if get(h.radio_clusterdisplay_3D,'Value')
      handle.FaceAlpha = 0.4;
      handle.EdgeAlpha = 0.4;
    else
      handle.LineStyle = '--';
      handle.Color = 'r';
    end
  else
    if get(h.radio_clusterdisplay_3D,'Value')
      handle.FaceAlpha = 1;
      handle.EdgeAlpha = 1;
    else
      handle.LineStyle = '-';
      handle.Color = 'k';
    end
  end
  
  
  
  
%%% ------------------------------ end: plot updating functions --------------------------------%%% 

%%% -------------------------------- start: ROI menu functions ---------------------------------%%%


function create_ROI_menu(h,face_handle,ID,side)
  
  c = uicontextmenu;
  
  % Assign the uicontextmenu to the plot
  set(face_handle,'UIContextMenu',c)
  
  % Create child menu items for the uicontextmenu
  m1 = uimenu(c,'Label','Toggle belong','Callback',{@toggle_belong,ID,face_handle});
  m2 = uimenu(c,'Label','Display other IDs','Callback',{@menu_plot_other_ID,ID});
  m3 = uimenu(c,'Label','Remove other IDs','Callback',{@menu_clear_ROI_ID,ID});
  m4 = uimenu(c,'Label','Mark as unsure','Callback',{@menu_remove_ROI,ID});
  m5 = uimenu(c,'Label','Mark for merging','Callback',[]);
  m6 = uimenu(c,'Label','Mark for splitting','Callback',[]);
  m7 = uimenu(c,'Label','Remove ROI','Callback',[]);
  

function toggle_belong(hObject,eventdata,ID,face_handle)
  
  if nargin == 4
    hObject = face_handle;
  end
  h = guidata(hObject);
  
  c = ID(1);
  s = ID(2);
  n = ID(3);
  
  clusters = getappdata(0,'clusters');
  %% data update
  idx = find(h.data.clusters(c).session(s).list==n);
  if ~isempty(idx)  %% removing ROI from cluster
    clusters(c).session(s).list(idx) = [];
    h.data.clusters(c).session(s).list(idx) = [];
    
    idx = find(h.data.session(s).ROI(n).cluster_ID==c);
    h.data.session(s).ROI(n).cluster_ID(idx) = [];
  else
    idx = h.data.clusters(c).occupancy(s)+1;
    clusters(c).session(s).list(idx) = n;
    h.data.clusters(c).session(s).list(idx) = n;
    
    idx = length(h.data.session(s).ROI(n).cluster_ID) + 1;
    h.data.session(s).ROI(n).cluster_ID(idx) = c;
  end
  setappdata(0,'clusters',clusters)
  
  h = DUF(h,c,false);
  clusters = getappdata(0,'clusters');
  
  ax_handle = get_axes(h,c);
  
  %% statistics update
  PUF_ROI_face(h,ax_handle,ID)
  ax_handle = PUF_cluster_stats(h,ax_handle,clusters(c),c);
  PUF_assignment_stats(h,ax_handle,c)
  PUF_match_stats(h)
  PUF_cluster_textbox(h,ax_handle,c)
  [h ax_handle] = display_ROI_info(h,ax_handle,hObject,1,ID);
  
  if h.data.cluster_ct
    delete(h.plots.cluster_handles(c))
    h.plots.cluster_handles(c) = cluster_plot_blobs(h.ax_cluster_display,full(clusters(c).A),[],h.parameter.ROI_thr,'-','m',h.plots.clusters(c).thickness);
  else
    ax_handle.picked.cluster = [];
  end
  
  if eq(hObject.Parent,h.plots.c1.ax_ROI_display) || eq(hObject.Parent,h.plots.c1.ax_clusterstats)
    h.plots.c1 = ax_handle;
  else
    h.plots.c2 = ax_handle;
  end
  
  for c_other = setdiff(h.data.session(s).ROI(n).cluster_ID,c)
    h.status.clusters(c_other).calc_occupancy = false;
    h.status.clusters(c_other).calc_status = false;
    h = DUF(h,c_other);
    if h.plots.c1.picked.cluster == c_other
      PUF_assignment_stats(h,h.plots.c1,c_other)
      PUF_ROI_face(h,h.plots.c1,[c_other,s,n])
    elseif h.plots.c2.picked.cluster == c_other
      PUF_assignment_stats(h,h.plots.c2,c_other)
      PUF_ROI_face(h,h.plots.c2,[c_other,s,n])
    end
  end
  
  guidata(hObject,h)
  
  
%    if ismember(n,clusters.ROIs(c).list(s,:))  %% removing ROI from cluster
    
%    else
    
%    end
    
    %% graphical update
    %%% in ROI_display
    
    %%% in cluster_display
    
    %%% in clusterstats_display
    

function menu_plot_other_ID(hObject,eventdata,ID)
  
  c = ID(1);
  s = ID(2);
  n = ID(3);
  
  h = guidata(hObject);
  
  %% find axis to plot to
  if h.plots.c1.picked.cluster == c
    side = 'right';
  else
    side = 'left';
  end
  
  c_new = setdiff(h.data.session(s).ROI(n).cluster_ID,c);
  if length(c_new) > 1
    uiwait(msgbox('more than 1 candidate to be plotted - allow choosing from UI'))
  else
    h = choose_cluster(h,c_new,side);
  end
  guidata(hObject,h)
  
  

function menu_clear_ROI_ID(hObject,eventdata,ID)
  
  c = ID(1);
  s = ID(2);
  n = ID(3);
  
  h = guidata(hObject);
  
  xdata = getappdata(0,'xdata');
  h = clear_ID(h,xdata,c,s,n);
  
  h = DUF_cluster_status(h,c);
  PUF_assignment_stats(h,get_axes(h,c),c)
  
  guidata(hObject,h)


function menu_remove_ROI(hObject,eventdata,ID)
  
  s = ID(2);
  n = ID(3);
  
  h = guidata(hObject);
  h = remove_ROI(h,s,n)
  guidata(hObject,h)
  



function h = remove_ROI(h,s,n)
  
  h.status.session(s).deleted(n) = true;
  clusters = getappdata(0,'clusters');
  %% disengage from all clusters
  for c = h.data.session(s).ROI(n).cluster_ID
    clusters(c).session(s).list = setdiff(clusters(c).session(s).list,c);
    h.data.clusters(c).session(s).list = setdiff(h.data.clusters(c).session(s).list,c);
  end
  setappdata(0,'clusters',clusters)
  
  %% disable visibility (removing centroid)
  footprints = getappdata(0,'footprints');
  footprints.session(s).centroids(n,:) = [NaN NaN];
  setappdata(0,'footprints',footprints);
  
  %% update stats and plots
  
%%% ----------------------------------- clustering functions --------------------------------%%%


function pre_clustering(h)
  
  appdata = get(0,'ApplicationData');
  
  if ~isfield(appdata,'pre_clusters')
  
    xdata = getappdata(0,'xdata');
    
    registered = struct('session',struct);
    clusters = struct('ID',[]);
    
    session = struct;
    for s = 1:h.data.nSes
      registered.session(s).neuron = false(h.data.session(s).nROI,1);
      session(s).ROI = struct('cluster_ID',cell(h.data.session(s).nROI,1),'matched',cell(h.data.session(s).nROI,1));
    end
    
    nCluster = 0;
    
    tic
    for s = 1:h.data.nSes
      for sm = 1:h.data.nSes
        
        for n = 1:h.data.session(s).nROI
          if sm == s
            session(s).ROI(n).matched = false;
            continue
          end
          
          if ~registered.session(s).neuron(n)   %% add new ROI_cluster if not already belonging to one
            nCluster = nCluster + 1;
            clusters(nCluster).session = struct('list',cell(h.data.nSes,1));
            
            clusters(nCluster).ID = nCluster;
            session(s).ROI(n).cluster_ID = nCluster;
            
            clusters(nCluster).session(s).list = n;
            registered.session(s).neuron(n) = true;
          end
          
          
          ID_n = session(s).ROI(n).cluster_ID;
          
          match_candidates = find(xdata(s,sm).prob(n,:)>0.5);    %% all ROIs in sm that are candidates to be same as ROI (s,n)
          for m = match_candidates
            
            if ~registered.session(sm).neuron(m)
              
              session(sm).ROI(m).cluster_ID = ID_n;
              for c = ID_n
                idx = length(clusters(c).session(sm).list)+1;
                clusters(c).session(sm).list(idx) = m;
              end
              registered.session(sm).neuron(m) = true;
                
            elseif registered.session(sm).neuron(m)
              fill_IDs = setdiff(ID_n,session(sm).ROI(m).cluster_ID);
              for c = fill_IDs
                idx = length(session(sm).ROI(m).cluster_ID) + 1;
                session(sm).ROI(m).cluster_ID(idx) = c;
                
                idx = length(clusters(c).session(sm).list)+1;
                clusters(c).session(sm).list(idx) = m;
              end
              
              fill_IDs = setdiff(session(sm).ROI(m).cluster_ID,ID_n);
              for c = fill_IDs
                idx = length(session(s).ROI(n).cluster_ID) + 1;
                session(s).ROI(n).cluster_ID(idx) = c;
                
                idx = length(clusters(c).session(s).list)+1;
                clusters(c).session(s).list(idx) = n;
              end
            end
          end
        end
      end
    end
    toc
    setappdata(0,'pre_clusters',clusters)
    setappdata(0,'session',session)
  end
  
  tic
  session = getappdata(0,'session');
  real_matching(h,session,0.8);
  toc
  
  
  
  
  
function real_matching(h,session,p_thr)
  
%    nSes = size(pre_clusters(1).list,1);
  
  pre_clusters = getappdata(0,'pre_clusters');
  
  xdata = getappdata(0,'xdata');
  mode = 'threshold';
%      mode = 'other';
  
  %% now, go through all clusters and assign surely matching ROIs to each other (p_same>0.95)
  %%% here, implementing footprints in the matching process should help/improve the results quite a bit
  
  %% afterwards, check chance of others belonging to the same cluster or whether chance is larger of them to form an own cluster
  %% for ROIs in same session, check whether merging improves matching probability
  %% also, remove surely matched ROIs in one cluster from others (or rather, track, which ones are matched already
  
%    merge_ct = 0;
%    merge2_ct = 0;
%    merge_ct_real = 0;
  c = 1;
  c_final = 0;
%    change_ct = 0;
%    switch_ct = 0;
%    A_thr = 400;
  
  nCluster = length(pre_clusters);
  
  disp('registering')
  while c < length(pre_clusters)
  
    if mod(c,500)==0
      disp(sprintf('%d of %d done. (originally %d)',c,length(pre_clusters),nCluster))
    end
    
    %% remove already matched ROIs from pre_clusters
    pre_occupancy = zeros(h.data.nSes,1);
    for s = 1:h.data.nSes
      for n = pre_clusters(c).session(s).list
        if session(s).ROI(n).matched
          idx = find(pre_clusters(c).session(s).list==n);
          pre_clusters(c).session(s).list(idx) = [];
        end
      end
      pre_occupancy(s) = length(pre_clusters(c).session(s).list);
    end
    
    if nnz(pre_occupancy) < 2   %% only look at pre_clusterss, that actually have some matching possibilities
      pre_clusters(c) = [];
    else
      c_final = c_final + 1;
      n_ref = 0;
      s_ref = 0;
      
      %% merge status: for every neuron in the final_list, have 3 entries: previous, current and following session match status
      %% match status does not refer to matching to a certain neuron, but rather assigning to this pre_clusters!
      post_clusters(c_final) = struct('A',[],'centroid',[],'score',NaN,'ct',NaN,'session',struct('list',cell(h.data.nSes,1),'ROI',struct('score',[],'mean_score',[])));
      
      for s = 1:h.data.nSes
      
        if length(pre_clusters(c).session(s).list)
          
          %% compare to last registered neuron (closest in time)
          %% also, compare to other ones if no fit found (or to overall pre_clusters?)
          
          if n_ref == 0   %% register new ROI as reference ROI
            %%% missing here: no merging in first session possible
            n = pre_clusters(c).session(s).list(1);
            post_clusters(c_final).session(s).list = n;
            
            %% set reference to first ROI detected
            n_ref = n;
            s_ref = s;
          else
            
            if strcmp(mode,'threshold')
              [matches_s, p_same_s] = get_matches(pre_clusters(c).session(s).list,xdata,0.05,s_ref,n_ref,s);
              
              [p_best_s,idx_s] = max(p_same_s);
              if p_best_s > p_thr
                best_match_s = matches_s(idx_s);
                
                %% check for reciprocity
                [matches_s_ref, p_same_s_ref] = get_matches(pre_clusters(c).session(s_ref).list,xdata,0.05,s,best_match_s,s_ref);
                [p_best_s_ref,idx_s_ref] = max(p_same_s_ref);
                if (matches_s_ref(idx_s_ref) == n_ref) && (p_best_s_ref > p_thr)
                  post_clusters(c_final).session(s).list = best_match_s;
                end
              end
            
%                if length(post_clusters(c_final).session(s).list)
%                  %% allow more than one neuron to go here
%                  n_ref = best_match_s;   %% this should include merging possibilities
%                  s_ref = s;
%                end
            %% matching due to most probable ROI (including merging etc)
            else
              
              %% check for matches with first detected ROI
              %% also, check for matches with most recently detected ROI
              [matches_s, p_same_s] = get_matches(pre_clusters(c),xdata,0.05,s_ref,n_ref,s);
              [~,idx_s] = max(p_same_s);
              best_match_s = matches_s(idx_s);
              
              for i=1:length(matches_s)
              %%% should only first best match (matches_s_ref) be considered? or also 2nd best?
                [matches_s_ref, p_same_s_ref] = get_matches(pre_clusters(c),xdata,0.05,s,matches_s(i),s_ref);
                [~,idx_s_ref] = max(p_same_s_ref);
                
                if matches_s(i) == best_match_s && matches_s_ref(idx_s_ref) == n_ref    %% if they are each others favorites
                  %% additionally check, whether this probability is larger than ... something?!
                  if p_same_s_ref(idx_s_ref) > 0.05
                    post_clusters(c_final).match_status(s_ref,3) = true;
                    post_clusters(c_final).match_status(s,1) = true;
                    
                    if ~ismember(matches_s(i),post_clusters(c_final).list(s,:))
                      idx = nnz(post_clusters(c_final).list(s,:)) + 1;
                      post_clusters(c_final).list(s,idx) = matches_s(i);
                    end
                  end
                  
                elseif matches_s(i) == best_match_s                 %% if chosen ROI rather matches with another one
                %% do not match!! (or rather: how much different are they? look for merging possibility?)
                %%% here, should check for 2nd best match
                  if (p_same_s_ref(idx_s_ref) - p_same_s(idx_s) > 0.5)  %% really wants to match another one -> do not include in this pre_clusters (very rare)
                    change_ct = change_ct + 1;
                  else                                           %% if there might be a chance of both matching -> merge?
                    post_clusters(c_final).match_status(s_ref,2:3) = true;
                    post_clusters(c_final).match_status(s,1) = true;
                    merge_ct = merge_ct + 1;
                    if ~ismember(matches_s_ref(idx_s_ref),post_clusters(c_final).list(s_ref,:))
                      idx = nnz(post_clusters(c_final).list(s_ref,:)) + 1;
                      post_clusters(c_final).list(s_ref,idx) = matches_s_ref(idx_s_ref);
                    end
                    if ~ismember(matches_s(i),post_clusters(c_final).list(s,:))
                      idx = nnz(post_clusters(c_final).list(s,:)) + 1;
                      post_clusters(c_final).list(s,idx) = matches_s(i);
                    end
                  end
                  
                elseif matches_s_ref(idx_s_ref) == n_ref
                  if (p_same_s_ref(idx_s_ref) - p_same_s(idx_s) > 0.5)  %% if probabilities far exceed, change match
                    post_clusters(c_final).match_status(s_ref,3) = true;
%                        post_clusters(c_final).list(s,:) = 0;
                    if ~ismember(matches_s(i),post_clusters(c_final).list(s,:))
                      idx = nnz(post_clusters(c_final).list(s,:)) + 1;
                      post_clusters(c_final).list(s,idx) = matches_s(i);
                      post_clusters(c_final).match_status(s,1) = true;
                    end
                    switch_ct = switch_ct + 1;
                  else
                    
                    merge2_ct = merge2_ct + 1;
                    post_clusters(c_final).match_status(s,2) = true;
                    if ~ismember(matches_s(i),post_clusters(c_final).list(s,:))
                      idx = nnz(post_clusters(c_final).list(s,:)) + 1;
                      post_clusters(c_final).list(s,idx) = matches_s(i);
                    end
                  end
                  best_match_s = matches_s(i);
                end
                
              end
              
              if any(post_clusters(c_final).list(s,:))
                %% allow more than one neuron to go here
                n_ref_alt = best_match_s;   %% this should include merging possibilities
                s_ref_alt = s;
              end
            end
          end
        end
      end
      
%        %% obtain and calculate values for ROI score
%        score = prepare_ROI_score(post_clusters(c_final),ROI_data,xdata);
%        
%        post_clusters(c_final) = ROI_cleanup(post_clusters(c_final),score,c_final,ROI_data);
%        post_clusters(c_final).score = get_ROI_score(post_clusters(c_final),score,0);
%        
%        %%% filling gaps in ROI cluster should be done in other function for all ROIs > certain score and ct
%        %%% it should...
%        %%% 1. crop out region that encloses all ROIs from this cluster + some margin
%        %%% 2. find all closeby ROIs (also from other clusters)
%        %%%   2.1. check if there is a single ROI, that might have been sorted out but belongs to this cluster- if so, remove!
%        %%% 3. initiate CNMF with initial guess of closeby ROIs + region covered by this cluster (+ some margin)
%        %%% 4. if new ROI is found, implement this one + its Ca-trace in data
%        %%%   4.1 if no new ROI is found, remark this one as "non-active" (or just apply average ROI from neighbouring sessions and get Ca-trace from simple filter application (- background) - check, if active or not)
%        
%        
%        %% here, implement checking for ROI score and removing/merging/splitting accordingly
%        
%        %% score: high average and minimum probability, bias towards large number of neurons in one pre_clusters
%        %% check: removing one ROI from pre_clusters: does it increase or decrease the "score"?
%        %% or: possible to create subset from pre_clusters that has high average and minimum probability?
%        
%        %% only now, after removing "substandard matches" from the pre_clusters, assign "matched" status to all
%          
      %% assign matched status to all within pre_clusters
      occupancy = zeros(h.data.nSes,1);
      for s = 1:h.data.nSes
        for i = 1:length(post_clusters(c_final).session(s).list)
          n = post_clusters(c_final).session(s).list(i);
          session(s).ROI(n).matched = true;
        end
        occupancy(s) = length(post_clusters(c_final).session(s).list);
      end
      
      post_clusters(c_final).ct = nnz(occupancy);
      if post_clusters(c_final).ct < 2
        post_clusters(c_final) = [];
        c_final = c_final - 1;
      elseif ~all(pre_occupancy==occupancy) %% in the end, create new pre_clusters from remaining ROIs and append to pre_clusters struct
      
        c_idx = length(pre_clusters)+1;
        pre_clusters(c_idx).session = struct('list',cell(h.data.nSes,1),'ROI',struct('score',[],'mean_score',[]));
%          pre_clusters(c_idx).ID = c_idx;
        
        for s = 1:h.data.nSes
          pre_clusters(c_idx).session(s).list = setdiff(pre_clusters(c).session(s).list,post_clusters(c_final).session(s).list);
          if isempty(pre_clusters(c_idx).session(s).list)
            pre_clusters(c_idx).session(s).list = [];
          end
          occupancy(s) = length(pre_clusters(c_idx).session(s).list);
        end
        
        if nnz(occupancy) < 2
          pre_clusters(c_idx) = [];
        end
      end
      
      c = c+1;
    end
  end
  
%    %%% fill up cluster_neuron arrays to cover all clusters
%    for s = 1:nSes
%      if length(ROI_data(s).cluster_neuron) < c_final
%        session(s).cluster_neuron(c_final) = 0;
%      end
%  %        [s length(ROI_data(s).cluster_neuron)]
%  %        ROI_data(s).cluster_neuron = cat(1,ROI_data(s).cluster_neuron',zeros(c_final - length(ROI_data(s).cluster_neuron),1))
%      [s size(session(s).cluster_neuron)]
%    end
  
  nMatches = [post_clusters.ct];
  disp(sprintf('number of ROI_clusters: %d',c_final))
%    disp(sprintf('merging attempts: %d',merge_ct))
%    disp(sprintf('real merges to be done: %d',merge_ct_real))
%  %      disp(sprintf('number of session-matchings: %d',sesmatch))
%  %      disp(sprintf('polygamous ROIs: %d',polygamy))
%  %      disp('matching done')
%    fig_ses = figure('position',[100 100 800 400]);
%    histogram(nMatches)
%    xlabel('# sessions detected')
%    ylabel('# matched ROIs')
  
%    hist_matches = hist(nMatches);
%    text(0.6,0.9,sprintf('# stable ROIs (s>=3): %d',sum(hist_matches(3:end))),'units','normalized','FontSize',14)
  
  setappdata(0,'clusters',post_clusters)
  


function [n, p_same] = get_matches(n,xdata,p_thr,s_ref,n_ref,s)
  
  %% search for all ROIs, that are not certainly rejected due to footprint or distance
  p_same = full(xdata(s_ref,s).prob(n_ref,n));
  
  mask = p_same>p_thr;
  n = n(mask);
  p_same = p_same(mask);
  
  
  

function h = cluster2handle(h,clusters)
  
  for s = 1:h.data.nSes
    h.data.session(s).ROI = struct('cluster_ID',cell(h.data.session(s).nROI,1));
  end
  
  h.data.nCluster = length(clusters);
  for c = 1:h.data.nCluster
    h.data.clusters(c).session = struct('list',cell(h.data.nSes,1));
    
    for s = 1:h.data.nSes
      h.data.clusters(c).session(s).list = clusters(c).session(s).list;
      
      for n = h.data.clusters(c).session(s).list
        h.data.session(s).ROI(n).cluster_ID = [h.data.session(s).ROI(n).cluster_ID c];
      end
    end
  end
