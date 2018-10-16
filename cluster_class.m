

classdef cluster_class < handle
  
  properties
    %% marked by x = needed as input
    %% everything else can be calculated from it
    
    ID                % x -> should know, who he is
    nSes              % x -> cheap and useful
    
    session           = struct('list',[],'ROI',struct)
%          list          % x
%          ROI   
%              dist
%              corr
%              prob
%              mean_dist
%              mean_corr
%              mean_prob
    
    centroid
    A
    
    status            = struct('calc_shape',false,'calc_stats',false,'calc_status',false,'calc_occupancy',false,...
                             'manipulated',0,'deleted',false,...   % x
                             'whelpling',false)                               % x
    
    stats             = struct('occupancy',[],'polyROI',[],'multiROI',[],...
                               'ct',0,'score',0)
    
    plot              = struct('color',NaN,'thickness',0)
  end
  
  events
    emptyCluster
  end
  
  methods
    
    function this = cluster_class(nC,IDs,h,clusters,status,footprints,xdata)
      
      ct = 0;
      if nargin ~= 0
        
        if nC == 1
          this(1).status.whelpling = true;
        end
          
        for c = 1:nC
          if h.wbar.status
            h.wbar.ct = h.wbar.ct + 1;
            if ~mod(h.wbar.ct,100)  % change to something else... (counter counting up)
              msg = sprintf('Loaded %d/%d clusters',h.wbar.ct,h.wbar.overall);
              waitbar(h.wbar.ct/(2*h.wbar.overall),h.wbar.handle,msg)
            end
          end
          %% get data from input and perform first DUF on it!
          this(c).ID = IDs(c);
          this(c).nSes = h.data.nSes;
          
          this(c).session = struct('list',cell(this(c).nSes,1),'ROI',struct);%struct('dist',[],'corr',[],'prob',[],...
    %                                                                                'mean_dist',[],'mean_corr',[],'mean_prob',[]));
          for s = 1:this(c).nSes
            this(c).session(s).list = clusters(c).session(s).list;
            if ~isfield(clusters(c).session(s),'ROI')
              this(c).session(s).ROI = [];
            else
              this(c).session(s).ROI = clusters(c).session(s).ROI;
            end
          end
          
          if ~isempty(status)
            this(c).status.deleted = status.deleted(c);
            if this(c).status.deleted
              this(c).centroid = [NaN NaN];
            end
          end
          
          this(c).DUF(h,false,footprints,xdata)
          this(c).status.whelpling = false;
        end
      end
    end
    
    
    function DUF(this,h,calc,footprints,xdata)
      
      
      if ~this.status.deleted
        
        if nargin < 4
          footprints = [];
        end
        if nargin < 5
          xdata = [];
        end
        
        if nargin > 2
          this.status.calc_occupancy = calc;
          this.status.calc_status = calc;
          this.status.calc_shape = calc;
          this.status.calc_stats = calc;
        end
        
        if ~this.status.calc_occupancy
          this.DUF_cluster_occupancy()
        end
        if ~ this.status.calc_status
          this.DUF_cluster_status(h)
        end
        if ~this.status.calc_shape
          this.DUF_cluster_shape(footprints)
        end
        if ~this.status.calc_stats
          this.DUF_cluster_stats(xdata);
        end
      end
    end
    
    
    
    function DUF_cluster_occupancy(this)   %% 1st
      
      this.stats.occupancy = zeros(this.nSes,1);
      for s = 1:this.nSes
        this.stats.occupancy(s) = length(this.session(s).list);
      end
      this.stats.ct = nnz(this.stats.occupancy);
      this.plot.thickness = max(0.1,this.stats.ct/this.nSes * 3);
      
      if this.stats.ct <= 1 && ~this.status.whelpling
        notify(this,'emptyCluster')
      end
      this.status.calc_occupancy = true;
    end
    
    
    
    function DUF_cluster_status(this,h)    %% 2nd
      
      this.stats.multiROI = any(this.stats.occupancy>1); %% multiple ROIs assigned in any session?
      
      this.stats.polyROI = zeros(this.nSes,1);
      this.status.manipulated = 0;
      
      for s = 1:this.nSes
        for n = this.session(s).list
          polyROI = length(h.data.session(s).ROI(n).cluster_ID);
          this.stats.polyROI(s) = max(this.stats.polyROI(s),polyROI);       %% if more than 1 neuron in session
          
          this.status.manipulated = max(this.status.manipulated,h.status.session(s).manipulated(n));
          
        end
      end
      this.status.calc_status = true;
    end
      
      
    function DUF_cluster_shape(this,footprints)   %% 3rd
      
      if isempty(footprints)
        footprints = getappdata(0,'footprints');
      end
      
      imSize = size(footprints.session(1).ROI(1).A);
      this.A = sparse(imSize(1),imSize(2));
      
      for s = 1:this.nSes
        for n = this.session(s).list
          this.A = this.A + footprints.session(s).ROI(n).A;
        end
      end
      if sum(this.A(:))
        this.A = sparse(this.A/sum(this.A(:)));
      end
      this.centroid = [sum((1:imSize(1))*this.A),sum(this.A*(1:imSize(2))')];
      
      this.status.calc_shape = true;
    end

      
    function DUF_cluster_stats(this,xdata)    % 4th
      
      if this.stats.ct > 1
        
        if isempty(xdata)
          xdata = getappdata(0,'xdata');
        end
        %% preparing data
        width = max(this.stats.occupancy);
        for s = 1:this.nSes
          for i = 1:this.stats.occupancy(s)
            this.session(s).ROI(i).dist = zeros(this.nSes,width);
            this.session(s).ROI(i).corr = zeros(this.nSes,width);
            this.session(s).ROI(i).prob = zeros(this.nSes,width);
          end
        end
        
        %% writing and calculating stats
        prob = [];
        for s = 1:this.nSes
          for i = 1:this.stats.occupancy(s)
            n = this.session(s).list(i);
            
            for sm = 1:this.nSes
              for j = 1:this.stats.occupancy(sm)
                m = this.session(sm).list(j);
                
                if all([s n] == [sm m])
                  continue
                end
                try
                  this.session(s).ROI(i).dist(sm,j) = xdata(s,sm).dist(n,m);
                  this.session(s).ROI(i).corr(sm,j) = xdata(s,sm).corr(n,m);
                  this.session(s).ROI(i).prob(sm,j) = xdata(s,sm).prob(n,m);
                catch
                  this.session(s).ROI(i).dist(sm,j) = NaN;
                  this.session(s).ROI(i).corr(sm,j) = NaN;
                  this.session(s).ROI(i).prob(sm,j) = NaN;
                end
              end
            end
            this.session(s).ROI(i).mean_dist = sum(this.session(s).ROI(i).dist(:))/(sum(this.stats.occupancy) - 1);
            this.session(s).ROI(i).mean_corr = sum(this.session(s).ROI(i).corr(:))/(sum(this.stats.occupancy) - 1);
            this.session(s).ROI(i).mean_prob = sum(this.session(s).ROI(i).prob(:))/(sum(this.stats.occupancy) - 1);
            prob = [prob this.session(s).ROI(i).mean_prob];
          end
        end
        
        this.stats.score = mean(prob)^(1+var(prob));
      else
        this.stats.score = 0;
      end
      
      this.plot.color = [1-this.stats.score,this.stats.score,0];
      this.status.calc_stats = true;
    end
  end
end