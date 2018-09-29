

classdef ROI_matching < handle
  properties
    uihandles
    
    c_disp
    
    plots
    wbar
    
    clusters
    status
    data
    parameter
    path
    
    dblclick
    t
  end
  
  methods
    
    % --- Executes just before ROI_matching is made visible.
    function h = ROI_matching(reload)
      
      hfig = openfig('ROI_matching_fig.fig','reuse');
      
      h.uihandles = guihandles(hfig);
      set(h.uihandles.figure1,'CloseRequestFcn',@h.GUI_CloseRequest)
      
      if ~nargin || ~reload
        
        h.plots = struct;
        
        h.parameter = struct('ROI_thr',0,'microns_per_pixel',530.684/512,'dist_max',12,'corr_max',1,'nbins',100);
        
        h.dblclick = tic;
        
%          set(h.uihandles.entry_data_path,'String','/home/wollex/Data/Documents/Uni/2016-XXXX_PhD/Japan/Work/Data/884')
        set(h.uihandles.entry_data_path,'String','/media/wollex/AS2/Masaaki/884')
        
        h.set_paths()
        
        set(h.uihandles.button_save,'enable','off')
        
        %% construct GUI for single-cluster display
        pos_ax = {[0.03, 0.1, 0.25, 0.3],...
                  [0.3, 0.1, 0.05, 0.3],...
                  [0.03, 0.5, 0.25, 0.1]};
        pos_txt = {[0.03 0.4 0.05 0.035],...
                  [0.03 0.36 0.06 0.035]};
        h.c_disp.c(1) = build_GUI_cluster_display(h,pos_ax,pos_txt);
        
        
        pos_ax = {[0.72, 0.1, 0.25, 0.3],...
                  [0.65, 0.1, 0.05, 0.3],...
                  [0.72, 0.5, 0.25, 0.1]};
        pos_txt = {[0.92 0.4 0.05 0.035],...
                  [0.91 0.36 0.06 0.035]};
        h.c_disp.c(2) = build_GUI_cluster_display(h,pos_ax,pos_txt);
        
        
        dropdown_filter_type_string = cellstr(['Specify filter 1...';...
                                              'Session occurence  ';...
                                              'ROI score          ';...
                                              'finished process   ';...
                                              'Multi-assignment   ';...
                                              'Polygamous ROIs    ';...
                                              'Tag: "unsure"      ']);
        
        set(h.uihandles.dropdown_filter1_type,'String',dropdown_filter_type_string,'Value',1,'Callback',@h.dropdown_filter_type_Callback)
        
        
        dropdown_filter_type_string = cellstr(['Specify filter 2...';...
                                              'Session occurence  ';...
                                              'ROI score          ';...
                                              'finished process   ';...
                                              'Multi-assignment   ';...
                                              'Polygamous ROIs    ']);
        
        set(h.uihandles.dropdown_filter2_type,'String',dropdown_filter_type_string,'Value',1,'Callback',@h.dropdown_filter_type_Callback)
        
        dropdown_filter_ll_gg_string = cellstr(['<';'>']);
        set(h.uihandles.dropdown_filter1_ll_gg,'String',dropdown_filter_ll_gg_string,'Value',2,'Callback',@h.dropdown_filter_ll_gg_Callback)
        set(h.uihandles.dropdown_filter2_ll_gg,'String',dropdown_filter_ll_gg_string,'Value',2,'Callback',@h.dropdown_filter_ll_gg_Callback)
        
        for obj = h.c_disp.c
          set(obj.slider_cluster_ID,'Callback',{@h.slider_cluster_ID_Callback,obj})
          set(obj.entry_cluster_ID,'Callback',{@h.entry_cluster_ID_Callback,obj})
          set(obj.button_refresh,'Callback',{@h.button_refresh_Callback,obj})
        
          set(obj.radio_active,'Callback',{@h.radio_active_Callback})
        end
        
        set(h.uihandles.entry_filter1_value,'Callback',@h.entry_filter_value_Callback)
        set(h.uihandles.entry_filter2_value,'Callback',@h.entry_filter_value_Callback)
        
        set(h.uihandles.checkbox_filter,'Callback',@h.checkbox_filter_Callback)
        
        set(h.uihandles.entry_cluster_displayed_first,'Callback',@h.entry_cluster_displayed_Callback)
        set(h.uihandles.entry_cluster_displayed_last,'Callback',@h.entry_cluster_displayed_Callback)
        
        set(h.uihandles.button_toggle_active_processed,'Callback',@h.button_toggle_active_processed_Callback)
        
        set(h.uihandles.button_data_path,'Callback',@h.button_data_path_Callback)
        
        set(h.uihandles.entry_ROI_adjacency,'Callback',@h.entry_ROI_adjacency_Callback)
        
        set(h.uihandles.entry_display_session,'Callback',@h.entry_display_session_Callback)
        
        set(h.uihandles.checkbox_ROI_unsure,'Callback',@h.checkbox_ROI_unsure_Callback)
        set(h.uihandles.checkbox_processed,'Callback',@h.toggle_processed)
        set(h.uihandles.checkbox_unsure,'Callback',@h.checkbox_unsure_Callback)
        
        set(h.uihandles.checkbox_show_all_sessions,'Callback',@h.checkbox_show_all_sessions_Callback)
        set(h.uihandles.button_prev_session,'Callback',@h.button_prev_session_Callback)
        set(h.uihandles.button_next_session,'Callback',@h.button_next_session_Callback)
        set(h.uihandles.entry_display_session,'Callback',@h.entry_display_session_Callback)
        set(h.uihandles.checkbox_show_processed,'Callback',@h.checkbox_show_processed_Callback)
        
        set(h.uihandles.button_load,'Callback',@h.button_load_Callback)
        set(h.uihandles.button_save,'Callback',@h.button_save_Callback)
        
        set(h.uihandles.button_choose_ROIs_done,'Callback',@h.button_choose_ROIs_done_Callback)
        
        set(h.uihandles.table_ROI_manipulation,'ColumnName',{'' 'ROI ID' 'type' 'to shape of...'})
        set(h.uihandles.table_ROI_manipulation,'ColumnWidth',{[30],[100],[50],[110]})
        set(h.uihandles.table_ROI_manipulation,'Data',cell(0,4),'Visible','off')
        
        set(h.uihandles.table_ROI_manipulation,'CellSelectionCallback',@h.table_menu_CellSelectionCallback)
        set(h.uihandles.button_run_manipulation,'Callback',@h.button_run_manipulation_Callback,'enable','off')
        
        set(h.uihandles.button_remove_ROIs,'Callback',@h.button_remove_ROIs_Callback)
        set(h.uihandles.button_discard_cluster,'Callback',@h.button_discard_cluster_Callback)
        set(h.uihandles.button_multi_remove_IDs,'Callback',@h.button_multi_remove_IDs_Callback)
        
        set(h.uihandles.button_toggle_time,'Callback',@h.button_toggle_time_Callback)
        
      end
      
      % Choose default command line output for ROI_matching
%        h.output = hObject;
      
    end
    
    function GUI_CloseRequest(h,a,b)
      answer = questdlg('Do you really want to close the programme?', ...
      'Closing cluster matching', ...
      'Yes','No','No');
      switch answer
        case 'No'
%            disp('not removing')
        case 'Yes'
          if isfield(h.t,'timer')
            stop(h.t.timer)
            delete(h.t.timer)
          end
          appdata = get(0,'ApplicationData');
          fname = fieldnames(appdata);
          for i = 1:numel(fname)
            rmappdata(0,fname{i})
          end
          delete(h.uihandles.figure1)
      end
    end
    
    
    
    function update_time(h,obj,event)
      
      h.t.now = toc(h.t.start) + h.t.offset;
      
      t_sec = mod(h.t.now,60);
      t_min = mod(floor(h.t.now/60),60);
      t_h = floor(h.t.now/(60*60));
      str = sprintf('Time since start: %02d:%02d:%02d',t_h,t_min,round(t_sec));
      set(h.uihandles.text_time_passed,'String',str)
      
      clusters_done = nnz(h.status.processed) + nnz(h.status.deleted);
      sec_per_cluster = h.t.now/clusters_done;
      t_eta = (h.data.nCluster-clusters_done)*sec_per_cluster;
      
      str_time_per_cluster = sprintf('Time per cluster: %02d sec',round(sec_per_cluster));
      set(h.uihandles.text_time_per_cluster,'String',str_time_per_cluster)
      
      t_eta_sec = mod(t_eta,60);
      t_eta_min = mod(floor(t_eta/60),60);
      t_eta_h = floor(t_eta/(60*60));
      str_eta = sprintf('Time until done: %02d:%02d:%02d',t_eta_h,t_eta_min,round(t_eta_sec));
      set(h.uihandles.text_eta,'String',str_eta)
    end
    
    
    function button_toggle_time_Callback(h,hObject,eventdata)
      
      switch h.t.timer.Running
        case 'on'
          set(h.uihandles.button_toggle_time,'String','Continue')
          h.t.offset = toc(h.t.start)+h.t.offset;
          stop(h.t.timer)
        case 'off'
          set(h.uihandles.button_toggle_time,'String','Pause')
          h.t.start = tic;
          start(h.t.timer)
      end
%        
    end
    
    
    
    function set_paths(h)
      h.path.mouse = get(h.uihandles.entry_data_path,'String');
      h.path.footprints = pathcat(h.path.mouse,'footprints.mat');
      h.path.xdata = pathcat(h.path.mouse,'xdata.mat');
