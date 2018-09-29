
%% inputs: dataset to run CNMF on

function [ROI_out] = manipulate_CNMF(h,manipulate,path,Y,A_in)
  
  
%    if isempty(manipulate)
%  
%  %      manipulate.pre.ID = [1, 213];
%  %      manipulate.post.ID = [11,29;11,258];
%      
%      manipulate.pre.ID = [4, 2];
%      manipulate.post.ID = [4, 2];
%    end
%    
%    if isempty(path)
%      path = struct;
%      path.mouse = '/media/wollex/AS2/Masaaki/884';
%      path.footprints = pathcat(path.mouse,'footprints.mat')
%    end
%    
%    s = manipulate.pre.ID(1,1);
  
  
%%% ---------------------------- data preparation -------------------------------
  
%    margin = 5;
%    imSize = [size(Y,1), size(Y,2)];
%    
%    ld = load(path.footprints);
%    
%    A_in = struct('n',[],'footprint',zeros(imSize(1),imSize(2),0),'ct',0,'centroid',zeros(0,2),'extents',[]);
%    
%    %% ROIs to be found (post)
%    for i = 1:size(manipulate.post.ID,1)
%      s_post = manipulate.post.ID(i,1);
%      n = manipulate.post.ID(i,2);
%      
%      %% post footprint
%      A_in.ct = A_in.ct + 1;
%      A_in.footprint(:,:,A_in.ct) = full(ld.footprints.session(s_post).ROI(n).A);
%      A_in.status(A_in.ct) = true;
%      A_in.n(A_in.ct) = n;
%    end
%    
%    [y_idx,x_idx,z_idx] = ind2sub(size(A_in.footprint),find(A_in.footprint));
%    extents = [max(1,min(y_idx)-margin), min(imSize(1),max(y_idx)+margin); max(1,min(x_idx)-margin), min(imSize(2),max(x_idx)+margin)];
%    A_in.extents = extents;
%    A_in.footprint = A_in.footprint(extents(1,1):extents(1,2),extents(2,1):extents(2,2),:);
%    
%    
%    
%    %% find closeby pre-footprints  
%    for n = 1:ld.footprints.data.session(s).nROI
%      if ~ismember(n,manipulate.pre.ID(:,2))
%        A_tmp = ld.footprints.session(s).ROI(n).A(extents(1,1):extents(1,2),extents(2,1):extents(2,2));
%        if nnz(A_tmp) > 10;
%          A_in.ct = A_in.ct + 1;
%          A_in.footprint(:,:,A_in.ct) = full(A_tmp);
%          A_in.status(A_in.ct) = false;
%          A_in.n(A_in.ct) = n;
%        end
%      end
%    end
%    
%    
%    for i = 1:A_in.ct
%      A_norm = A_in.footprint(:,:,i)/sum(sum(A_in.footprint(:,:,i)));
%      A_in.centroid(i,:) = [sum((1:d1)*A_norm),sum(A_norm*(1:d2)')];
%    end
%    
%    
%    
%    Y = single(Y(extents(1,1):extents(1,2),extents(2,1):extents(2,2),:));
%    [d1,d2,T] = size(Y);                            % dimensions of dataset
%    d = d1*d2;                                      % total number of pixels
%    
%    Cn = correlation_image(Y); % image statistic (only for display purposes)
  
  
%%% ------------------------------- CNMF ------------------------------------
  
  [d1,d2,T] = size(Y);                            % dimensions of dataset
  d = d1*d2;                                      % total number of pixels
  
  %% Set parameters
  p = 0;
  options = CNMFSetParms(...   
      'd1',d1,'d2',d2,...                         % dimensionality of the FOV
      'p',p,...                                   % order of AR dynamics
      'merge_thr',0.80,...                        % merging threshold  
      'nb',2,...                                  % number of background components    
      'min_SNR',3,...                             % minimum SNR threshold
      'space_thresh',0.5,...                      % space correlation threshold
      'cnn_thr',0.2,...                            % threshold for CNN classifier
      'flag_g',1);
  options.min_fitness = -50;
  
  %% Data pre-processing
  [P,Y] = preprocess_data(Y,p);
  
  %% fast initialization of spatial components using greedyROI and HALS
  [A_CNMF,C_out,b_out,f_out,center] = initialize_components_fill(Y,A_in,options,P);  % initialize
  
  Yr = reshape(Y,d,T);
  
  %% update spatial components
  [A_CNMF,b_out,C_out] = update_spatial_components(Yr,C_out,f_out,[A_CNMF,b_out],P,options);
    
  %% update temporal components
%    P.p = 0;    % set AR temporarily to zero for speed
  [C_out,f_out,P,S,YrA] = update_temporal_components(Yr,A_CNMF,b_out,C_out,f_out,P,options);
  
  
%%% -------------------------------- prepare output ------------------------------------
  
%    pathCa = pathcat(path.mouse,sprintf('Session%02d',s),'CaData.mat');
%    ld_Ca = load(pathCa);
  
  ROI_out(sum(A_in.status)) = struct('A',zeros(h.data.imSize(1),h.data.imSize(2)),'norm',NaN,'centroid',[],'fitness',NaN,'C',[],'S',[]);
  for i = 1:sum(A_in.status)
    ROI_out(i).A = sparse(h.data.imSize(1),h.data.imSize(2));
    ROI_out(i).A(A_in.extents(1,1):A_in.extents(1,2),A_in.extents(2,1):A_in.extents(2,2)) = reshape(A_CNMF(:,i),d1,d2);
    ROI_out(i).norm = norm(ROI_out(i).A(:));
    A_tmp = ROI_out(i).A/sum(ROI_out(i).A(:));
    ROI_out(i).centroid = [sum((1:h.data.imSize(1))*A_tmp),sum(A_tmp*(1:h.data.imSize(2))')];
    
    ROI_out(i).fitness = compute_event_exceptionality(C_out(i,:)+YrA(i,:),options.N_samples_exc,options.robust_std);
    
    [ROI_out(i).C, ROI_out(i).S] = deconvolveCa(C_out(i,:));
  end
  
%    query_manipulate(path,s,Cn,manipulate,A_in,ROI_out)
  
end
  
%%% ------------------------------- plotting ------------------------------
  
%  function query_manipulate(path,s,Cn,manipulate,A_in,ROI_out)
%  
%    footprints = getappdata(0,'footprints');
%    % s
%    
%    pathCa = pathcat(path.mouse,sprintf('Session%02d',s),'CaData.mat');
%    ld_Ca = load(pathCa);
%    
%    f = figure('position',[100 100 1200 900]);
%    
%    Ca_button_accept = uicontrol(f,'Style','pushbutton',...
%                                    'String','Accept',...
%                                    'Units','normalized','Position',[0.6 0.05 0.2 0.05],'Callback',@h.accept_manipulation);
%            
%    Ca_button_refuse = uicontrol(f,'Style','pushbutton',...
%                                    'String','Refuse',...
%                                    'Units','normalized','Position',[0.2 0.05 0.2 0.05],'Callback',@h.refuse_manipulation);
%    
%    ax_pre = subplot(2,2,1);
%    ax_post = subplot(2,2,2);
%    
%    ax_Ca_pre = subplot(4,1,3);
%    ax_Ca_post = subplot(4,1,4);
%    
%    hold(ax_pre,'on')
%    hold(ax_Ca_pre,'on')
%    imagesc(ax_pre,Cn)
%    ax_pre.CLim = [0.5,1];
%    
%    for i = 1:size(manipulate.pre.ID,1)
%      n_pre = manipulate.pre.ID(i,2);
%      A_pre = full(footprints.session(s).ROI(n_pre).A(A_in.extents(1,1):A_in.extents(1,2),A_in.extents(2,1):A_in.extents(2,2)));
%      contour(ax_pre,A_pre,'b')
%      C_tmp = ld_Ca.C2(n_pre,:);
%      C_tmp = C_tmp/max(C_tmp);
%      plot(ax_Ca_pre,(i-1)+C_tmp,'b')
%    end
%    
%    for i=1:A_in.ct
%      if A_in.status(i)
%        col = 'r';
%      else
%        col = 'g';
%      end
%      contour(ax_pre,A_in.footprint(:,:,i),col)
%    end
%    hold(ax_pre,'off')
%    hold(ax_Ca_pre,'off')
%    
%    hold(ax_post,'on')
%    hold(ax_Ca_post,'on')
%    imagesc(ax_post,Cn)
%    ax_post.CLim = [0.5,1];
%    for i=1:length(ROI_out)
%      contour(ax_post,ROI_out(i).A(A_in.extents(1,1):A_in.extents(1,2),A_in.extents(2,1):A_in.extents(2,2)),'r')
%    
%      C_tmp = ROI_out(i).C;
%      C_tmp = C_tmp/max(C_tmp);
%      plot(ax_Ca_post,(i-1)+C_tmp,'r')
%    end
%    hold(ax_post,'off')
%    hold(ax_Ca_post,'off')
%  end
