

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
    panel_status
    
    checkbox_processed
    checkbox_unsure
    checkbox_pending
    checkbox_manipulated
    
    ax_sizes
    
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
      
      obj.ax_sizes = pos_ax;
      
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
      pos_GUI{1} = [pos_ax{1}(1), pos_ax{1}(2)-0.07, pos_ax{1}(3)-0.08, 0.015];
      pos_GUI{2} = [pos_ax{1}(1) + (pos_ax{1}(3)-0.07), pos_ax{1}(2)-0.07, 0.03, 0.02];
      pos_GUI{3} = [pos_ax{1}(1) + (pos_ax{1}(3)-0.03), pos_ax{1}(2)-0.07, 0.03, 0.025];
      pos_GUI{4} = [pos_ax{1}(1), pos_ax{1}(2)-0.09, 0.075, 0.02];
      pos_GUI{5} = [pos_ax{1}(1) + pos_ax{1}(3)/2, pos_ax{1}(2)+pos_ax{1}(4)+0.01, 0.05, 0.02];
      
      pos_GUI{6} = [pos_ax{2}(1), pos_ax{2}(2)-0.11, pos_ax{2}(3), 0.09];
      
      pos_GUI_checkbox = {[0.1 0.7 0.8 0.18],...
                          [0.1 0.5 0.8 0.18],...
                          [0.1 0.3 0.8 0.18],...
                          [0.1 0.1 0.8 0.18]};
      
      
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
      
      obj.panel_status = uipanel(h.uihandles.figure1,'Title','Stats','FontSize',12,...
                                'Position',pos_GUI{6});
                                
      obj.checkbox_processed = uicontrol('Parent',obj.panel_status,'Style','checkbox',...
                                         'Value',0,'String','processed',...
                                         'Units','normalized','position',pos_GUI_checkbox{1});
      obj.checkbox_unsure = uicontrol('Parent',obj.panel_status,'Style','checkbox',...
                                         'Value',0,'String','unsure',...
                                         'Units','normalized','position',pos_GUI_checkbox{2});
      obj.checkbox_pending = uicontrol('Parent',obj.panel_status,'Style','checkbox',...
                                         'Value',0,'String','pending','enable','off',...
                                         'Units','normalized','position',pos_GUI_checkbox{3});
      obj.checkbox_manipulated = uicontrol('Parent',obj.panel_status,'Style','checkbox',...
                                         'Value',0,'String','manipulated','enable','off',...
                                         'Units','normalized','position',pos_GUI_checkbox{4});
                                
      obj.picked = struct('cluster',[],'ROI',[NaN NaN],'ROI_stat',[NaN NaN]);
      
      uistack(obj.ax_ROI_display, 'top')
      
    end
  end
end