%        h.path.clusters = pathcat(h.path.mouse,'clusters.mat');
      h.path.results = pathcat(h.path.mouse,'matching_results.mat');
    end
    
    % --- Outputs from this function are returned to the command line.
    function varargout = ROI_matching_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
      varargout{1} = handles.output;
    end
    
    
    
    % --- Executes on button press in button_load.
    function button_load_Callback(h, hObject, eventdata)
    % hObject    handle to button_load (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      tic
      set(hObject,'enable','off')
      set(h.uihandles.entry_data_path,'enable','off')
      set(h.uihandles.checkbox_load_processed_data,'enable','off')
      
      h.t.timer = timer(); % Put the timer object inside handles so that you can stop it later
      h.t.timer.Period = 2;
      h.t.timer.ExecutionMode = 'fixedRate';
      h.t.timer.TimerFcn = @(~,event) h.update_time(); % Here is where you assign the callback function
      
      nSes = 15;
      footprints = match_loadSessions(h.path.mouse,nSes);
      setappdata(0,'footprints',footprints)
      
      if ~exist(h.path.xdata,'file')
        [xdata, histo, para] = match_analyzeData(footprints,footprints.data.nSes,12);      %% calculate distances and footprint correlation
        [model,histo] = match_buildModel(xdata,histo,para,footprints.data.nSes,h.path.mouse);
      %    [ROC] = estimate_model_accuracy(histo,model,para,pathMouse);
        
        %% and assigning probabilities to each (close) pair
        xdata = match_assign_prob(xdata,footprints.data,model,para,h.path.xdata);
      else
        load(h.path.xdata)
      end
      setappdata(0,'xdata',xdata)
      
      bool_ld = get(h.uihandles.checkbox_load_processed_data,'Value') && exist(h.path.results,'file');
      if bool_ld
        ld_data = load(h.path.results);
        clusters = ld_data.clusters_sv;
        status = ld_data.status;
      else
        real_matching(footprints.data,0.8);
        clusters = getappdata(0,'clusters');
        status = [];
      end
      
      
      %%% setup of prototype structures after number of clusters is known
      nCluster = length(clusters);
      nSes = footprints.data.nSes;
      
      for obj = h.c_disp.c
        set(obj.slider_cluster_ID,'Min',0,'Max',nCluster,'Value',0,'SliderStep',[1/nCluster, 10/nCluster])
      end
      
      %% setup of data structure
      h.data = struct('nCluster',nCluster,'nSes',nSes,'imSize',footprints.data.imSize,...
                      'session',struct('shift',cell(nSes,1),'rotation',cell(nSes,1),'nROI',cell(nSes,1),...
                                       'ROI',struct('cluster_ID',[])),...
                      'ct',zeros(nCluster,1),'score',zeros(nCluster,1),...
                      'cluster_centroids',[]);
      
      %% setup of status structure
      h.status = struct('save',struct('footprints',false,'xdata',false),...
                        'picked',struct('markROIs',[],'list',[]),'mark','',...
                        'plotted',false(nCluster,1),...
                        'processed',false(nCluster,1),'active',true(nCluster,1),'deleted',false(nCluster,1),...
                        'multiROI',false(nCluster,1),'polyROI',false(nCluster,1),...
                        'unsure',false(nCluster,1),'manipulated',false(nCluster,1),...
                        'session',struct('manipulated',cell(nSes,1),'deleted',cell(nSes,1),...
                                         'visible',cell(nSes,1),'merge_ct',cell(nSes,1),'split_ct',cell(nSes,1)));
      
      for s = 1:nSes
        h.data.session(s).shift = footprints.data.session(s).shift;
        h.data.session(s).rotation = footprints.data.session(s).rotation;
        h.data.session(s).nROI = footprints.data.session(s).nROI;
        
        for n = 1:h.data.session(s).nROI
          h.data.session(s).ROI(n).cluster_ID = [];
        end
        
        if bool_ld
          h.status.session(s).manipulated = status.session(s).manipulated;
          h.status.session(s).deleted = status.session(s).deleted;
          h.status.session(s).merge_ct = status.session(s).merge_ct;
          h.status.session(s).split_ct = status.session(s).split_ct;
        else
          h.status.session(s).manipulated = false(h.data.session(s).nROI,1);
          h.status.session(s).deleted = false(h.data.session(s).nROI,1);
          h.status.session(s).merge_ct = zeros(h.data.session(s).nROI,1);
          h.status.session(s).split_ct = zeros(h.data.session(s).nROI,1);
        end
        h.status.session(s).visible = true;
      end
      
      if bool_ld
        h.status.processed = status.processed;
        h.status.unsure = status.unsure;
        h.status.deleted = status.deleted;
        h.status.manipulated = status.manipulated;
        
        h.status.manipulate = status.manipulate;
        
        h.t.offset = status.time;
      else
        h.status.manipulate = struct('processed',{},'pre',{},'post',{},'type',{});
        
        h.t.offset = 0;
      end
      h.status.manipulate_ct = length(h.status.manipulate);
      
      %%% processing input from "clusters" structure (from clustering or loading)
      h.wbar.handle = waitbar(0,'Loading and processing clusters...');
      h.wbar.status = true;
      h.wbar.overall = nCluster;
      h.wbar.ct = 0;
      
      h.clusters = cluster_class(nCluster,1:nCluster,h,clusters,status,footprints,xdata);
      h.data.cluster_centroids = cat(1,h.clusters.centroid);
      h.data.listener = addlistener(h.clusters,'emptyCluster',@h.emptyCluster);   %% triggers, when cluster becomes empty
      
      for c = 1:nCluster
        for s = 1:nSes
          for n = h.clusters(c).session(s).list
            h.data.session(s).ROI(n).cluster_ID = cat(2,h.data.session(s).ROI(n).cluster_ID,c);
          end
        end
      end
      for c = 1:nCluster
        h.clusters(c).DUF_cluster_status(h)
        h.update_arrays(c)
      end
      
      h.wbar.ct = 0;
      h.init_plot();
      
      h.update_table()
      
      close(h.wbar.handle)
      h.wbar.status = false;
      
      h.DUF_process_info()
      
      uiwait(msgbox('loading of data processed'))
      
      set(h.uihandles.button_toggle_time,'Visible','on')
      
      h.t.start = tic;
      start(h.t.timer)
      
      toc
    end
    
    
    
    
    
    function update_arrays(h,c)
      
      h.status.polyROI(c) = any(h.clusters(c).stats.polyROI > 1);
      h.status.multiROI(c) = any(h.clusters(c).stats.occupancy>1); %% multiple ROIs assigned in any session?
      
      h.status.manipulated(c) = h.clusters(c).status.manipulated;
      h.status.deleted(c) = h.clusters(c).status.deleted;
      
      h.data.ct(c) = h.clusters(c).stats.ct;
      h.data.score(c) = h.clusters(c).stats.score;
    end
    
    
    function emptyCluster(h,src,event)
      
      c = src.ID;
      obj = h.get_axes(c);
      
      delete(h.data.listener(c))
      
      for s = 1:h.data.nSes
        for n = h.clusters(c).session(s).list
          h.toggle_cluster_list([c,s,n],false)
          if ~isempty(obj)
            h.PUF_ROI_face(obj,[c,s,n])
          end
        end
      end
      
      if h.status.plotted(c)
        delete(h.plots.cluster_handles(c))
        h.status.plotted(c) = false;
      end
      
      h.clusters(c).status.deleted = true;
      h.status.deleted(c) = true;
      
      h.status.active(c) = false;
      uiwait(msgbox(sprintf('cluster %d was deleted',c)))
      
      if ~isempty(obj)
        obj.picked.cluster = [];
      end
      
    end
    
    function entry_cluster_ID_Callback(h, hObject, eventdata, obj)
    % hObject    handle to entry_cluster_ID_1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c = max(1,str2num(get(obj.entry_cluster_ID,'String')));
      while ~h.status.active(c) || h.status.deleted(c)
        c = mod(c,h.data.nCluster)+1;
      end
      
      h.choose_cluster(obj,c);
    end
    
    
    function button_refresh_Callback(h, hObject, eventdata, obj)
    % hObject    handle to entry_cluster_ID_1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      h.plot_cluster(obj,obj.picked.cluster);
    end
    
    
    %      --- Executes on slider movement.
    function slider_cluster_ID_Callback(h, hObject, eventdata, obj)
    % hObject    handle to slider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c = max(1,round(get(hObject, 'Value')));
      
      direction = sign(c-obj.picked.cluster);
      
      %% find next active
      while c>h.data.nCluster || c < 1 || ~h.status.active(c) || h.status.deleted(c) || (get(obj.checkbox_cluster_ID_skip_processed,'Value') && h.status.processed(c))
        if direction > 0
          c = mod(c,h.data.nCluster)+1;
        else
          c = mod(c-2,h.data.nCluster)+1;
        end
      end
      
      set(hObject, 'Value', c);
      set(obj.entry_cluster_ID,'String',sprintf('%d',c))
      
      h.choose_cluster(obj,c);
    end
    
    
    function entry_display_session_Callback(h, hObject, eventdata)
    % hObject    handle to entry_display_session (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of entry_display_session as text
    %        str2double(get(hObject,'String')) returns contents of entry_display_session as a double
      
      for s = 1:h.data.nSes
        h.status.session(s).visible = false;
      end
      
      s_vis = str2num(get(h.uihandles.entry_display_session,'String'));
      if isempty(s_vis)
        s_vis = 0;
        set(h.uihandles.entry_display_session,'String',sprintf('%d',s_vis))
      elseif s_vis
        h.status.session(s_vis).visible = true;
        if s_vis == h.data.nSes
          set(h.uihandles.button_next_session,'enable','off')
        else
          set(h.uihandles.button_next_session,'enable','on')
        end
        set(h.uihandles.button_prev_session,'enable','on')
      elseif ~s_vis
        set(h.uihandles.button_prev_session,'enable','off')
      end
      
      h.display_sessions(h.c_disp.active)
    end
    
    
    
    % --- Executes on button press in button_prev_session.
    function button_prev_session_Callback(h, hObject, eventdata)
    % hObject    handle to button_prev_session (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      %% remove earlier visibility
      s_vis = str2num(get(h.uihandles.entry_display_session,'String'));
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
      set(h.uihandles.entry_display_session,'String',sprintf('%d',s_vis))
      
      h.display_sessions(h.c_disp.active)
      
      if s_vis == 0
        set(h.uihandles.button_prev_session,'enable','off')
      else
        set(h.uihandles.button_prev_session,'enable','on')
      end
      set(h.uihandles.button_next_session,'enable','on')
    end


    % --- Executes on button press in button_next_session.
    function button_next_session_Callback(h, hObject, eventdata)
    % hObject    handle to button_next_session (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      %% remove earlier visibility
      s_vis = str2num(get(h.uihandles.entry_display_session,'String'));
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
      
      set(h.uihandles.entry_display_session,'String',sprintf('%d',s_vis))
      
      h.display_sessions(h.c_disp.active)
      
      if s_vis == h.data.nSes
        set(h.uihandles.button_next_session,'enable','off')
      else
        set(h.uihandles.button_next_session,'enable','on')
      end
      set(h.uihandles.button_prev_session,'enable','on')
    end


    % --- Executes on button press in checkbox_show_all_sessions.
    function checkbox_show_all_sessions_Callback(h, hObject, eventdata)
    % hObject    handle to checkbox_show_all_sessions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkbox_show_all_sessions
      
      if get(hObject,'Value')
        for s = 1:h.data.nSes
          h.status.session(s).visible = true;
        end
        set(h.uihandles.button_next_session,'enable','off')
        set(h.uihandles.button_prev_session,'enable','off')
        set(h.uihandles.entry_display_session,'enable','off')
      else
        for s = 1:h.data.nSes
          h.status.session(s).visible = false;
        end
        s_vis = str2num(get(h.uihandles.entry_display_session,'String'));
        if isempty(s_vis) || ~s_vis
          s_vis = 0;
          set(h.uihandles.entry_display_session,'String',sprintf('%d',s_vis))
        else
          h.status.session(s_vis).visible = true;
        end
        
        if s_vis < h.data.nSes
          set(h.uihandles.button_next_session,'enable','on')
        end
        
        if s_vis > 0
          set(h.uihandles.button_prev_session,'enable','on')
        end
        
        set(h.uihandles.entry_display_session,'enable','on')
      end
      
      h.display_sessions(h.c_disp.active)
    end
    
    
    
    % --- Executes on button press in checkbox_rotate3d.
    function checkbox_rotate3d_Callback(h, hObject, eventdata, rotate_on)
    % hObject    handle to checkbox_rotate3d (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      r3d = rotate3d(h.c_disp.active.ax_ROI_display);
      
      if strcmp(r3d.Enable,'off') || nargin == 4
        r3d.Enable = 'on';
        set(r3d,'ButtonDownFilter',@myRotateFilter);    %% kinda ugly, as it maintains the rotate cursor everywhere and rotates other axes as well
        hManager = uigetmodemanager(h.uihandles.figure1);
        [hManager.WindowListenerHandles.Enabled] = deal(false);
        set(h.uihandles.figure1, 'WindowKeyPressFcn', @h.KeyPress_Callback);
        set(h.uihandles.figure1, 'KeyPressFcn', []);
        set(hObject,'value',true)
      else
        r3d.Enable = 'off';
        hManager = uigetmodemanager(h.uihandles.figure1);
        [hManager.WindowListenerHandles.Enabled] = deal(false);
        set(h.uihandles.figure1, 'WindowKeyPressFcn', @h.KeyPress_Callback);
        set(h.uihandles.figure1, 'KeyPressFcn', []);
        set(hObject,'value',false)
      end
    end
      
      
    % --- Executes on button press in button_discard_cluster.
    function button_discard_cluster_Callback(h, hObject, eventdata)
    % hObject    handle to button_discard_cluster (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c = h.c_disp.active.picked.cluster;
      
      answer = questdlg('Do you really want to remove this cluster?', ...
      'Removing cluster', ...
      'Yes','No','No')
      switch answer
        case 'No'
          disp('not removing')
        case 'Yes'
          h.remove_cluster(c);
      end
      %% update faces and stats
      
    end

    % --- Executes on button press in radio_clusterdisplay_2D.
    function radio_clusterdisplay_2D_3D_Callback(h, hObject, eventdata)
    % hObject    handle to radio_clusterdisplay_2D (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c = h.c_disp.active.picked.cluster;
      if ~isempty(c)
        h.plot_cluster(h.c_disp.active,c);
      end
      
      if get(h.uihandles.radio_clusterdisplay_2D,'Value')
        set(h.uihandles.checkbox_rotate3d,'enable','on')
      else
        set(h.uihandles.checkbox_rotate3d,'enable','off')
      end
    end
      
      
    function entry_ROI_adjacency_Callback(h, hObject, eventdata)
    % hObject    handle to entry_ROI_adjacency (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c = h.c_disp.active.picked.cluster;
      if ~isempty(c)
        h.plot_cluster(h.c_disp.active,c);
      end
    end
      
      
    % --- Executes on button press in radio_clusterstats_dist.
    function radio_clusterstats_Callback(h, hObject, eventdata)
    % hObject    handle to radio_clusterstats_dist (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c = h.c_disp.active.picked.cluster;
      if ~isempty(c)
        h.PUF_cluster_stats(h.c_disp.active,c)
      end

    end
      
      
    % --- Executes on button press in checkbox_filter.
    function checkbox_filter_Callback(h, hObject, eventdata)
    % hObject    handle to checkbox_filter (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkbox_filter
      
      filter_active = get(h.uihandles.checkbox_filter,'Value');
      filter_type_val = get(h.uihandles.dropdown_filter1_type,'Value');
      filter_val = str2double(get(h.uihandles.entry_filter1_value,'String'));
      if filter_active && filter_type_val>1 && ~isnan(filter_val) || ~filter_active
        h.apply_filter();
      end
    end
      
      
    % --- Executes on selection change in dropdown_filter_type.
    function dropdown_filter_type_Callback(h, hObject, eventdata)
    % hObject    handle to dropdown_filter_type (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      filter_active = get(h.uihandles.checkbox_filter,'Value');
      filter_type_val = get(h.uihandles.dropdown_filter1_type,'Value');
      filter_val = str2double(get(h.uihandles.entry_filter1_value,'String'));
      if filter_active && filter_type_val>1 && ~isnan(filter_val)
        h.apply_filter();
      end
      
      if filter_type_val>1 && ~isnan(filter_val)
        act = 'on';
      else
        act = 'off';
        set(h.uihandles.checkbox_filter,'Value',0)
      end
      set(h.uihandles.checkbox_filter,'enable',act)
      set(h.uihandles.dropdown_filter2_type,'enable',act)
      set(h.uihandles.dropdown_filter2_ll_gg,'enable',act)
      set(h.uihandles.entry_filter2_value,'enable',act)
    end
    
    
    
    % --- Executes on selection change in dropdown_filter_ll_gg.
    function dropdown_filter_ll_gg_Callback(h, hObject, eventdata)
    % hObject    handle to dropdown_filter_ll_gg (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      filter_active = get(h.uihandles.checkbox_filter,'Value');
      filter_type_val = get(h.uihandles.dropdown_filter1_type,'Value');
      filter_val = str2double(get(h.uihandles.entry_filter1_value,'String'));
      if filter_active && filter_type_val>1 && ~isnan(filter_val)
        h.apply_filter();
      end
      
      if filter_type_val>1 && ~isnan(filter_val)
        act = 'on';
      else
        act = 'off';
        set(h.uihandles.checkbox_filter,'Value',0)
      end
      set(h.uihandles.checkbox_filter,'enable',act)
      set(h.uihandles.dropdown_filter2_type,'enable',act)
      set(h.uihandles.dropdown_filter2_ll_gg,'enable',act)
      set(h.uihandles.entry_filter2_value,'enable',act)
    end
    
    
    
    function entry_filter_value_Callback(h, hObject, eventdata)
    % hObject    handle to entry_filter_value (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

      filter_active = get(h.uihandles.checkbox_filter,'Value');
      filter_type_val = get(h.uihandles.dropdown_filter1_type,'Value');
      filter_val = str2double(get(h.uihandles.entry_filter1_value,'String'));
      if filter_active && filter_type_val>1 && ~isnan(filter_val)
        h.apply_filter();
      end
      
      if filter_type_val>1 && ~isnan(filter_val)
        act = 'on';
      else
        act = 'off';
        set(h.uihandles.checkbox_filter,'Value',0)
      end
      set(h.uihandles.checkbox_filter,'enable',act)
      set(h.uihandles.dropdown_filter2_type,'enable',act)
      set(h.uihandles.dropdown_filter2_ll_gg,'enable',act)
      set(h.uihandles.entry_filter2_value,'enable',act)
    end
    
    
    
    % --- Executes on selection change in dropdown_filter2_ll_gg.
    function dropdown_filter2_ll_gg_Callback(hObject, eventdata, h)
    % hObject    handle to dropdown_filter2_ll_gg (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

      filter_active = get(h.uihandles.checkbox_filter,'Value');
      filter_type_val = get(h.uihandles.dropdown_filter2_type,'Value');
      filter_val = str2double(get(h.uihandles.entry_filter2_value,'String'));
      if filter_active && filter_type_val>1 && ~isnan(filter_val)
        h.apply_filter();
      end
    end
    
    
    
    function entry_filter2_value_Callback(h, hObject, eventdata)
    % hObject    handle to entry_filter2_value (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      filter_active = get(h.uihandles.checkbox_filter,'Value');
      filter_type_val = get(h.uihandles.dropdown_filter2_type,'Value');
      filter_val = str2double(get(h.uihandles.entry_filter2_value,'String'));
      if filter_active && filter_type_val>1 && ~isnan(filter_val)
        h.apply_filter();
      end
    end
    
    
    
    % --- Executes on selection change in dropdown_filter2_type.
    function dropdown_filter2_type_Callback(h, hObject, eventdata)
    % hObject    handle to dropdown_filter2_type (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

      filter_active = get(h.uihandles.checkbox_filter,'Value');
      filter_type_val = get(h.dropdown_filter2_type,'Value');
      filter_val = str2double(get(h.entry_filter2_value,'String'));
      if filter_active && filter_type_val>1 && ~isnan(filter_val)
        h.apply_filter();
      end
    end

     
    
    % --- Executes on selection change in dropdown_filter2_type.
    function entry_cluster_displayed_Callback(h, hObject, eventdata)
    % hObject    handle to dropdown_filter2_type (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c_first = str2num(get(h.uihandles.entry_cluster_displayed_first,'String'));
      c_last = str2num(get(h.uihandles.entry_cluster_displayed_last,'String'));
      
      if c_first <= c_last
        c_plot = 1:h.data.nCluster;
        c_plot = c_plot >= c_first & c_plot <= c_last;
        c_not_plot = find(~c_plot);
        c_plot = find(c_plot);
        
        for obj = h.c_disp.c
          if ismember(obj.picked.cluster,c_not_plot)
            h.choose_cluster(obj,[])
          end
        end
        
        h.wbar.handle = waitbar(0,'Plotting clusters...');
        h.wbar.status = true;
        h.plot_cluster_shape(c_plot,false)
        
        for c = c_not_plot
          if h.status.plotted(c)
            delete(h.plots.cluster_handles(c))
            h.status.plotted(c) = false;
          end
        end
        close(h.wbar.handle)
        h.wbar.status = false
        
      end
      
      if get(h.uihandles.checkbox_filter,'Value');
        h.apply_filter();
      end
    end
    
    
    
    % --- Executes on button press in checkbox_processed.
    function toggle_processed(h, hObject, eventdata, c, val)
    % hObject    handle to checkbox_processed (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      if nargin < 4
        c = h.c_disp.active.picked.cluster;
      end
      
      if nargin == 5
        new_val = val;
      else
        new_val = ~h.status.processed(c);
      end
      
      if (h.clusters(c).status.merge || h.clusters(c).status.split) && new_val
        uiwait(msgbox('Cluster cannot be marked as complete, as long as there are manipulations pending!'))
      elseif h.status.polyROI(c) && new_val
        uiwait(msgbox('There are multiassignments in this cluster. Please remove those bevore marking as complete'))
      else
        h.status.processed(c) = new_val;
        h.DUF_process_info()
      end
      
      if c == h.c_disp.active.picked.cluster
        set(h.uihandles.checkbox_processed,'Value',h.status.processed(c))
      end
      if h.status.plotted(c)
        set(h.plots.cluster_handles(c),'LineStyle','-','LineWidth',h.clusters(c).plot.thickness)
        
        if h.status.processed(c)
          set(h.plots.cluster_handles(c),'LineStyle',':','LineWidth',1)
        else
          set(h.plots.cluster_handles(c),'LineStyle','-','LineWidth',h.clusters(c).plot.thickness)
        end
      end
      set(h.uihandles.button_save,'enable','on')
    end
    
    
    % --- Executes on button press in checkbox_unsure.
    function checkbox_unsure_Callback(h, hObject, eventdata)
    % hObject    handle to checkbox_unsure (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c = h.c_disp.active.picked.cluster;
      
      h.status.unsure(c) = ~h.status.unsure(c);
      set(h.uihandles.checkbox_unsure,'Value',h.status.unsure(c))
      
      h.DUF_process_info()
      set(h.uihandles.button_save,'enable','on')
    end
    
    
    
    % --- Executes on button press in checkbox_unsure.
    function checkbox_show_processed_Callback(h, hObject, eventdata)
    % hObject    handle to checkbox_unsure (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      for obj = h.c_disp.c
        h.choose_cluster(obj,obj.picked.cluster)
      end
    end
    
    
    
    
    % --- Executes on button press in checkbox_ROI_unsure.
    function checkbox_ROI_unsure_Callback(h, hObject, eventdata)
    % hObject    handle to checkbox_ROI_unsure (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      if ~any(isnan(h.c_disp.active.picked.ROI(1)))
        c = h.c_disp.active.picked.cluster;
        s = h.c_disp.active.picked.ROI(1);
        n = h.c_disp.active.picked.ROI(2);
        
        idx = find(h.clusters(c).session(s).list==n);
        h.clusters(c).session(s).ROI(idx).unsure = ~h.clusters(c).session(s).ROI(idx).unsure;
        clusters(c).session(s).ROI(idx).unsure = h.clusters(c).session(s).ROI(idx).unsure;
        set(h.uihandles.checkbox_ROI_unsure,'Value',h.clusters(c).session(s).ROI(idx).unsure)
      end
    end


    % --- Executes on button press in button_multi_remove_IDs.
    function button_multi_remove_IDs_Callback(h, hObject, eventdata)
    % hObject    handle to button_multi_remove_IDs (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c = h.c_disp.active.picked.cluster;
      
      xdata = getappdata(0,'xdata');
      
      for s = 1:h.data.nSes
        for n = h.clusters(c).session(s).list
          h.clear_ID(xdata,c,s,n);
        end
      end
      h.PUF_assignment_stats(h.c_disp.active,c)
    end


    % --- Executes on button press in button_active_clusters_finished.
    function button_toggle_active_processed_Callback(h, hObject, eventdata)
    % hObject    handle to button_active_clusters_finished (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c_disp = h.status.active & h.status.plotted;
      idx = find(c_disp);
      
      if all(~h.status.processed(c_disp))
        for c = idx'
          set(h.plots.cluster_handles(c),'LineStyle',':','LineWidth',1)
          h.status.processed(c) = true;
        end
      else
        for c = idx'
          set(h.plots.cluster_handles(c),'LineStyle','-','LineWidth',h.clusters(c).plot.thickness)
          h.status.processed(c) = false;
        end
      end
      h.DUF_process_info()
    end
      

      
    % --- Executes on button press in radio_plot_to_left.
    function radio_active_Callback(h, hObject, eventdata)
    % hObject    handle to radio_plot_to_left (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      for obj = h.c_disp.c
        set(obj.radio_active,'Value',false)
      end
      set(hObject,'Value',true)
      
      if eq(h.c_disp.c(1).radio_active,hObject)
        h.c_disp.active = h.c_disp.c(1);
      else
        h.c_disp.active = h.c_disp.c(2);
      end
      
      h.update_statusboxes()
    end
    
    
    
    % --- Executes on button press in button_remove_ROIs.
    function button_remove_ROIs_Callback(hObject, eventdata, h)
    % hObject    handle to button_remove_ROIs (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      c = h.c_disp.active.picked.cluster;
      
      for s = 1:h.data.nSes
        for n = h.clusters(c).session(s).list
          h.remove_ROI(s,n)
        end
      end
      
      h.remove_cluster(c);
    end
      
      
    % --- Executes on button press in checkbox_load_processed_data.
    function checkbox_load_processed_data_Callback(h, hObject, eventdata)
    % hObject    handle to checkbox_load_processed_data (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      disp('none')
    end

        
    function entry_data_path_Callback(hObject, eventdata, h)
    % hObject    handle to entry_data_path (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      h.set_paths()
    end
      
      
    % --- Executes on button press in button_data_path.
    function button_data_path_Callback(h, hObject, eventdata)
    % hObject    handle to button_data_path (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      pathSearch = get(h.uihandles.entry_data_path,'String');
      pathName = uigetdir(pathSearch,'Choose mouse folder');
      
      if ischar(pathName)
        set(h.uihandles.entry_data_path,'String',pathName)
        h.set_paths()
      end
    end
      
      
    % --- Executes on button press in button_save.
    function button_save_Callback(h, hObject, eventdata)
    % hObject    handle to button_save (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      set(hObject,'enable','off')
      
      h.t.now = toc(h.t.start)+h.t.offset;
      
      if h.status.save.footprints
        footprints = getappdata(0,'footprints');
        save(h.path.footprints,'footprints','-v7.3')
        h.status.save.footprints = false;
      end
      if h.status.save.xdata
        xdata = getappdata(0,'xdata');
        save(h.path.xdata,'xdata','-v7.3')
        h.status.save.xdata = false;
      end
      
      clusters_sv = struct('ID',cell(h.data.nCluster,1),'nSes',cell(h.data.nCluster,1),...
                           'session',struct('list',[],'ROI',struct('unsure',false)),...
                           'status',struct);%('merge',false,'split',false,...
%                                             'processed',false,'manipulated',false,'deleted',false,'unsure',false));
      
      for c=1:h.data.nCluster
        clusters_sv(c).ID = h.clusters(c).ID;
        clusters_sv(c).nSes = h.clusters(c).nSes;
        
        for s = 1:h.data.nSes
          clusters_sv(c).session(s).list = h.clusters(c).session(s).list;
          for i = 1:length(h.clusters(c).session(s).list)
            clusters_sv(c).session(s).ROI(i).unsure = h.clusters(c).session(s).ROI(i).unsure;
          end
        end
        clusters_sv(c).status = h.clusters(c).status;
      end
      
      status = struct;
      status.session = h.status.session;
      
      status.processed = h.status.processed;
      status.unsure = h.status.unsure;
      status.deleted = h.status.deleted;
      status.manipulated = h.status.manipulated;
      
      status.manipulate = h.status.manipulate;
      
      status.time = h.t.now;
      
      save(h.path.results,'clusters_sv','status','-v7.3')
      uiwait(msgbox(sprintf('data saved @ %s',h.path.results)))
      
    end
      
      
      
    % --- Executes on button press in button_process_marked.
    function button_process_marked_Callback(hObject, eventdata, handles)
    % hObject    handle to button_process_marked (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      disp('none')
    end
      
      
    % --- Executes on button press in button_choose_ROIs_done.
    function button_choose_ROIs_done_Callback(h, hObject, eventdata)
    % hObject    handle to button_choose_ROIs_done (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
      
      switch h.status.mark
        case 'merge_pre'
          c = h.c_disp.active.picked.cluster;
          
          idx = h.status.manipulate_ct+1;
          h.status.manipulate(idx).pre = h.status.picked.markROIs;
          
          h.status.mark = 'merge_post';
          
          session_filter = 1:h.data.nSes;
          session_filter(h.status.manipulate(idx).pre(1).ID(1)) = [];
          
          h.status.minmax_ROI = [0,1];
          
          h.enable_markROI(c,'g','Merging','as new area',session_filter);
          set(h.uihandles.button_choose_ROIs_done,'enable','on')
          
        case 'merge_post'
          
          %% check overlap & connection in pre if no post given
          idx = h.status.manipulate_ct+1;
          h.status.manipulate(idx).post = h.status.picked.markROIs;
          
          h.status.manipulate(idx).type = 'merge';
          h.status.manipulate(idx).processed = false;
          
          if h.check_manipulate(h.status.manipulate(idx))
            h.status.manipulate_ct = idx;
            
            for i = 1:length(h.status.manipulate(idx).pre)
              s = h.status.manipulate(idx).pre(i).ID(1);
              n = h.status.manipulate(idx).pre(i).ID(2);
              
              h.status.session(s).merge_ct(n) = h.status.session(s).merge_ct(n) + 1;
              for c = h.data.session(s).ROI(n).cluster_ID
                h.clusters(c).DUF_cluster_status(h)
                h.toggle_processed([],[],c,false)
              end
            end
            for i = 1:length(h.status.manipulate(idx).post)
              s = h.status.manipulate(idx).post(i).ID(1);
              n = h.status.manipulate(idx).post(i).ID(2);
              
              h.status.session(s).merge_ct(n) = h.status.session(s).merge_ct(n) + 1;
              for c = h.data.session(s).ROI(n).cluster_ID
                h.toggle_processed([],[],c,false)
              end
            end
            
            h.update_table()
            h.update_statusboxes()
            
            set(h.uihandles.button_save,'enable','on')
          else
            uiwait(msgbox('chosen candidates for merging do not overlap properly'))
          end
          h.button_cancel_menu_Callback([],[],h.c_disp.active.picked.cluster)
          
          set(h.uihandles.button_run_manipulation,'enable','on')
          
        case 'split'
          
          idx = h.status.manipulate_ct+1;
          h.status.manipulate(idx).post = h.status.picked.markROIs;
          
          h.status.manipulate(idx).type = 'split';
          h.status.manipulate(idx).processed = false;
          
          if h.check_manipulate(h.status.manipulate(idx))
            h.status.manipulate_ct = idx;
            
            for i = 1:length(h.status.manipulate(idx).pre)
              s = h.status.manipulate(idx).pre(i).ID(1);
              n = h.status.manipulate(idx).pre(i).ID(2);
              
              h.status.session(s).split_ct(n) = h.status.session(s).split_ct(n) + 1;
              for c = h.data.session(s).ROI(n).cluster_ID
                h.clusters(c).DUF_cluster_status(h)
                h.toggle_processed([],[],c,false)
              end
            end
            for i = 1:length(h.status.manipulate(idx).post)
              s = h.status.manipulate(idx).post(i).ID(1);
              n = h.status.manipulate(idx).post(i).ID(2);
              
              h.status.session(s).split_ct(n) = h.status.session(s).split_ct(n) + 1;
              for c = h.data.session(s).ROI(n).cluster_ID
                h.clusters(c).DUF_cluster_status(h)
                h.toggle_processed([],[],c,false)
              end
            end
            h.update_table()
            
            h.update_statusboxes()
            h.button_cancel_menu_Callback([],[],h.c_disp.active.picked.cluster)
            set(h.uihandles.button_save,'enable','on')
          else
            uiwait(msgbox('chosen candidates for splitting do not overlap properly'))
          end
          set(h.uihandles.button_run_manipulation,'enable','on')
          
      end
      
    end
    
    
    function good = check_manipulate(h,test)
      
      footprints = getappdata(0,'footprints');
      good = true;
      
      switch h.status.mark
        case 'merge_post'
          if isempty(test.post)
            %% check whether chosen ROIs have at least some overlap
            s = test.pre(1).ID(1);
            n = test.pre(1).ID(2);
            
            sm = test.pre(2).ID(1);
            m = test.pre(2).ID(2);
            
            if ~nnz(footprints.session(sm).ROI(m).A(find(footprints.session(s).ROI(n).A)))
              good = false;
              return
            end
            
          else
            %% check, whether all pre ROIs have 1w-corr with post > 0.8 or so
            sm = test.post.ID(1);
            m = test.post.ID(2);
            for idx = 1:length(test.pre)
              s = test.pre(idx).ID(1);
              n = test.pre(idx).ID(2);
              
              if get_1w_corr(footprints.session(s).ROI(n),footprints.session(sm).ROI(m)) < 0.6
                good = false;
                return
              end
            end
          end
          
        case 'split'
          sm = test.pre.ID(1);
          m = test.pre.ID(2);
          for idx = 1:length(test.post)
            s = test.post(idx).ID(1);
            n = test.post(idx).ID(2);
            
            if get_1w_corr(footprints.session(s).ROI(n),footprints.session(sm).ROI(m)) < 0.6
              good = false;
              return
            end
          end
      end
    end
    
    
    
    function update_table(h)
      
      table_data = cell(h.status.manipulate_ct,4);
      if ~h.status.manipulate_ct
        set(h.uihandles.table_ROI_manipulation,'Visible','off','Data',table_data)
        set(h.uihandles.button_run_manipulation,'enable','off')
      else
        
        for idx = 1:h.status.manipulate_ct
          
          table_data{idx,1} = h.status.manipulate(idx).processed;
          
          ROIs_pre = h.status.manipulate(idx).pre;
          
          str = '';
          for i = 1:length(ROIs_pre)
            str = sprintf('%s%d(%d)',str,ROIs_pre(i).ID(2),ROIs_pre(i).ID(1));
            if i < length(ROIs_pre)
              str = sprintf('%s, ',str);
            end
          end
          table_data{idx,2} = str;
          table_data{idx,3} = h.status.manipulate(idx).type;

          ROIs_post = h.status.manipulate(idx).post;

          switch h.status.manipulate(idx).type
            case 'merge'
              if isempty(h.status.manipulate(idx).post)
                table_data{idx,4} = 'compound';
              else
                table_data{idx,4} = sprintf('%d(%d)',ROIs_post(1).ID(2),ROIs_post(1).ID(1));
              end
            case 'split'
              if length(h.status.manipulate(idx).post) == 1
                table_data{idx,4} = sprintf('%d(%d)',ROIs_post(1).ID(2),ROIs_post(1).ID(1));
              else
                table_data{idx,4} = sprintf('%d(%d), %d(%d)',ROIs_post(1).ID(2),ROIs_post(1).ID(1),ROIs_post(2).ID(2),ROIs_post(2).ID(1));
              end
            case 'discard'
              table_data{idx,4} = '-';
            case 'add'
              disp('nothing in here')
          end
        end
        
        set(h.uihandles.table_ROI_manipulation,'Visible','on','Data',table_data)
        set(h.uihandles.button_run_manipulation,'enable','on')
        h.create_table_menu()
      end
    end
    
    
    function table_menu_CellSelectionCallback(h,obj,eventdata)
      
      h.status.picked.list = eventdata.Indices;
      
%        if ~isempty(h.status.picked.list)
%          table_data = get(h.uihandles.table_ROI_manipulation,'Data');
%          c = table_data{h.status.picked.list(1),2};
%          if c~=h.c_disp.active.picked.cluster
%            h.choose_cluster(h.c_disp.active,c)
%          end
%        end
    end
    
    
    function create_table_menu(h)
      
      cm = uicontextmenu(h.uihandles.figure1);
      
      % Assign the uicontextmenu to the plot
      set(h.uihandles.table_ROI_manipulation,'UIContextMenu',cm)
      
      % Create child menu items for the uicontextmenu
      m1 = uimenu(cm,'Label','Remove','Callback',@h.table_menu_remove);
      m2 = uimenu(cm,'Label','Display','Callback',@h.table_menu_display);
    end
    
    
    function table_menu_remove(h,obj,event)
      idx = h.status.picked.list(1);
      if ~isempty(idx)
        h.remove_manipulation(idx)
      end
    end
    
    function remove_manipulation(h,idx)
      
      if ~h.status.manipulate(idx).processed
        switch h.status.manipulate(idx).type
          case 'merge'
            for j = 1:length(h.status.manipulate(idx).pre)
              s = h.status.manipulate(idx).pre(j).ID(1);
              n = h.status.manipulate(idx).pre(j).ID(2);
              
              h.status.session(s).merge_ct(n) = max(0,h.status.session(s).merge_ct(n) - 1);
              for c = h.data.session(s).ROI(n).cluster_ID
                h.clusters(c).DUF_cluster_status(h)
              end
            end
            for j = 1:length(h.status.manipulate(idx).post)
              s = h.status.manipulate(idx).post(j).ID(1);
              n = h.status.manipulate(idx).post(j).ID(2);
              
              h.status.session(s).merge_ct(n) = max(0,h.status.session(s).merge_ct(n) - 1);
              for c = h.data.session(s).ROI(n).cluster_ID
                h.clusters(c).DUF_cluster_status(h)
              end
            end
          case 'split'
            for j = 1:length(h.status.manipulate(idx).pre)
              s = h.status.manipulate(idx).pre(j).ID(1);
              n = h.status.manipulate(idx).pre(j).ID(2);
              
              h.status.session(s).split_ct(n) = max(0,h.status.session(s).split_ct(n) - 1);
              for c = h.data.session(s).ROI(n).cluster_ID
                h.clusters(c).DUF_cluster_status(h)
              end
            end
            for j = 1:length(h.status.manipulate(idx).post)
              s = h.status.manipulate(idx).post(j).ID(1);
              n = h.status.manipulate(idx).post(j).ID(2);
              
              h.status.session(s).split_ct(n) = max(0,h.status.session(s).split_ct(n) - 1);
              for c = h.data.session(s).ROI(n).cluster_ID
                h.clusters(c).DUF_cluster_status(h)
              end
            end
          case 'discard'
            s = h.status.manipulate(idx).pre.ID(1);
            n = h.status.manipulate(idx).pre.ID(2);
            h.status.session(s).deleted(n) = false;
        end
        h.update_statusboxes()
        h.status.manipulate(idx) = [];
        h.status.manipulate_ct = length(h.status.manipulate);
        h.update_table()
      end
    end
    
    function table_menu_display(h,obj,event)
      %% if already processed, it should carry some information about which ROI was assigned anew, to switch to this one (because all pre ROIs were deleted, and post maybe changed)
      idx = h.status.picked.list(1);
      s = h.status.manipulate(idx).pre(1).ID(1);
      n = h.status.manipulate(idx).pre(1).ID(2);
      
      if ~isempty(h.data.session(s).ROI(n).cluster_ID)
        c = h.data.session(s).ROI(n).cluster_ID(1);
        h.choose_cluster(h.c_disp.active,c)
      end
    end
    
    function button_cancel_menu_Callback(h, hObject, eventdata, c)
      
      obj = h.get_axes(c);
      
      set(obj.add_ROI_textbox,'Visible','off','String','')
      set(h.uihandles.button_choose_ROIs_done,'Visible','off','enable','off')
      set(h.uihandles.button_cancel_menu,'Visible','off','enable','off')
      h.disable_markROI([],[],c)
      h.status.mark = '';
      
    end

      
    %%% -------------------------------------- other functions -------------------------------------%%%
      
      
    function apply_filter(h)
      
      filter_active = get(h.uihandles.checkbox_filter,'Value');
      
      filter_type_val = get(h.uihandles.dropdown_filter1_type,'Value');
      filter_type_str = get(h.uihandles.dropdown_filter1_type,'String');
      filter_type = filter_type_str{filter_type_val};
      
      filter_ll_gg_val = get(h.uihandles.dropdown_filter1_ll_gg,'Value');
      filter_ll_gg_str = get(h.uihandles.dropdown_filter1_ll_gg,'String');
      filter_ll_gg = filter_ll_gg_str{filter_ll_gg_val};
      
      filter_val = str2double(get(h.uihandles.entry_filter1_value,'String'));
      
      if filter_active && filter_type_val>1 && ~isempty(filter_val) 
        
        filter2_type_val = get(h.uihandles.dropdown_filter2_type,'Value');
        filter2_type_str = get(h.uihandles.dropdown_filter2_type,'String');
        filter2_type = filter2_type_str{filter2_type_val};
        
        filter2_ll_gg_val = get(h.uihandles.dropdown_filter2_ll_gg,'Value');
        filter2_ll_gg_str = get(h.uihandles.dropdown_filter2_ll_gg,'String');
        filter2_ll_gg = filter2_ll_gg_str{filter2_ll_gg_val};
        
        filter2_val = str2double(get(h.uihandles.entry_filter2_value,'String'));
        
        switch filter_type
          case 'Session occurence'
            stats = h.data.ct;
          case 'ROI score'
            stats = h.data.score;
          case 'Multi-assignment'
            stats = h.status.multiROI;
          case 'finished process'
            stats = h.status.processed;
          case 'Polygamous ROIs'
            stats = h.status.polyROI;
          case 'Tag: "unsure"'
            stats = h.status.unsure;
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
              stats = h.data.ct;
            case 'ROI score'
              stats = h.data.score;
            case 'Multi-assignment'
              stats = h.status.multiROI;
            case 'finished process'
              stats = h.status.processed;
            case 'Polygamous ROIs'
              stats = h.status.polyROI;
            case 'Tag: "unsure"'
              stats = h.status.unsure;
          end
          
          switch filter2_ll_gg
            case '<'
              h.status.active = h.status.active & stats < filter2_val & ~h.status.deleted;
            case '>'
              h.status.active = h.status.active & stats > filter2_val & ~h.status.deleted;
          end
        end
        
        for obj = h.c_disp.c
          if ~h.status.active(obj.picked.cluster)
            h.choose_cluster(obj,[]);
          end
        end
        
      else
        h.status.active = ~h.status.deleted;
      end
      
      for c = 1:h.data.nCluster
        if ~h.status.deleted(c) && h.status.plotted(c)
          if h.status.active(c)
            set(h.plots.cluster_handles(c),'Visible','on')
          else
            set(h.plots.cluster_handles(c),'Visible','off')
          end
        end
      end
      h.DUF_process_info();
    end



    function clear_ID(h,xdata,c,s,n)
      
      for c_other = setdiff(h.data.session(s).ROI(n).cluster_ID,c)
        
        h.toggle_cluster_list([c_other,s,n],false)
        
        obj = h.get_axes(c_other);
        if ~isempty(obj)
          h.PUF_ROI_face(obj,[c_other,s,n])
          h.PUF_assignment_stats(obj,c_other)
          h.PUF_cluster_textbox(obj,c_other)
        end
        
        if h.status.plotted(c_other)
          delete(h.plots.cluster_handles(c_other))
          h.status.plotted(c_other) = false;
          if h.data.ct(c_other)
            h.plot_cluster_shape(c_other,true)
            for obj = h.c_disp.c
              if obj.picked.cluster == c_other
                set(h.plots.cluster_handles(c_other),'Color','m')
              end
            end
          end
        end
        
      end
      h.clusters(c).DUF_cluster_status(h)
      h.update_arrays(c)
    end
      
      
    function remove_cluster(h,c)
      
      disp(sprintf('Uh oh, cluster %d was stripped of all of its ROIs. Removing!',c))
      
      obj = h.get_axes(c);
      for s = 1:h.data.nSes
        for i = 1:length(obj.session(s).ROI_ID)
          n = obj.session(s).ROI_ID(i);
          if ismember(n,h.clusters(c).session(s).list)
            h.toggle_cluster_list([c s n],false);
            h.PUF_ROI_face(obj,[c s n]);
          end
        end
      end
      h.PUF_cluster(obj,c);
    end
      
      
    
    function obj = get_axes(h,c)
      
      if h.c_disp.c(1).picked.cluster == c
        obj = h.c_disp.c(1);
      elseif h.c_disp.c(2).picked.cluster == c
        obj = h.c_disp.c(2);
      else
        obj = [];
      end
      
    end
      

    function find_unsures(h)
      
      xdata = getappdata(0,'xdata');
      
      for c = 1:h.data.nCluster
        breakit = false;
        
        if ~h.status.deleted(c)
          
          for s = 1:h.data.nSes
            
            if breakit
              break
            end
            
            for n = h.clusters(c).session(s).list
              
              if breakit
                break
              end
              
              for sm = 1:h.data.nSes
                if sm==s
                  continue
                end
                m_candidate = find(xdata(s,sm).prob(n,:)>0.8);
                
                if ~(isempty(m_candidate) && isempty(h.clusters(c).session(sm).list)) && ~all(ismember(m_candidate,h.clusters(c).session(sm).list))
                  
                  h.status.unsure(c) = true;
                  breakit = true;
                  break
                end
              end
            end
          end
        end
      end
    end


    %%% ---------------------------------- end: other functions ------------------------------------%%%


    %%% ------------------------------ start: data updating functions (DUF) ------------------------------%%%


    function init_data(h)

%        h.data.nCluster = 200; %% only for testing to restrict number of loaded clusters
      
      
      
%        h.plots.cluster = struct('thickness',cell(h.data.nCluster,1),'color',cell(h.data.nCluster,1));
      
%        h.data.ct = zeros(h.data.nCluster,1);
%        h.data.score = zeros(h.data.nCluster,1);
      
%        h.status.active = true(h.data.nCluster,1);
%        h.status.cluster_multiROI = false(h.data.nCluster,1);
%        h.status.cluster_polyROI = false(h.data.nCluster,1);
      
      %% first run of updating data for all
%        
%        disp(sprintf('number of ROI_clusters: %d',h.data.nCluster))
%        disp(sprintf('number of real ROI_clusters: %d',sum(h.data.ct > 1)))
      
%        clusters = getappdata(0,'clusters');
%        h.data.cluster_centroids = cat(1,clusters.centroid);
      
    end

      
      
    %%% ------------------------------- end: data updating functions -------------------------------%%%
      
    %%% ------------------------------ start: plot updating functions ----------------------------------%%% 

      
    function init_plot(h)
      %%% initial plotting of all clusters
      load('/home/wollex/Data/Documents/Uni/2016-XXXX_PhD/Japan/Work/Data/884/Session01/reduced_MF1_LK1.mat','max_im')
      imagesc(h.uihandles.ax_cluster_overview,max_im,'Hittest','off')
      colormap(h.uihandles.ax_cluster_overview,'gray')
      
      h.status.plotted = false(h.data.nCluster,1);
      
      c_plot = 1:h.data.nCluster;
      c_plot = find(c_plot >= str2num(get(h.uihandles.entry_cluster_displayed_first,'String')) & c_plot <= str2num(get(h.uihandles.entry_cluster_displayed_last,'String')));
      
      h.wbar.ct = 0;
      h.wbar.overall = length(c_plot);
      
      h.plot_cluster_shape(c_plot,false)
      
      
      xlim(h.uihandles.ax_cluster_overview,[1,h.data.imSize(2)])
      ylim(h.uihandles.ax_cluster_overview,[1,h.data.imSize(1)])
      
      set(h.uihandles.ax_cluster_overview,'ButtonDownFcn',@h.ButtonDown_pickCluster,'Hittest','on','PickableParts','All');
      
      %% plot overall stats
      h.plots.histo_ct = histogram(h.uihandles.ax_matchstats1,h.data.ct(~h.status.deleted));
      xlim(h.uihandles.ax_matchstats1,[0,16])
      xlabel(h.uihandles.ax_matchstats1,'# Sessions')
      ylabel(h.uihandles.ax_matchstats1,'# clusters')
      
      h.plots.histo_score = histogram(h.uihandles.ax_matchstats2,h.data.score(~h.status.deleted),linspace(0,1,21));
      xlim(h.uihandles.ax_matchstats2,[0,1])
      xlabel(h.uihandles.ax_matchstats2,'score')
      ylabel(h.uihandles.ax_matchstats2,'# clusters')
      
      %% set active display
      h.c_disp.active = h.c_disp.c(1);
      
      %% some GUI updates
      set(h.c_disp.c(1).radio_active,'Value',true)
      
      for obj = h.c_disp.c
        set(obj.entry_cluster_ID,'enable','on')
      end
      
      set(h.uihandles.dropdown_filter1_type,'enable','on')
      set(h.uihandles.dropdown_filter1_ll_gg,'enable','on')
      set(h.uihandles.entry_filter1_value,'enable','on')
    end
    
    
    
    function plot_cluster_shape(h,c_arr,replot)
      
      if nargin < 3
        replot = true;
      end
      
      nPlot = length(c_arr);
      for i = 1:nPlot
        c = c_arr(i);
        
        if h.wbar.status
          h.wbar.ct = h.wbar.ct + 1;
          if ~mod(h.wbar.ct,100)  % change to something else... (counter counting up)
            msg = sprintf('Plotted %d/%d clusters',h.wbar.ct,h.wbar.overall);
            waitbar(h.wbar.ct/(2*h.wbar.overall),h.wbar.handle,msg)
          end
        end
        
        if ~h.clusters(c).status.deleted && (~h.status.plotted(c) || replot)
          if h.status.processed(c)
            cluster_line = ':';
            cluster_thickness = 1;
          else
            cluster_line = '-';
            cluster_thickness = h.clusters(c).plot.thickness;
          end
          h.plots.cluster_handles(c) = cluster_plot_blobs(h.uihandles.ax_cluster_overview,full(h.clusters(c).A),[],h.parameter.ROI_thr,cluster_line,h.clusters(c).plot.color,cluster_thickness);
          h.status.plotted(c) = true;
        end
      end
    end
    
    
    
    function plot_cluster(h,obj,c)
      
      %% resetting everything in the plot and on ROI-stats
      cla(obj.ax_ROI_display)
      cla(obj.ax_ROI_display_stats)
      cla(obj.ax_ROI_clusterstats)
      
      %% resetting textbox
      h.display_ROI_info(obj,[]);
      h.display_ROIstat_info(obj,[],[]);
      
      obj.session = [];
      if ~isempty(c)
        dist_thr = str2double(get(h.uihandles.entry_ROI_adjacency,'String'));
        margin = dist_thr + 10;
        
        %% getting data
        footprints = getappdata(0,'footprints');
        
        centr = round(h.clusters(c).centroid);
        x_lims = [max(1,centr(2)-margin),min(512,centr(2)+margin)];
        y_lims = [max(1,centr(1)-margin),min(512,centr(1)+margin)];
        
        
        plot_3D = get(h.uihandles.radio_clusterdisplay_3D,'Value');
        if plot_3D
          [X,Y] = meshgrid(1:diff(x_lims)+1,1:diff(y_lims)+1);
        end
        
        %% plotting cluster
        hold(obj.ax_ROI_display,'on')
        
        for s = 1:h.data.nSes
          obj.session(s).ROI_ID = [];
          for i = 1:h.clusters(c).stats.occupancy(s)
            n = h.clusters(c).session(s).list(i);
            
            if plot_3D
              %%% here comes 3D plotting
              A_tmp = full(footprints.session(s).ROI(n).A(y_lims(1):y_lims(2),x_lims(1):x_lims(2)));
              A_tmp(A_tmp==0) = NaN;
              
              obj.session(s).ROI(i) = surf(obj.ax_ROI_display,X,Y,-2*A_tmp+s);
            else
              %%% here comes 2D plotting
              col = ones(3,1)*4*s/(5.*h.data.nSes);
              obj.session(s).ROI(i) = cluster_plot_blobs(obj.ax_ROI_display,full(footprints.session(s).ROI(n).A),[],h.parameter.ROI_thr,'-',col,1);
            end
            idx = length(obj.session(s).ROI_ID)+1;
            obj.session(s).ROI_ID(idx) = n;
            set(obj.session(s).ROI(i),'ButtonDownFcn',{@h.ButtonDown_pickROI,obj,[c s n]},'HitTest','on');
            h.create_ROI_menu(obj,obj.session(s).ROI(idx),[c s n])
          end  
        end
        
        plot_processed = get(h.uihandles.checkbox_show_processed,'Value');
        
        %% plotting adjacent, non-cluster ROIs
        for s = 1:h.data.nSes
        
          dist = sqrt(sum((h.data.cluster_centroids(c,1)-footprints.session(s).centroids(:,1)).^2 + (h.data.cluster_centroids(c,2)-footprints.session(s).centroids(:,2)).^2,2));
          
          idx_plot = find(dist < dist_thr);
          idx = h.clusters(c).stats.occupancy(s);
          
          for n = idx_plot'
            c_other = h.data.session(s).ROI(n).cluster_ID;
            
            if ~ismember(n,h.clusters(c).session(s).list) && ~h.status.session(s).deleted(n) && (plot_processed || ~all(h.status.processed(c_other)) || isempty(c_other))
              idx = idx + 1;
              if plot_3D
                A_tmp = full(footprints.session(s).ROI(n).A(y_lims(1):y_lims(2),x_lims(1):x_lims(2)));
                A_tmp(A_tmp==0) = NaN;
                
                obj.session(s).ROI(idx) = surf(obj.ax_ROI_display,X,Y,-2*A_tmp+s,'FaceAlpha',0.4,'EdgeAlpha',0.4);
              else
                obj.session(s).ROI(idx) = cluster_plot_blobs(obj.ax_ROI_display,full(footprints.session(s).ROI(n).A),[],h.parameter.ROI_thr,'--','r',0.75);
              end
              set(obj.session(s).ROI(idx),'ButtonDownFcn',{@h.ButtonDown_pickROI,obj,[c s n]},'HitTest','on');
              h.create_ROI_menu(obj,obj.session(s).ROI(idx),[c s n])
              obj.session(s).ROI_ID(idx) = n;
            end
          end
          
          if ~idx
            obj.session(s).ROI = [];
          end
        end
        
        hold(obj.ax_ROI_display,'off')
        
        %% overall plot settings
        if plot_3D
%            view(obj.ax_ROI_display,[15,30])
          set(obj.ax_ROI_display,'YDir','reverse')
          set(obj.ax_ROI_display,'ZDir','reverse')
          zlim(obj.ax_ROI_display,[0,h.data.nSes+1])
          caxis(obj.ax_ROI_display,[1,h.data.nSes])
          
          h.checkbox_rotate3d_Callback(h.uihandles.checkbox_rotate3d,[],true)
          
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
          
          xticks(obj.ax_ROI_display,x0_arr)
          xticklabels(obj.ax_ROI_display,xtick_arr)
          xlabel(obj.ax_ROI_display,'x')

          yticks(obj.ax_ROI_display,y0_arr)
          yticklabels(obj.ax_ROI_display,ytick_arr)
          ylabel(obj.ax_ROI_display,'y')
          
          zlabel(obj.ax_ROI_display,'session')
          
          xlim(obj.ax_ROI_display,[0 x_lims(2)-x_lims(1)])
          ylim(obj.ax_ROI_display,[0 y_lims(2)-y_lims(1)])
        else
          rotate3d(obj.ax_ROI_display,'off')
          set(h.uihandles.checkbox_rotate3d,'Value',0)
          view(obj.ax_ROI_display,2)
          xlim(obj.ax_ROI_display,x_lims)
          ylim(obj.ax_ROI_display,y_lims)
        end
        
        
        %% adjust visibility of adjacent ROIs
        h.display_sessions(obj)
        
        %% plotting occupation of each session
        dat = zeros(h.data.nSes,2);
        obj.session_occ_poly = barh(obj.ax_ROI_display_stats,dat);
        obj.session_occ_poly(1).FaceColor = 'b';
        obj.session_occ_poly(2).FaceColor = 'r';
        
        xlim(obj.ax_ROI_display_stats,[0,5])
        set(obj.ax_ROI_display_stats,'YDir','reverse')
        
        %% plotting stats
        h.clusters(c).DUF(h)
        
        h.PUF_cluster(obj,c);
        h.PUF_cluster_textbox(obj,c)
        
        set(obj.slider_cluster_ID,'enable','on')
      else
        set(obj.slider_cluster_ID,'enable','off')
      end
    end
    
    
    
    function PUF_ROI_face(h,obj,ID)
      
      c = ID(1);
      s = ID(2);
      n = ID(3);
      
      idx = find(obj.session(s).ROI_ID==n);
      handle = obj.session(s).ROI(idx);
      
      if ~ismember(n,h.clusters(c).session(s).list)
        if get(h.uihandles.radio_clusterdisplay_3D,'Value')
          handle.FaceAlpha = 0.4;
          handle.EdgeAlpha = 0.4;
        else
          handle.LineStyle = '--';
          handle.Color = 'r';
        end
      else
        if get(h.uihandles.radio_clusterdisplay_3D,'Value')
          handle.FaceAlpha = 1;
          handle.EdgeAlpha = 1;
        else
          handle.LineStyle = '-';
          handle.Color = 'k';
        end
      end
    end
      
      
    function PUF_cluster(h,obj,c)
      
      h.PUF_cluster_stats(obj,c);
      
      h.PUF_cluster_textbox(obj,c)
      h.PUF_assignment_stats(obj,c)
    end
      
      
    function PUF_cluster_stats(h,obj,c)  %% updating is more pain than replotting it completely
      
      cla(obj.ax_ROI_clusterstats,'reset')
      
      if h.clusters(c).stats.ct>1
        hold(obj.ax_ROI_clusterstats,'on')
        for s = 1:h.data.nSes
          
          for i = 1:h.clusters(c).stats.occupancy(s)
            n = h.clusters(c).session(s).list(i);
            if get(h.uihandles.radio_clusterstats_dist,'Value')
              obj.session(s).ROI_stat(i) = plot(obj.ax_ROI_clusterstats,s,h.clusters(c).session(s).ROI(i).mean_dist,'ks','HitTest','off');
              ylim(obj.ax_ROI_clusterstats,[0 5])
              ylabel(obj.ax_ROI_clusterstats,'distance')
            elseif get(h.uihandles.radio_clusterstats_corr,'Value')
              obj.session(s).ROI_stat(i) = plot(obj.ax_ROI_clusterstats,s,h.clusters(c).session(s).ROI(i).mean_corr,'ks','HitTest','off');
              ylim(obj.ax_ROI_clusterstats,[0.5 1])
              ylabel(obj.ax_ROI_clusterstats,'footprint correlation')
            elseif get(h.uihandles.radio_clusterstats_prob,'Value')
              obj.session(s).ROI_stat(i) = plot(obj.ax_ROI_clusterstats,s,h.clusters(c).session(s).ROI(i).mean_prob,'kS','HitTest','off');
              ylim(obj.ax_ROI_clusterstats,[0.5 1])
              ylabel(obj.ax_ROI_clusterstats,'p_{same}')
            end
            set(obj.session(s).ROI_stat(i),'ButtonDownFcn',{@h.ButtonDown_pickROIstat,[c s n]},'HitTest','on');
          end
        end
        hold(obj.ax_ROI_clusterstats,'off')
      end
      xticks(obj.ax_ROI_clusterstats,1:h.data.nSes)
      xticklabels(obj.ax_ROI_clusterstats,1:h.data.nSes)
      xlim(obj.ax_ROI_clusterstats,[0,h.data.nSes+1])
    end
    
    
    
    function PUF_cluster_textbox(h,obj,c)
      
      if ~isempty(c)
        str = sprintf('cluster %d \nscore: %5.3g',c,h.clusters(c).stats.score);
        set(obj.textbox,'String',str,'Visible','on')
      else
        set(obj.textbox,'Visible','off')
      end
    end
      
      
    function PUF_assignment_stats(h,obj,c)
      
      set(obj.session_occ_poly(1),'YData',h.clusters(c).stats.occupancy);
      set(obj.session_occ_poly(2),'YData',h.clusters(c).stats.polyROI);
      
    end
    
    
    
    function display_ROI_info(h,obj,ID)
      
      if ~isempty(ID)
        c = ID(1);
        s = ID(2);
        n = ID(3);
        
        vis = 'on';
        
        %% get cursor position
        pt = hgconvertunits(gcf, [get(gcf, 'CurrentPoint') 1 1], ...
                        get(gcf, 'Units'), 'Normalized', gcf);
        
        height = 0.02*(1+length(h.data.session(s).ROI(n).cluster_ID));
        pos = [pt(1)+0.01 pt(2)+0.01 0.1 height];
        
        %% preparing string
        str = sprintf('session %d, neuron %d',s,n);
        for c = h.data.session(s).ROI(n).cluster_ID
          str = sprintf('%s\n cluster ID: %d',str,c);
        end
      else
        vis = 'off';
        pos = [0 0 0 0];
        str = '';
      end
      
      set(obj.ROI_textbox,'String',str,'Position',pos,'Visible',vis)
    end
    
    
    
    
    function display_ROIstat_info(h,obj,hObject,ID)
      
      vis_bool = ~isempty(ID);
      
      if vis_bool
        c = ID(1);
        s = ID(2);
        n = ID(3);
      end
      
      vis_bool = vis_bool && ~(strcmp(obj.clusterstats_textbox.Visible,'on') && all(obj.picked.ROI_stat == [s n]));
      textbox_handle = obj.clusterstats_textbox;
      
      if ~isempty(ID) && ~any(isnan(obj.picked.ROI))
        idx = find(obj.session(obj.picked.ROI(1)).ROI_ID==obj.picked.ROI(2));
        set(obj.session(obj.picked.ROI(1)).ROI(idx),'EdgeColor','k')
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
        
        obj.picked.ROI_stat = [s n];
          
      else
        vis = 'off';
        str = '';
        pos = [0 0 0 0];
        ECol = 'k';
        
        obj.picked.ROI_stat = [NaN NaN];
      end
      set(textbox_handle,'String',str,'Position',pos,'Visible',vis)
    end
    
    
    
    function display_sessions(h,obj)
      
      c = obj.picked.cluster;
      
      for s = 1:h.data.nSes
        if length(obj.session(s).ROI_ID)
          if h.status.session(s).visible
            vis = 'on';
          else
            vis = 'off';
          end
          for i = 1:length(obj.session(s).ROI_ID)
            n = obj.session(s).ROI_ID(i);
            if ~ismember(n,h.clusters(c).session(s).list)
              set(obj.session(s).ROI(i),'Visible',vis)
            end
          end
        end
      end
    end
    
%%% -------------------------------- end: plot updating functions --------------------------------%%% 

%%% --------------------------------start: GUI interaction functions -----------------------------%%%
      
    function ButtonDown_pickROI(h, hObject, eventdata, obj, ID)
      
    % ID contains: (c,s,n)
      c = ID(1);
      s = ID(2);
      n = ID(3);
      
      obj = h.get_axes(c);
      t = toc(h.dblclick);
      
      f = hObject.Parent.Parent;
      if ~strcmp(f.SelectionType, 'alt')
        
        if t < 0.3 && (~isempty(obj) || all(isnan(obj.picked.ROI)) || all([s n] == obj.picked.ROI))  %% doubleclick (not on clusterstats)
          h.toggle_belong(hObject, eventdata, obj, ID);
          h.dblclick = tic-2; %% disable double click trigger for next click
        else
          h.toggle_picked_ROI(obj, hObject, ID);
          h.dblclick = tic;
        end
        
      end
    end
      
      
    function ButtonDown_pickROIstat(h, hObject, eventdata, obj, ID)
      
    % ID contains: (c,s,n)
      c = ID(1);
      s = ID(2);
      n = ID(3);
      
      t = toc(h.dblclick);
      
      f = hObject.Parent.Parent;
      if ~strcmp(f.SelectionType, 'alt')
        
        h.display_ROIstat_info(h.c_disp.active,hObject,ID);
        h.dblclick = tic;
      end
    end
      
      
    function ButtonDown_markROIs(h,hObject,eventdata,ID,col)
      
      c = ID(1);
      s = ID(2);
      n = ID(3);
      
      obj = h.get_axes(c);
      
      if ~isempty(h.status.picked.markROIs)
        
        for idx_list = 1:length(h.status.picked.markROIs)
          idx_bool = ismember([s n],h.status.picked.markROIs(idx_list).ID,'rows');
          if idx_bool
            break
          end
        end
        
        if idx_bool     %% reset earlier picked ROI
          h.status.picked.markROIs(idx_list) = [];
          
          idx = find(obj.session(s).ROI_ID==n);
          set(obj.session(s).ROI(idx),'EdgeColor','k')
        elseif length(h.status.picked.markROIs)>=h.status.minmax_ROI(2)
          %% reset appearance of deleted ROI
          sm = h.status.picked.markROIs(h.status.minmax_ROI(2)).ID(1);
          m = h.status.picked.markROIs(h.status.minmax_ROI(2)).ID(2);
          idx = find(obj.session(sm).ROI_ID==m);
          set(obj.session(sm).ROI(idx),'EdgeColor','k')
          
          h.status.picked.markROIs(h.status.minmax_ROI(2)).ID = [s n];
          set(hObject,'EdgeColor',col)
        else
          idx = length(h.status.picked.markROIs) + 1;
          h.status.picked.markROIs(idx).ID = [s n];
          set(hObject,'EdgeColor',col)
        end
      else
        h.status.picked.markROIs(1).ID = [s n];
        set(hObject,'EdgeColor',col)
      end
      
      str = '';
      for i = 1:length(h.status.picked.markROIs)
        str = sprintf('%s\nROI #%d: %d (%d) ',str,i,h.status.picked.markROIs(i).ID(2),h.status.picked.markROIs(i).ID(1));
      end
      
      set(obj.add_ROI_textbox,'String',sprintf('%s%s',h.status.markROIs_str,str))
      
      if length(h.status.picked.markROIs) >= h.status.minmax_ROI(1)
        set(h.uihandles.button_choose_ROIs_done,'enable','on')
      else
        set(h.uihandles.button_choose_ROIs_done,'enable','off')
      end
      
    end
    
    
    
    function ButtonDown_pickCluster(h,hObject,eventdata)

      coords = get(hObject,'CurrentPoint');
      
      [min_val c_idx] = min(sum((h.data.cluster_centroids(h.status.active & h.status.plotted,1)-coords(1,2)).^2 + (h.data.cluster_centroids(h.status.active & h.status.plotted,2)-coords(1,1)).^2,2));
      idxes = find(h.status.active & h.status.plotted);
      c = idxes(c_idx);
      
      if sqrt(min_val) < 10
        pt = hgconvertunits(gcf, [get(gcf, 'CurrentPoint') 1 1], ...
                        get(gcf, 'Units'), 'Normalized', gcf);
        if c == h.c_disp.active.picked.cluster
          c = [];
        end
        h.choose_cluster(h.c_disp.active,c)
      end
    end



    function KeyPress_Callback(h, hObject, eventdata)
      
      c = h.c_disp.active.picked.cluster;
      switch eventdata.Key
        case 'u'
          if ~any(isnan(h.c_disp.active.picked.ROI))
            h.checkbox_ROI_unsure_Callback(h.uihandles.checkbox_ROI_unsure,[])
          else
            h.checkbox_unsure_Callback(h.uihandles.checkbox_unsure,[])
          end
        case 'c'
          h.toggle_processed([],[],c)
        case 'r'
          h.checkbox_rotate3d_Callback(h.uihandles.checkbox_rotate3d,[])
        case 'm'
          if ~any(isnan(h.c_disp.active.picked.ROI))
            s = h.c_disp.active.picked.ROI(1);
            n = h.c_disp.active.picked.ROI(2);
            ID = [c s n];
            idx = find(h.c_disp.active.session(s).ROI_ID == n);
            face_handle = h.c_disp.active.session(s).ROI(idx);
            menu_merging(h, [], [], h.c_disp.active, ID, face_handle)
          end
        case 's'
          if ~any(isnan(h.c_disp.active.picked.ROI))
            s = h.c_disp.active.picked.ROI(1);
            n = h.c_disp.active.picked.ROI(2);
            ID = [c s n];
            idx = find(h.c_disp.active.session(s).ROI_ID == n);
            face_handle = h.c_disp.active.session(s).ROI(idx);
            menu_splitting(h, [], [], h.c_disp.active, ID, face_handle)
          end
        case 't'
          if ~any(isnan(h.c_disp.active.picked.ROI))
            s = h.c_disp.active.picked.ROI(1);
            n = h.c_disp.active.picked.ROI(2);
            ID = [c s n];
            idx = find(h.c_disp.active.session(s).ROI_ID == n);
            face_handle = h.c_disp.active.session(s).ROI(idx);
            h.toggle_belong([], [], h.c_disp.active, ID, face_handle);
          end
        case 'rightarrow'
          set(h.c_disp.active.slider_cluster_ID,'Value',c+1)
          h.slider_cluster_ID_Callback(h.c_disp.active.slider_cluster_ID,[],h.c_disp.active)
        case 'leftarrow'
          set(h.c_disp.active.slider_cluster_ID,'Value',c-1)
          h.slider_cluster_ID_Callback(h.c_disp.active.slider_cluster_ID,[],h.c_disp.active)
        case 'uparrow'
          if get(h.uihandles.checkbox_show_all_sessions,'Value')
            set(h.uihandles.checkbox_show_all_sessions,'Value',false)
            h.checkbox_show_all_sessions_Callback(h.uihandles.checkbox_show_all_sessions,[])
          elseif str2num(get(h.uihandles.entry_display_session,'String'))
            h.button_prev_session_Callback([],[])
          end
        case 'downarrow'
          if get(h.uihandles.checkbox_show_all_sessions,'Value')
            set(h.uihandles.checkbox_show_all_sessions,'Value',false)
            h.checkbox_show_all_sessions_Callback(h.uihandles.checkbox_show_all_sessions,[])
          elseif str2num(get(h.uihandles.entry_display_session,'String'))<h.data.nSes
            h.button_next_session_Callback([],[])
          end
        case 'delete'
          if ~any(isnan(h.c_disp.active.picked.ROI))
            s = h.c_disp.active.picked.ROI(1);
            n = h.c_disp.active.picked.ROI(2);
            ID = [c s n];
            h.menu_remove_ROI([],[],ID)
          elseif ~isempty(h.c_disp.active.picked.cluster)
            h.remove_cluster(h.c_disp.active.picked.cluster)
          end
        case 'escape'
          if ~strcmp(h.status.mark,'')
            h.button_cancel_menu_Callback([],[],c)
          elseif ~any(isnan(h.c_disp.active.picked.ROI))
            s = h.c_disp.active.picked.ROI(1);
            n = h.c_disp.active.picked.ROI(2);
            idx = find(h.c_disp.active.session(s).ROI_ID == n);
            face_handle = h.c_disp.active.session(s).ROI(idx);
            h.toggle_picked_ROI(h.c_disp.active,hObject,c)
          end
        case 'return'
          if ~strcmp(h.status.mark,'') && strcmp(get(h.uihandles.button_choose_ROIs_done,'enable'),'on')
            h.button_choose_ROIs_done_Callback([],[])
          end
        case 'backspace'
          if ~isempty(h.c_disp.active.picked.cluster)
            h.button_multi_remove_IDs_Callback([],[])
          end
      end
    end


%%% ----------------------------------- end: GUI interaction functions ------------------------------------%%%

%%% --------------------------------- start: data updating functions (DUF) --------------------------------%%%
    
    
      
    function DUF_process_info(h)
      
      str_active = sprintf('Clusters disp / proc / tot /del: %d / %d / %d / %d',nnz(h.status.active & h.status.plotted),nnz(h.status.processed),nnz(~h.status.deleted),nnz(h.status.deleted));
      set(h.uihandles.text_now_active,'String',str_active)
      
      str_unsure = sprintf('Clusters unsure: %d / %d',nnz(h.status.unsure),nnz(~h.status.deleted));
      set(h.uihandles.text_now_processed,'String',str_unsure)
      
      del = 0;
      for s = 1:h.data.nSes
        del = del + nnz(h.status.session(s).deleted);
      end
      str_deleted = sprintf('ROIs deleted: %d / %d',del,sum([h.data.session.nROI]));
      set(h.uihandles.text_now_deleted,'String',str_deleted)
    end

%%% ------------------------------- end: data updating functions -------------------------------%%%
    
    
    function choose_cluster(h,obj,c)
      
      if isempty(c) || isnan(c) || c < 1 || c > h.data.nCluster
        c = [];
      end
      
      if ~isempty(obj.picked.cluster) && ~h.status.deleted(obj.picked.cluster)
        set(h.plots.cluster_handles(obj.picked.cluster),'Color',h.clusters(obj.picked.cluster).plot.color)
        PUF_cluster_textbox(h,obj,[])
      end
      obj.picked.cluster = c;
      
      %% reset some stuff
      obj.picked.ROI = [NaN NaN];
      set(h.uihandles.checkbox_ROI_unsure,'enable','off','Value',false)
      
      if ~strcmp(h.status.mark,'')
        h.button_cancel_menu_Callback([],[],c)
      end
      
      %% set overall plot and GUI controls
      if ~isempty(c)
        if ~h.status.plotted(c)
          h.plot_cluster_shape(c)
        end
        set(h.plots.cluster_handles(c),'Color','m')
        set(obj.slider_cluster_ID,'Value',c)
      else
        set(obj.slider_cluster_ID,'Value',0)
      end
      
      h.update_statusboxes()
      
      h.plot_cluster(obj,c);
      set(obj.entry_cluster_ID,'String',sprintf('%d',c))
      
    end
    
    
%%% -------------------------------- start: ROI menu functions ---------------------------------%%%

    function create_ROI_menu(h,obj,face_handle,ID,side)
      
      cm = uicontextmenu(h.uihandles.figure1);
      
      % Assign the uicontextmenu to the plot
      set(face_handle,'UIContextMenu',cm)
      
      % Create child menu items for the uicontextmenu
      m1 = uimenu(cm,'Label','Toggle belong','Callback',{@h.toggle_belong,obj,ID,face_handle});
      m2 = uimenu(cm,'Label','Display other IDs');
      m3 = uimenu(cm,'Label','Remove other IDs','Callback',{@h.menu_clear_ROI_ID,obj,ID});
      m4 = uimenu(cm,'Label','Mark as unsure','Callback',[]);
      m5 = uimenu(cm,'Label','Mark for merging','Callback',{@h.menu_merging,obj,ID,face_handle});
      m6 = uimenu(cm,'Label','Mark for splitting','Callback',{@h.menu_splitting,obj,ID,face_handle});
      m7 = uimenu(cm,'Label','Remove ROI','Callback',{@h.menu_remove_ROI,ID});
      m8 = uimenu(cm,'Label','Show Calcium trace','Callback',{@h.menu_show_CaTrace,ID});
      m9 = uimenu(cm,'Label','Create new cluster','Callback',{@h.menu_create_cluster,ID});
      
      c = ID(1);
      s = ID(2);
      n = ID(3);
      cluster_IDs = setdiff(h.data.session(s).ROI(n).cluster_ID,obj.picked.cluster);
      
      if length(cluster_IDs)
        %% find axis to plot to
        if h.c_disp.c(1).picked.cluster == c
          obj = h.c_disp.c(2);
        else
          obj = h.c_disp.c(1);
        end
        
        for i = 1:length(cluster_IDs)
          c = cluster_IDs(i);
          m2_sub(i) = uimenu('Parent',m2,'Label',sprintf('%d',c),'Callback',{@h.menu_plot_other_ID,obj,c});
        end
      else
        set(m2,'enable','off')
      end
    end


    function toggle_belong(h, hObject, eventdata, obj, ID, face_handle)
      
      if nargin == 6
        hObject = face_handle;
      end
      
      c = ID(1);
      s = ID(2);
      n = ID(3);
      
      h.toggle_picked_ROI(obj,hObject,c)  % deselect
      
      h.toggle_cluster_list(ID)
      
      %% plot updates 
      h.PUF_ROI_face(obj,ID)
      h.PUF_cluster(obj,c)
      h.PUF_match_stats()
      
      h.toggle_picked_ROI(obj,hObject,ID)
      
      if ~h.status.deleted(c)
        delete(h.plots.cluster_handles(c))
        h.plot_cluster_shape(c)
        set(h.plots.cluster_handles(c),'Color','m')
      end
      
      %% check other clusters for updates
      for c_other = setdiff(h.data.session(s).ROI(n).cluster_ID,c)
        
        h.clusters(c_other).DUF_cluster_occupancy()
        h.clusters(c_other).DUF_cluster_status(h)
        
        obj = h.get_axes(c_other);
        if ~isempty(obj)
          h.PUF_assignment_stats(obj,c_other)
          h.PUF_ROI_face(obj,[c_other,s,n])
        end
      end
      
      h.update_statusboxes()
      set(h.uihandles.button_save,'enable','on')
    end
    
    
    
    function update_statusboxes(h)
    
      c = h.c_disp.active.picked.cluster;
      if ~isempty(c)
        set(h.uihandles.checkbox_processed,'Value',h.status.processed(c),'enable','on')
        set(h.uihandles.checkbox_unsure,'Value',h.status.unsure(c),'enable','on')
        set(h.uihandles.checkbox_merge,'Value',h.clusters(c).status.merge)
        set(h.uihandles.checkbox_split,'Value',h.clusters(c).status.split)
        set(h.uihandles.checkbox_manipulated,'Value',h.status.manipulated(c))
      else
        set(h.uihandles.checkbox_processed,'Value',false,'enable','off')
        set(h.uihandles.checkbox_unsure,'Value',false,'enable','off')
        set(h.uihandles.checkbox_merge,'Value',false)
        set(h.uihandles.checkbox_split,'Value',false)
        set(h.uihandles.checkbox_manipulated,'Value',false)
      end
    end
    
    
    
    function menu_plot_other_ID(h, hObject, eventdata, obj, c)
      
      h.radio_active_Callback(obj.radio_active,[])
      h.choose_cluster(h.c_disp.active,c)
    end
      

    function menu_clear_ROI_ID(h, hObject, eventdata, obj, ID)
      
      c = ID(1);
      s = ID(2);
      n = ID(3);
      
      xdata = getappdata(0,'xdata');
      h.clear_ID(xdata,c,s,n);
      
      h.clusters(c).DUF_cluster_status(h);
      h.PUF_assignment_stats(obj,c)
      
    end
    
    
    function menu_merging(h, hObject, eventdata, obj, ID, face_handle)
      
      %% 2 ROI (red, same session) -> 1 ROI (compound)
      %% 2 ROI (red, same session) -> 1 ROI (ROI from any session)
      
      h.status.mark = 'merge_pre';
      
      c = ID(1);
      
      if length(ID)>1
        s = ID(2);
        n = ID(3);
      else
        s = obj.picked.ROI(1);
        n = obj.picked.ROI(2);
      end
      
      h.toggle_picked_ROI(obj,hObject,c);
      
      h.status.minmax_ROI = [2,2];  % min/max number of ROIs to choose
      
      h.status.picked.markROIs(1).ID = [s n];
      
      h.enable_markROI(c,'r','Merging','to merge',s);
      
      set(obj.ROI_textbox,'Visible','off')
      
      h.ButtonDown_markROIs(face_handle,[],[c s n],'r')
      set(h.uihandles.button_choose_ROIs_done,'Callback',@h.button_choose_ROIs_done_Callback,'Visible','on','enable','off')
      
    end
      
      
    function menu_splitting(h, hObject, eventdata, obj, ID, face_handle)
    
      %% 1 ROI (red) -> 2 ROI (green, anywhere)
      %% 1 ROI (red) -> 1 ROI (anywhere, means pretty much: cutting off)
%        h.status.manipulate = struct('processed',{},'pre',{},'post',{},'type',{});
%        h.status.manipulate_ct = 0;
      
      h.status.mark = 'split';
      
      c = ID(1);
      if length(ID) > 1
        s = ID(2);
        n = ID(3);
      elseif ~any(isnan(obj.picked.ROI))
        s = obj.picked.ROI(1);
        n = obj.picked.ROI(2);
      end
      
      h.toggle_picked_ROI(obj,hObject,c);
      
      h.status.minmax_ROI = [1,2];  % min/max number of ROIs to choose
      
      idx = h.status.manipulate_ct+1;
      h.status.manipulate(idx).pre = struct('ID',[s n]);
      
      set(face_handle,'EdgeColor','r')
      
      session_filter = 1:h.data.nSes;
      session_filter(s) = [];
          
      h.enable_markROI(c,'g','Splitting','as new footprints',session_filter)
      
      set(obj.ROI_textbox,'Visible','off')
      set(h.uihandles.button_choose_ROIs_done,'Callback',@h.button_choose_ROIs_done_Callback,'Visible','on','enable','off')
    end
    
    
    
    function enable_markROI(h,c,col,str_title,str_explain,session_filter)
      
      if nargin < 5
        session_filter = 1:h.data.nSes;
      end
      
      obj = h.get_axes(c);
      
      if h.status.minmax_ROI(1) == h.status.minmax_ROI(2)
        h.status.markROIs_str = sprintf('%s\nChoose %d ROIs %s: ',str_title,h.status.minmax_ROI(2),str_explain);
      else
        h.status.markROIs_str = sprintf('%s\nChoose %d to %d ROIs %s: ',str_title,h.status.minmax_ROI(1),h.status.minmax_ROI(2),str_explain);
      end
      set(obj.add_ROI_textbox,'String',h.status.markROIs_str,'Visible','on')
      set(h.uihandles.button_cancel_menu,'Visible','on','enable','on')
      
      %% enable different ButtonDownFct in all ROIs to pick 2 ROIs
      for s = 1:h.data.nSes
        for i = 1:length(obj.session(s).ROI_ID)
          n = obj.session(s).ROI_ID(i);
          if ismember(s,session_filter)
            set(obj.session(s).ROI(i),'ButtonDownFcn',{@h.ButtonDown_markROIs,[c s n],col})
          else
            set(obj.session(s).ROI(i),'ButtonDownFcn',[])
          end
        end
      end
      h.status.picked.markROIs = [];
      
      set(h.uihandles.button_cancel_menu,'Callback',{@h.disable_markROI,c})
    end
    
    
    function disable_markROI(h,hObject,event,c)
      
      obj = h.get_axes(c);
      set(obj.add_ROI_textbox,'String','','Visible','off')
      
      %% enable different ButtonDownFct in all ROIs to pick 2 ROIs
      for s = 1:h.data.nSes
        for i = 1:length(obj.session(s).ROI_ID)
          n = obj.session(s).ROI_ID(i);
          set(obj.session(s).ROI(i),'ButtonDownFcn',{@h.ButtonDown_pickROI,obj,[c s n]},'EdgeColor','k')
        end
      end
      h.status.picked.markROIs = [];
      
      set(h.uihandles.button_choose_ROIs_done,'Visible','off','enable','off')
      set(h.uihandles.button_cancel_menu,'Visible','off','enable','off')
      
    end
      
      
    function menu_remove_ROI(h, hObject, eventdata, ID)
      
      c = ID(1);
      s = ID(2);
      n = ID(3);
      
      h.remove_ROI(s,n)
      
      obj = h.get_axes(c);
      
      idx = find(obj.session(s).ROI_ID==n);
      delete(obj.session(s).ROI(idx))
      
      obj.session(s).ROI_ID(idx) = [];
      obj.session(s).ROI(idx) = [];
      
      h.PUF_cluster(obj,c)
      h.PUF_match_stats()
      
    end
      
      
    function remove_ROI(h,s,n)
      
      h.status.mark = 'discard';
      
      %% disengage from all clusters
      for c = h.data.session(s).ROI(n).cluster_ID
        h.toggle_cluster_list([c s n],false)
      end
      
      h.status.manipulate_ct = h.status.manipulate_ct + 1;
      h.status.manipulate(h.status.manipulate_ct).processed = true;
      h.status.manipulate(h.status.manipulate_ct).type = 'discard';
      h.status.manipulate(h.status.manipulate_ct).pre(1).ID = [s n];
      h.status.manipulate(h.status.manipulate_ct).post = [];
      
      %% disable visibility (removing centroid)
      h.status.session(s).deleted(n) = true;
      
      h.update_table()
      h.status.mark = '';
    end
    
    
    function menu_show_CaTrace(h,hObject,eventdata,ID)
      
      c = ID(1);
      s = ID(2);
      n = ID(3);
      
      pathSession = pathcat(h.path.mouse,sprintf('Session%02d',s));
      
      CaPath = pathcat(pathSession,'CaData.mat');
      Ca_mat = matfile(CaPath,'Writable',true);
      
      figure('position',[500 500 900 600])
      ax_C = subplot(2,1,1);
      plot(ax_C,linspace(1/15,8989/15,8989),Ca_mat.C2(n,:),'k')
      ylabel(ax_C,'Calcium signal')
      
      ax_S = subplot(2,1,2);
      plot(ax_S,linspace(1/15,8989/15,8989),Ca_mat.S2(n,:),'k')
      
      xlabel(ax_S,'time')
      ylabel(ax_S,'deconvolved signal')
      
      suptitle(sprintf('ROI #%d (%d)',n,s))
      
    end
    
    
    function menu_create_cluster(h, hObject, eventdata, ID)
      
      c = h.data.nCluster+1;
      
      cluster_prototype = struct('session',struct('list',cell(h.data.nSes,1),'ROI',struct('unsure',{})));
      for s = 1:h.data.nSes
        cluster_prototype.session(s).list = [];
      end
      
      s = ID(2);
      n = ID(3);
      
      h.data.nCluster = c;
      for obj = h.c_disp.c
        set(obj.slider_cluster_ID,'Max',h.data.nCluster)
      end
      
      cluster_prototype.session(s).list = n;
      cluster_prototype.session(s).ROI(1).unsure = false;
      
      idx = length(h.data.session(s).ROI(n).cluster_ID) + 1;
      h.data.session(s).ROI(n).cluster_ID(idx) = c;
      
      h.clusters(c) = cluster_class(1,c,h,cluster_prototype,[],[],[]);
      h.data.listener(c) = addlistener(h.clusters(c),'emptyCluster',@h.emptyCluster);
      
      h.status.plotted(c) = false;
      h.status.processed(c) = false;
      h.status.unsure(c) = false;
      h.status.active(c) = true;
      
      h.data.cluster_centroids(c,:) = h.clusters(c).centroid;
      h.update_arrays(c)
      
      if h.c_disp.c(1).picked.cluster == ID(1)
        obj = h.c_disp.c(2);
      else
        obj = h.c_disp.c(1);
      end
      h.radio_active_Callback(obj.radio_active,[])
      h.choose_cluster(obj,c)
      
      
    end
  
%%% ------------------------------------ end: ROI menu functions ----------------------------%%%
      
    function toggle_picked_ROI(h, obj, hObject, ID)
      
      c = ID(1);
      
      %% reset earlier picked ROI
      if ~all(isnan(obj.picked.ROI))
        idx = find(obj.session(obj.picked.ROI(1)).ROI_ID==obj.picked.ROI(2));
        set(obj.session(obj.picked.ROI(1)).ROI(idx),'EdgeColor','k')
      end
        
      if length(ID)>1
        c = ID(1);
        s = ID(2);
        n = ID(3);
        
        if all(obj.picked.ROI == [s n])
          obj.picked.ROI = [NaN NaN];
          h.display_ROI_info(obj,[])
          set(h.uihandles.checkbox_ROI_unsure,'enable','off','Value',false)
        else
          obj.picked.ROI = [s n];
          h.display_ROI_info(obj,ID)
          set(hObject,'EdgeColor','r')
          if ismember(n,h.clusters(c).session(s).list)
            idx = find(h.clusters(c).session(s).list==n);
            set(h.uihandles.checkbox_ROI_unsure,'enable','on','Value',h.clusters(c).session(s).ROI(idx).unsure)
          else
            set(h.uihandles.checkbox_ROI_unsure,'enable','off','Value',false)
          end
        end
      else
        obj.picked.ROI = [NaN NaN];
        h.display_ROI_info(obj,[])
        set(h.uihandles.checkbox_ROI_unsure,'enable','off','Value',false)
      end
    end


      
    function toggle_cluster_list(h, ID, add)
      
      c = ID(1);
      s = ID(2);
      n = ID(3);
      
      %% data update
      idx = find(h.clusters(c).session(s).list==n);
      
      if ~isempty(idx) %% removing ROI from cluster
        if (nargin == 3  && add)
          return
        end
        h.clusters(c).session(s).list(idx) = [];
        h.clusters(c).session(s).ROI(idx) = [];
        
        idx = find(h.data.session(s).ROI(n).cluster_ID==c);
        h.data.session(s).ROI(n).cluster_ID(idx) = [];
      elseif isempty(idx)
        if (nargin == 3  && ~add)
          return
        end
        idx = h.clusters(c).stats.occupancy(s)+1;
        h.clusters(c).session(s).list(idx) = n;
        
        h.clusters(c).session(s).ROI(idx).unsure = false;
        
        idx = length(h.data.session(s).ROI(n).cluster_ID) + 1;
        h.data.session(s).ROI(n).cluster_ID(idx) = c;
      end
      h.toggle_processed([],[],c,false)
      h.clusters(c).DUF(h,false)
      h.update_arrays(c)
    end
    
    
    
    function PUF_match_stats(h)
      c_arr = ~h.status.deleted;
      set(h.plots.histo_ct,'Data',h.data.ct(c_arr))
      set(h.plots.histo_score,'Data',h.data.score(c_arr))
    end
    
    
    
    
    function button_run_manipulation_Callback(h, hObject, eventdata)
      
%        set(hObject,'enable','off')
      disp('now executing all desired manipulations')
      
      %% going though sessions and process all manipulations of a single session at once (save loading time...)
      footprints = getappdata(0,'footprints');
      margin = 5;
      
      s_ld = 0;
      for s = 1:h.data.nSes
        for i = 1:h.status.manipulate_ct
          
          if ~h.status.manipulate(i).processed && (s==h.status.manipulate(i).pre(1).ID(1));
            
            disp(sprintf('-------------------- manipulation #%d ----------------------',i))
            
            pathSession = pathcat(h.path.mouse,sprintf('Session%02d',s));
            h5file = dir(pathcat(pathSession,'*.h5'));
            pathData = pathcat(pathSession,h5file.name);
            
            if s ~= s_ld
              Y = h5read(pathData,'/DATA');
%                disp('file read')
            end
            
            A_in = struct('n',[],'footprint',zeros(h.data.imSize(1),h.data.imSize(2),0),'ct',0,'centroid',zeros(0,2),'extents',[],'C',[]);
            %% ROIs to be found (post)
            if strcmp(h.status.manipulate(i).type,'merge') && ~length(h.status.manipulate(i).post)
              A_in.ct = 1;
              A_in.footprint(:,:,1) = zeros(h.data.imSize(1),h.data.imSize(2));
              
              for j = 1:length(h.status.manipulate(i).pre)
                s_pre = h.status.manipulate(i).pre(j).ID(1);
                n = h.status.manipulate(i).pre(j).ID(2);
                
                A_in.footprint(:,:,1) = A_in.footprint(:,:,1) + full(footprints.session(s_pre).ROI(n).A);
              end
              A_in.status(A_in.ct) = true;
            else
              for j = 1:length(h.status.manipulate(i).post)
                s_post = h.status.manipulate(i).post(j).ID(1);
                n = h.status.manipulate(i).post(j).ID(2);
                
                %% post footprint
                A_in.ct = A_in.ct + 1;
                A_in.footprint(:,:,A_in.ct) = full(footprints.session(s_post).ROI(n).A);
                A_in.status(A_in.ct) = true;
              end
           
            end
            
            [y_idx,x_idx,z_idx] = ind2sub(size(A_in.footprint),find(A_in.footprint));
            A_in.extents = [max(1,min(y_idx)-margin), min(h.data.imSize(1),max(y_idx)+margin); max(1,min(x_idx)-margin), min(h.data.imSize(2),max(x_idx)+margin)];
            A_in.footprint = A_in.footprint(A_in.extents(1,1):A_in.extents(1,2),A_in.extents(2,1):A_in.extents(2,2),:);
              
            [d1,d2,~] = size(A_in.footprint);               % dimensions of dataset
            d = d1*d2;                                      % total number of pixels
            
            %% find closeby pre-footprints  
            IDs = cat(1,h.status.manipulate(i).pre.ID);
            for n = 1:footprints.data.session(s).nROI
              if ~ismember(n,IDs(:,2)) && ~h.status.session(s).deleted(n)
%  %                  footprints.session(s).ROI(n).A
%  %                  [s n]
                if isempty(footprints.session(s).ROI(n).A)
                  disp('removing')
                  [s n]
                  h.remove_ROI(s,n)
                else
                  A_tmp = footprints.session(s).ROI(n).A(A_in.extents(1,1):A_in.extents(1,2),A_in.extents(2,1):A_in.extents(2,2));
                  if nnz(A_tmp) > 10;
                    A_in.ct = A_in.ct + 1;
                    A_in.footprint(:,:,A_in.ct) = full(A_tmp);
                    A_in.status(A_in.ct) = false;
                  end
                end
              end
            end
            for j = 1:A_in.ct
              A_norm = A_in.footprint(:,:,j)/sum(sum(A_in.footprint(:,:,j)));
              A_in.centroid(j,:) = [sum((1:d1)*A_norm),sum(A_norm*(1:d2)')];
            end
            
            Y_tmp = single(Y(A_in.extents(1,1):A_in.extents(1,2),A_in.extents(2,1):A_in.extents(2,2),:));
%              Y_tmp = single(read_file_crop(pathData,A_in.extents));
            
            A_in.C = zeros(A_in.ct,size(Y_tmp,3));
            for j = 1:A_in.ct
              A_tmp = A_in.footprint(:,:,j);
              for t=1:size(Y_tmp,3)
                A_in.C(j,t) = sum(sum(A_tmp.*Y_tmp(:,:,t)));
              end
            end
            ROI_out = manipulate_CNMF(h,h.status.manipulate(i),h.path,Y_tmp,A_in);%single(Y(extents(1,1):extents(1,2),extents(2,1):extents(2,2),:)));
            
            Cn = correlation_image(Y_tmp);%Y(extents(1,1):extents(1,2),extents(2,1):extents(2,2),:)); % image statistic (only for display purposes)
            
            h.query_manipulate(s,i,Cn,A_in,ROI_out)
            
%            else
%              disp(sprintf('%d (%s) already processed',i,h.status.manipulate(i).type))
          end
        end
      end
      clear Y
      clear footprints
      set(hObject,'enable','on')
    end
    
    
    function query_manipulate(h,s,i,Cn,A_in,ROI_out)

      footprints = getappdata(0,'footprints');
      
      pathCa = pathcat(h.path.mouse,sprintf('Session%02d',s),'CaData.mat');
      ld_Ca = load(pathCa);
      
      h.uihandles.queryfig(i) = figure('position',[100 100 1200 900]);
      
      h.uihandles.manipulate_accept(i) = uicontrol(h.uihandles.queryfig(i),'Style','pushbutton',...
                                      'String','Accept',...
                                      'Units','normalized','Position',[0.6 0.05 0.15 0.05],'Callback',{@h.accept_manipulation,i,ROI_out});
              
      h.uihandles.manipulate_refuse(i) = uicontrol(h.uihandles.queryfig(i),'Style','pushbutton',...
                                      'String','Refuse',...
                                      'Units','normalized','Position',[0.2 0.05 0.15 0.05],'Callback',{@h.refuse_manipulation,i});
      
      h.uihandles.query_keep_open(i) = uicontrol(h.uihandles.queryfig(i),'Style','checkbox',...
                                      'Value',0,'String','keep window open',...
                                      'Units','normalized','Position',[0.8 0.05 0.15 0.05]);
      
      time_arr = linspace(1/15,8989/15,8989);
      ax_pre = subplot(2,2,1);
      ax_post = subplot(2,2,2);
      
      ax_Ca_pre = subplot(6,1,4);
      ax_Ca_post = subplot(6,1,5);
      
      ax_S = subplot(6,1,6);
      
      hold(ax_pre,'on')
      hold(ax_Ca_pre,'on')
      imagesc(ax_pre,Cn)
      ax_pre.CLim = [0.5,1];
      
      %% plot contours and Ca of pre neurons
      for j = 1:length(h.status.manipulate(i).pre)
        n_pre = h.status.manipulate(i).pre(j).ID(2);
        A_pre = full(footprints.session(s).ROI(n_pre).A(A_in.extents(1,1):A_in.extents(1,2),A_in.extents(2,1):A_in.extents(2,2)));
        contour(ax_pre,A_pre,'b')
        C_tmp = ld_Ca.C2(n_pre,:);
        C_tmp = C_tmp/max(C_tmp);
        plot(ax_Ca_pre,time_arr,(j-1)+C_tmp,'b')
      end
      
      %% plot contours and Ca of inputs to CNMF_manipulate
      for j=1:A_in.ct
        if A_in.status(j)
          col = 'r';
          
          C_tmp = A_in.C(j,:);
          baseline = prctile(C_tmp,5);
          C_tmp = C_tmp - baseline;
          C_tmp = C_tmp/max(C_tmp);
          plot(ax_Ca_post,time_arr,(j-1)+C_tmp,'k:','LineWidth',0.8)
        else
          col = 'g';
        end
        contour(ax_pre,A_in.footprint(:,:,j),col)
      end
      hold(ax_pre,'off')
      hold(ax_Ca_pre,'off')
      
      
      %%% now, plotting all results
      hold(ax_post,'on')
      hold(ax_Ca_post,'on')
      hold(ax_S,'on')
      
      imagesc(ax_post,Cn)
      ax_post.CLim = [0.5,1];
      
      for j=1:length(ROI_out)
        contour(ax_post,ROI_out(j).A(A_in.extents(1,1):A_in.extents(1,2),A_in.extents(2,1):A_in.extents(2,2)),'r')
        
        C_tmp = ROI_out(j).C;
        C_tmp = C_tmp/max(C_tmp);
        plot(ax_Ca_post,time_arr,(j-1)+C_tmp,'r')
        
        S_tmp = ROI_out(j).S;
        S_tmp = S_tmp/max(S_tmp);
        plot(ax_S,time_arr,(j-1)+S_tmp,'k')
        
        prc = 30;
        nsd = 4;
        modeS = prctile(S_tmp(S_tmp>0),prc);                    %% get mode from overall activity
        activity = floor(sqrt(S_tmp/(modeS*nsd)));         %% only activity from actual times
        text(600,(j-1)+0.2,sprintf('spikes: %d',sum(activity)))
        plot(ax_S,[0,600],(j-1)+[modeS*nsd modeS*nsd],'r--')
      end
      
      hold(ax_post,'off')
      hold(ax_Ca_post,'off')
      hold(ax_S,'off')
      
      linkaxes([ax_Ca_pre,ax_Ca_post,ax_S],'x')
      
      
    %%% add as text somewhere in the plot
%      for j = 1:size(manipulate.pre.ID,1)
%        corr_tmp = corrcoef(ROI_out(i).C,ld_Ca.C2(manipulate.pre.ID(j,2),:));
%        corr_tmp = corr_tmp(1,2);
%        corr_tmp
%      end
    end
    
    function accept_manipulation(h,hObject,eventdata,i,ROI_out)
      
      if ~get(h.uihandles.query_keep_open(i),'Value')
        close(h.uihandles.queryfig(i))   %% add possibility to keep window open
      end
      %% save footprint and Calcium trace to end of footprints & Ca files
      s = h.status.manipulate(i).pre(1).ID(1);
      pathSession = pathcat(h.path.mouse,sprintf('Session%02d',s));
      
      CaPath = pathcat(pathSession,'CaData.mat');
      Ca_mat = matfile(CaPath,'Writable',true);
      
      %%% remove 1 merge / split counter from each post neuron (pre neurons are deleted anyway)
      for j = 1:length(h.status.manipulate(i).post)
        sm = h.status.manipulate(i).post(j).ID(1);
        m = h.status.manipulate(i).post(j).ID(2);
        switch h.status.manipulate(i).type
          case 'merge'
            h.status.session(sm).merge_ct(m) = max(0,h.status.session(sm).merge_ct(m) - 1);
          case 'split'
            h.status.session(sm).split_ct(m) = max(0,h.status.session(sm).split_ct(m) - 1);
        end
      end
      
      for j = 1:length(ROI_out)
        
        footprints = getappdata(0,'footprints');
        
        n = h.data.session(s).nROI + j;    %% append to end of data
        h.data.session(s).nROI = n;
        
        %% update footprints structure
        footprints.data.session(s).nROI = n;
        footprints.session(s).ROI(n).A = ROI_out(j).A;
        
        A_tmp_norm = ROI_out(j).A/sum(ROI_out(j).A(:));
        footprints.session(s).ROI(n).centroid = [sum((1:h.data.imSize(1))*A_tmp_norm),sum(A_tmp_norm*(1:h.data.imSize(2))')];
        footprints.session(s).ROI(n).norm = norm(full(ROI_out(j).A));
        
        footprints.session(s).centroids(n,:) = footprints.session(s).ROI(n).centroid;
        setappdata(0,'footprints',footprints)
        h.status.save.footprints = true;
        
        h.data.cluster_centroids(n,:) = footprints.session(s).ROI(n).centroid;
        
        h.add_xdata(s,n)
        
        %% update CaTraces file
        Ca_mat.C2(n,:) = ROI_out(j).C';
        Ca_mat.S2(n,:) = ROI_out(j).S';
        
        %% update h-structure
        h.status.session(s).merge_ct(n) = 0;
        h.status.session(s).split_ct(n) = 0;
        h.status.session(s).manipulated(n) = true;
        h.status.session(s).deleted(n) = false;
        
        h.data.session(s).ROI(n) = struct('cluster_ID',[]);
        
        %% add new ROI to all clusters, to which post neurons belonged
        for k = 1:length(h.status.manipulate(i).post)
          sm = h.status.manipulate(i).post(k).ID(1);
          m = h.status.manipulate(i).post(k).ID(2);
          for c = h.data.session(sm).ROI(m).cluster_ID
            h.toggle_cluster_list([c,s,n],true)
          end
        end
        
        %% add new ROI to all clusters, to which pre neurons belonged
        for k = 1:length(h.status.manipulate(i).pre)
          sm = h.status.manipulate(i).pre(k).ID(1);
          m = h.status.manipulate(i).pre(k).ID(2);
          for c = h.data.session(sm).ROI(m).cluster_ID
            h.toggle_cluster_list([c,s,n],true)
          end
        end
        
        
        for c = h.data.session(s).ROI(n).cluster_ID
          h.update_arrays(c)
        end
      end
      
      h.data.session(s).nROI = n;
      
      %% "delete" old (pre)-neurons
      for j = 1:length(h.status.manipulate(i).pre)
        sm = h.status.manipulate(i).pre(j).ID(1);
        m = h.status.manipulate(i).pre(j).ID(2);
        h.remove_ROI(sm,m);
      end
      
      h.status.manipulate(i).processed = true;
      h.update_table()
      h.update_statusboxes()
      
      %% update plots: single ROIs display (replot cluster), and clustershape (replot shape)
      h.choose_cluster(h.c_disp.active,h.data.session(s).ROI(n).cluster_ID(1))
      
      
    end
    
    
    function status = refuse_manipulation(h,hObject,eventdata,i)
      status = false;
      disp('manipulation refused')
      if ~get(h.uihandles.query_keep_open(i),'Value')
        close(h.uihandles.queryfig(i))
      end
      
      %% remove from manipulation list
      h.remove_manipulation(i)
    end
    
    
    function add_xdata(h,s,n)
      xdata = getappdata(0,'xdata');
      footprints = getappdata(0,'footprints');
      pathModel = pathcat(h.path.mouse,'model.mat');
      load(pathModel)
      
      for sm = 1:h.data.nSes
      
        if sm == s
          dist_tmp = h.parameter.microns_per_pixel*sqrt((footprints.session(s).ROI(n).centroid(1) - footprints.session(sm).centroids(:,1)).^2 + (footprints.session(s).ROI(n).centroid(2) - footprints.session(sm).centroids(:,2)).^2);
          
          xdata(s,sm).neighbours(n,1:n) = sparse(1*(dist_tmp < h.parameter.dist_max));
          xdata(s,sm).neighbours(:,n) = xdata(s,sm).neighbours(n,:)';
          
          neighbours = xdata(s,sm).neighbours(n,:) > 0;
          idx_nb = find(neighbours);
          xdata(s,sm).dist(n,neighbours) = dist_tmp(neighbours);
          xdata(s,sm).dist(:,n) = xdata(s,sm).dist(n,:)';
          for m = idx_nb
            xdata(s,sm).corr(n,m) = min(1,dot(footprints.session(s).ROI(n).A(:),footprints.session(sm).ROI(m).A(:))/(footprints.session(s).ROI(n).norm*footprints.session(sm).ROI(m).norm));
            xdata(s,sm).corr(m,n) = xdata(s,sm).corr(n,m);
          end
          
          idx_dist = max(1,ceil(h.parameter.nbins*xdata(s,sm).dist(n,neighbours)/h.parameter.dist_max));
          idx_corr = max(1,ceil(h.parameter.nbins*min(1,xdata(s,sm).corr(n,neighbours))/h.parameter.corr_max));
          
          for k=1:length(idx_dist)
            val_tmp = model.p_same_joint(idx_dist(k),idx_corr(k));
            xdata(s,sm).prob(n,idx_nb(k)) = val_tmp;
          end
          xdata(s,sm).prob(:,n) = xdata(s,sm).prob(n,:)';
          
        else
          dist_tmp = h.parameter.microns_per_pixel*sqrt((footprints.session(s).ROI(n).centroid(1) - footprints.session(sm).centroids(:,1)).^2 + (footprints.session(s).ROI(n).centroid(2) - footprints.session(sm).centroids(:,2)).^2);
          
          xdata(s,sm).neighbours(n,1:h.data.session(sm).nROI) = zeros(1,h.data.session(sm).nROI);
          xdata(s,sm).dist(n,1:h.data.session(sm).nROI) = zeros(1,h.data.session(sm).nROI);
          xdata(s,sm).corr(n,1:h.data.session(sm).nROI) = zeros(1,h.data.session(sm).nROI);
          xdata(s,sm).prob(n,1:h.data.session(sm).nROI) = zeros(1,h.data.session(sm).nROI);
          
          xdata(s,sm).neighbours(n,1:length(dist_tmp)) = sparse(1*(dist_tmp < h.parameter.dist_max));
          neighbours = xdata(s,sm).neighbours(n,:) > 0;
          idx_nb = find(neighbours);
          xdata(s,sm).dist(n,neighbours) = dist_tmp(neighbours);
          
          for m = idx_nb
            xdata(s,sm).corr(n,m) = min(1,dot(footprints.session(s).ROI(n).A(:),footprints.session(sm).ROI(m).A(:))/(footprints.session(s).ROI(n).norm*footprints.session(sm).ROI(m).norm));
          end
          
          idx_dist = max(1,ceil(h.parameter.nbins*xdata(s,sm).dist(n,neighbours)/h.parameter.dist_max));
          idx_corr = max(1,ceil(h.parameter.nbins*min(1,xdata(s,sm).corr(n,neighbours))/h.parameter.corr_max));
          
          for k=1:length(idx_dist)
            val_tmp = model.p_same_joint(idx_dist(k),idx_corr(k));
            xdata(s,sm).prob(n,idx_nb(k)) = val_tmp;
          end
        
          xdata(sm,s).neighbours = 1*(xdata(s,sm).neighbours>0)';  %% possibly different nearest neighbours
          xdata(sm,s).dist = xdata(s,sm).dist';
          xdata(sm,s).corr = xdata(s,sm).corr';
          xdata(sm,s).prob = xdata(s,sm).prob';
        end
      end
      setappdata(0,'xdata',xdata)
      h.status.save.xdata = true;
    end
  end
end



function real_matching(data,p_thr)
  
  xdata = getappdata(0,'xdata');
  mode = 'threshold';
%      mode = 'other';
  
  c = 0;
  
  session(data.nSes) = struct;
  for s = 1:data.nSes
    session(s).ROI_matched = false(data.session(s).nROI,1);
  end
  
  disp('registering')
  
  for s = 1:data.nSes
    
    for n = 1:data.session(s).nROI
      
      if ~session(s).ROI_matched(n)
        
        c = c + 1;
        clusters(c) = struct('A',[],'centroid',[],'score',NaN,'ct',NaN,'session',struct('list',cell(data.nSes,1),'ROI',struct('score',[],'mean_score',[],'unsure',false)));
        
        clusters(c).session(s).list = n;
        
        if mod(c,500)==0
          disp(sprintf('%d clusters found.',c))
        end
        
        for sm = 1:data.nSes
          if s==sm
            continue
          end
          
          if strcmp(mode,'threshold')
            
            matches_s = find(xdata(s,sm).prob(n,:)>p_thr);
            p_same_s = xdata(s,sm).prob(n,matches_s);
            
            [p_best_s,idx_s] = max(p_same_s);
            if p_best_s > p_thr
              best_match_s = matches_s(idx_s);
              
              %% check for reciprocity
              matches_s_ref = find(xdata(sm,s).prob(best_match_s,:)>p_thr);
              p_same_s_ref = xdata(sm,s).prob(best_match_s,matches_s_ref);
              
              [p_best_s_ref,idx_s_ref] = max(p_same_s_ref);
              
              if (matches_s_ref(idx_s_ref) == n) && (p_best_s_ref > p_thr)% && ~session(sm).ROI_matched(best_match_s)
                clusters(c).session(sm).list = best_match_s;
              end
            end
          end
        end
        
%        %% assign matched status to all within pre_clusters
        occupancy = zeros(data.nSes,1);
        for sm = 1:data.nSes
          for i = 1:length(clusters(c).session(sm).list)
            n = clusters(c).session(sm).list(i);
            clusters(c).session(sm).ROI(i).unsure = false;
            session(sm).ROI_matched(n) = true;
          end
          occupancy(sm) = length(clusters(c).session(sm).list);
        end
        
        clusters(c).ct = nnz(occupancy);
        if clusters(c).ct < 2
          clusters(c) = [];
          c = c - 1;
        end
        
      end
    end
  end
  
  setappdata(0,'clusters',clusters)
  clusters
  
end




function [n, p_same] = get_matches(n,xdata,p_thr,s_ref,n_ref,s)
  
  %% search for all ROIs, that are not certainly rejected due to footprint or distance
  p_same = full(xdata(s_ref,s).prob(n_ref,n));
  
  mask = p_same>p_thr;
  n = n(mask);
  p_same = p_same(mask);
end
  
  


function [disallowRotation] = myRotateFilter(hObject,eventdata)
  
  disallowRotation = false;
  % if a ButtonDownFcn has been defined for the object, then use that
  if isfield(get(hObject),'ButtonDownFcn')
    disallowRotation = ~isempty(get(hObject,'ButtonDownFcn'));
  end
end



function [corr_1w] = get_1w_corr(ROI_n,ROI_m)
  A_n = reshape(ROI_n.A,[],1);
  A_m = reshape(ROI_m.A,[],1);
  
  idx_n = find(A_n);
  
  corr_1w = full(dot(A_n(idx_n),A_m(idx_n))/(ROI_n.norm*norm(A_m(idx_n))));
end



