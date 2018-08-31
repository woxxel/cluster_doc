

function [hPlot] = plot_blobs(ax,A,offset,thr,ROI_line,ROI_color,ROI_thickness,hwait)
  
  %% --- INPUTS ---
  %% ax		- axis to plot to
  %% A 		- (nX x nY x nROI) array containing ROI footprints in order to plot  
  %% offset - coordinates (min_y, max_y, min_x, max_x) of imaging window to be displayed
  %% thr 	- threshold for "energy"-cutoff of displayed ROI area (0 = full, 1=peak only)
  %% ROI_line 	- linestyle of ROI contours: single value, or cell of length nROI to be plotted
  %% ROI_color 	- color of ROI contours: single value, or cell of length nROI to be plotted
  
  %% --- OUTPUTS ---
  %% hPlot 	- handles to ROIs
  
  
  nROI = size(A,3);
  
  if ~iscell(ROI_line) || ~(length(ROI_line) == nROI)
    linestyle_tmp = ROI_line;
    ROI_line={};
    [ROI_line{1:nROI}] = deal(linestyle_tmp);
  end
  
  if ~iscell(ROI_color) || ~(length(ROI_color) == nROI)
    color_tmp = ROI_color;
    ROI_color={};
    [ROI_color{1:nROI}] = deal(color_tmp);
  end
  
  if ~iscell(ROI_thickness) || ~(length(ROI_thickness) == nROI)
    thickness_tmp = ROI_thickness;
    ROI_thickness={};
    [ROI_thickness{1:nROI}] = deal(thickness_tmp);
  end
  
  if nargin==8
    waitbar(0,hwait,sprintf('Plotting %d ROIs...',nROI))
  end
  
  if isempty(offset)
    offset = [0 0];
  end
  
  hold(ax,'on')
  for n=1:size(A,3)
    if nargin==8 && mod(n,100)==0
      waitbar(n/nROI,hwait)
    end
    if nROI==1
      A_tmp = A;
    else
      A_tmp = A(:,:,n);
    end
    if nanmax(A_tmp(:)) > 0
      A_tmp(A_tmp<thr*max(A_tmp(:))) = 0;
      BW = bwareafilt(A_tmp>0,1);
      blob = bwboundaries(BW);
      if ~isempty(blob)
        if length(blob)>1
          max_sz = 0;
          for ii = 1:length(blob)
            max_sz = max(max_sz,size(blob{ii},1));
          end
        end
        for ii = 1:length(blob)
          if length(blob)>1
            if size(blob{ii},1) ~= max_sz
              continue
            end
          end
          blob{ii} = fliplr(blob{ii}-offset);
          hPlot(n) = plot(ax,blob{ii}(:,1),blob{ii}(:,2),ROI_line{n},'Color',ROI_color{n},'linewidth',ROI_thickness{n},'Hittest','off');
        end
      end
    end
  end
  hold(ax,'off')
  
  if nargin==8
    drawnow
    waitbar(1,hwait)
  end
end