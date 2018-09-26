

classdef build_GUI_cluster_display < handle

  properties (SetAccess = private)
    
    %% textboxes
    textbox
    ROI_textbox
    clusterstats_textbox
    add_ROI_textbox

    %% axes
    ax_ROI_display
    ax_ROI_display_stats
    ax_ROI_clusterstats
    
    %% GUI
    slider_cluster_ID
    entry_cluster_ID
    button_refresh
    checkbox_cluster_ID_skip_processed
    radio_active
    
  end
  
  properties (SetAccess = public)
    
    %% data
    picked
    session
    
    %% plots
    session_occ_poly
    
  end
    

  methods
    
    function obj = build_GUI_cluster_display(h,pos_ax,pos_txt)
      
      %% create axes
      obj.ax_ROI_display = axes('Parent',h.uihandles.figure1,'Position',pos_ax{1});
      obj.ax_ROI_display_stats = axes('Parent',h.uihandles.figure1,'Position',pos_ax{2});
      obj.ax_ROI_clusterstats = axes('Parent',h.uihandles.figure1,'Position',pos_ax{3});
      
      %% create textboxes
      box_default = [0 0 0 0];
      obj.ROI_textbox = annotation(h.uihandles.figure1,'textbox',box_default,'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
      obj.clusterstats_textbox = annotation(h.uihandles.figure1,'textbox',box_default,'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
      
      obj.textbox = annotation(h.uihandles.figure1,'textbox',pos_txt{1},'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
      obj.add_ROI_textbox = annotation(h.uihandles.figure1,'textbox',pos_txt{2},'String','','FitBoxToText','on','BackgroundColor','w','Visible','off');
      
      pos_GUI = cell(5,1);
      pos_GUI{1} = [pos_ax{1}(1), pos_ax{1}(2)-0.05, pos_ax{1}(3)-0.08, 0.015];
      pos_GUI{2} = [pos_ax{1}(1) + (pos_ax{1}(3)-0.07), pos_ax{1}(2)-0.05, 0.03, 0.02];
      pos_GUI{3} = [pos_ax{1}(1) + (pos_ax{1}(3)-0.03), pos_ax{1}(2)-0.05, 0.03, 0.025];
      pos_GUI{4} = [pos_ax{1}(1), pos_ax{1}(2)-0.07, 0.075, 0.02];
      pos_GUI{5} = [pos_ax{1}(1) + pos_ax{1}(3)/2, pos_ax{1}(2)+pos_ax{1}(4)+0.05, 0.05, 0.02];
      
      
      obj.slider_cluster_ID = uicontrol(h.uihandles.figure1,'Style','slider',...
                'Min',0,'Max',1,'Value',0,'SliderStep',[1, 1],...
                'Units','normalized','Position',pos_GUI{1});
      
      obj.entry_cluster_ID = uicontrol(h.uihandles.figure1,'Style','edit',...
                'String','',...
                'Units','normalized','Position',pos_GUI{2});
      
      obj.button_refresh = uicontrol(h.uihandles.figure1,'Style','pushbutton',...
                'String','Refresh',...
                'Units','normalized','Position',pos_GUI{3});
      
      obj.checkbox_cluster_ID_skip_processed = uicontrol(h.uihandles.figure1,'Style','checkbox',...
                'Value',0,'String','skip processed',...
                'Units','normalized','Position',pos_GUI{4});
      
      obj.radio_active = uicontrol(h.uihandles.figure1,'Style','radiobutton',...
                'String','active',...
                'Units','normalized','Position',pos_GUI{5});
      
      
      obj.picked = struct('cluster',[],'ROI',[NaN NaN],'ROI_stat',[NaN NaN]);
      
    end
  end
end
