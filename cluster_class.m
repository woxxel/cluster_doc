

classdef cluster_class < handle
  
  properties
    %% marked by x = needed as input
    %% everything else can be calculated from it
    session 
        list          % x
        ROI   
            unsure    % x
            dist
            corr
            prob
            mean_dist
            mean_corr
            mean_prob
    occupancy
    polyROI
    
    centroid
    A
    score
    ct
    
    %%% status
      calc_shape
      calc_stats
      calc_status
      calc_occupancy
      
      merge_ct        % x
      split_ct        % x
      
      deleted         % x
      unsure          % x
      
    %%% plot
      color
      thickness
  end
  
  methods
    
    function this = cluster_class(h,cluster,status)
      
      %% get data from input and perform first DUF on it!
      this.session = struct('list',cell(h.data.nSes,1),'ROI',struct);%struct('unsure',false,...
%                                                                      'dist',[],'corr',[],'prob',[],...
%                                                                      'mean_dist',[],'mean_corr',[],'mean_prob',[]));
      for s = 1:h.data.nSes
        this.session(s).list = clusters.session(s).list;
        this.session(s).ROI = clusters.session(s).ROI;
        
%          for idx = 1:length(this.session(s).list)
%            this.session(s).ROI(idx).unsure = clusters(c).session(s).ROI(idx).unsure;
          
%            n = this.session(s).list(idx);
%            h.data.session(s).ROI(n).cluster_ID = [h.data.session(s).ROI(n).cluster_ID c];
%          end
      end
      
      if nargin < 3
        this.merge_ct = status.merge_ct;
        this.split_ct = status.split_ct;
        
        this.deleted = status.deleted;
        this.unsure = status.deleted;
      else
        this.merge_ct = 0;
        this.split_ct = 0;
        
        this.deleted = false;
        this.unsure = false;
      end
      
      this.DUF()
      
    end
    
    
    function DUF(h,c_arr,calc,wbar)
      if nargin > 1
        if nargin > 2
          h.status.clusters(c_arr).calc_occupancy = calc;
          h.status.clusters(c_arr).calc_status = calc;
          h.status.clusters(c_arr).calc_shape = calc;
          h.status.clusters(c_arr).calc_stats = calc;
        end
        
        ld_footprints = ~all([h.status.clusters(c_arr).calc_shape]);
        ld_xdata = ~all([h.status.clusters(c_arr).calc_stats]);
        ld_clusters = ld_footprints || ld_xdata;
        
        if ld_footprints
          footprints = getappdata(0,'footprints');
        end
        if ld_xdata
          xdata = getappdata(0,'xdata');
        end
        
        for c = c_arr
          if h.status.deleted(c)
            continue
          end
          if nargin == 4 && wbar && ~mod(find(c==c_arr),100)
            msg = sprintf('Prepared data of %d/%d clusters',c,h.data.nCluster);
            waitbar(c/(2*h.data.nCluster),h.hwait,msg)
          end
          
          h.DUF_cluster_occupancy(c);
          h.DUF_cluster_status(c);
          
          if ld_footprints && ~h.status.clusters(c).calc_shape
            tmp = h.DUF_cluster_shape(footprints,c);
          end
          if ld_xdata && ~h.status.clusters(c).calc_stats
            tmp = h.DUF_cluster_stats(xdata,c);
          end
        end
      end
      
      h.DUF_process_info()
    end
    
    
    
    function DUF_cluster_occupancy(h,c)   %% 1st
      
      if ~h.status.clusters(c).calc_occupancy
        h.data.clusters(c).occupancy = zeros(h.data.nSes,1);
        for s = 1:h.data.nSes
          h.data.clusters(c).occupancy(s) = length(h.data.clusters(c).session(s).list);
        end
        h.data.cluster_ct(c) = nnz(h.data.clusters(c).occupancy);
        h.plots.clusters(c).thickness = h.data.cluster_ct(c)/h.data.nSes * 3;
        
        if h.data.cluster_ct(c) <= 1
          h.empty_cluster(c);
        end
        h.status.clusters(c).calc_occupancy = true;
      end
    end
    
    
    
    function DUF_cluster_status(h,c)    %% 2nd
      
      if ~h.status.clusters(c).calc_status
        h.status.cluster_multiROI(c) = any(h.data.clusters(c).occupancy>1); %% multiple ROIs assigned in any session?
        
        h.status.cluster_polyROI(c) = false;
        h.status.cluster_manipulated(c) = false;
        h.data.clusters(c).polyROI = zeros(h.data.nSes,1);
        
        for s = 1:h.data.nSes
          for n = h.data.clusters(c).session(s).list
            polyROI = length(h.data.session(s).ROI(n).cluster_ID);
            h.data.clusters(c).polyROI(s) = max(h.data.clusters(c).polyROI(s),polyROI);
            h.status.cluster_polyROI(c) = h.status.cluster_polyROI(c) || polyROI>1;
            h.status.cluster_manipulated(c) = h.status.cluster_manipulated(c) || h.status.session(s).manipulated(n);
          end
        end
        
        h.status.merge_cluster(c) = logical(h.status.clusters(c).merge_ct);
        h.status.split_cluster(c) = logical(h.status.clusters(c).split_ct);
        
        h.status.clusters(c).calc_status = true;
      end
    end
      
      
    function clusters = DUF_cluster_shape(h,footprints,c,clusters)   %% 3rd
      
%        if ~h.status.clusters(c).calc_shape
        if nargin < 4
          clusters_tot = getappdata(0,'clusters');
          clusters = clusters_tot(c);
        end
        clusters.A = sparse(h.data.imSize(1),h.data.imSize(2));
        
        for s = 1:h.data.nSes
          for n = h.data.clusters(c).session(s).list
            clusters.A = clusters.A + footprints.session(s).ROI(n).A;
          end
        end
        if sum(clusters.A(:))
          clusters.A = sparse(clusters.A/sum(clusters.A(:)));
        end
        clusters.centroid = [sum((1:h.data.imSize(1))*clusters.A),sum(clusters.A*(1:h.data.imSize(2))')];
        
        h.status.clusters(c).calc_shape = true;
        if nargin < 4
          clusters_tot(c) = clusters;
          setappdata(0,'clusters',clusters_tot)
        end
%        end
    end

      
    function clusters = DUF_cluster_stats(h,xdata,c,clusters)    % 4th
      
%        if ~h.status.clusters(c).calc_stats
        if nargin < 4
          clusters_tot = getappdata(0,'clusters');
          clusters = clusters_tot(c);
        end
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
                  try
                    clusters.session(s).ROI(i).dist(sm,j) = xdata(s,sm).dist(n,m);
                    clusters.session(s).ROI(i).corr(sm,j) = xdata(s,sm).corr(n,m);
                    clusters.session(s).ROI(i).prob(sm,j) = xdata(s,sm).prob(n,m);
                  catch
                    clusters.session(s).ROI(i).dist(sm,j) = NaN;
                    clusters.session(s).ROI(i).corr(sm,j) = NaN;
                    clusters.session(s).ROI(i).prob(sm,j) = NaN;
                  end
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
        if nargin < 4
          clusters_tot(c) = clusters;
          setappdata(0,'clusters',clusters_tot)
        end
%        end
    end
    
  end
end