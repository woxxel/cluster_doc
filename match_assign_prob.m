

function [xdata] = match_assign_prob(xdata,data,model,para,pathXdata)
  
%    savePath = pathcat(pathMouse,'xdata.mat');
  
  %% here, all cells that are not surely different are put together in ROI_clusters
  for s = 1:data.nSes
    for sm = s+1:data.nSes
      for n = 1:data.session(s).nROI
        neighbours = xdata(s,sm).neighbours(n,:) > 0;
        idx_nb = find(neighbours);
        idx_dist = max(1,ceil(para.nbins*xdata(s,sm).dist(n,neighbours)/para.dist_max));
        idx_corr = max(1,ceil(para.nbins*xdata(s,sm).corr(n,neighbours)/para.corr_max));
        
        for i=1:length(idx_dist)
          val_tmp = model.p_same_joint(idx_dist(i),idx_corr(i));
          xdata(s,sm).prob(n,idx_nb(i)) = val_tmp;
          xdata(sm,s).prob(idx_nb(i),n) = val_tmp;
        end
      end
    end
  end
  
  
  save(pathXdata,'xdata','-v7.3')
  disp(sprintf('saved data @ %s',pathXdata))
  