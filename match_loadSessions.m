

function footprints = match_loadSessions(pathMouse,nSes)
    
    savePath = pathcat(pathMouse,'footprints.mat');
    
    if ~exist(savePath,'file')
      tic
      pathSessions = dir(pathcat(pathMouse,'Session*'));
      if nargin ==2 && ~isempty(nSes)
        pathSessions = pathSessions(1:nSes);
      else
        nSes = length(pathSessions);
      end
      
      border_prox_thr = 3;
      rot_max = 1;
      rot = linspace(-rot_max,rot_max,10*rot_max+1);
      
  %      mask(nSes) = struct('mask',[]);
      
      path_bg = pathcat(pathMouse,pathSessions(1).name,'reduced_MF1_LK1.mat');
      loadDat0 = load(path_bg,'max_im');
      bg_ref = loadDat0.max_im;
      
      footprints = struct('session',struct);
      footprints.data = struct('session',struct,'nSes',nSes);
      footprints.data.imSize = size(bg_ref);
      
      rm_ct = 0;
      nROIs = 0;
      
      %% register all sessions
      for s = 1:footprints.data.nSes
        
        disp(sprintf('loading %s',pathSessions(s).name))
        
        %% loading data
        path_ROI = pathcat(pathMouse,pathSessions(s).name,'resultsCNMF_MF1_LK1.mat');
        loadDat = load(path_ROI,'A2');
        
        nROI = size(loadDat.A2,2);
        mask = false(nROI,1);
        %% preparing structure
        
        footprints.session(s).ROI = struct('A',[],'centroid',cell(nROI,1),'norm',[]);
        footprints.session(s).centroids = zeros(nROI,2);
        
        A_tmp = reshape(full(loadDat.A2),footprints.data.imSize(1),footprints.data.imSize(2),nROI);
        
        if s == 1
          
          footprints.data.session(s).shift = [0,0,0];
          footprints.data.session(s).rotation = 0;
          
        else
          
          path_bg = pathcat(pathMouse,pathSessions(s).name,'reduced_MF1_LK1.mat');
          loadDat = load(path_bg,'max_im');
          bg_tmp = loadDat.max_im;
          
          max_C = 0;
          rot_tmp = -rot_max;
          for r = rot
            bg_rot = imrotate(bg_tmp,r,'crop');
            C = fftshift(real(ifft2(fft2(bg_ref).*fft2(rot90(bg_rot,2)))));
            if max(C(:)) > max_C;
              max_C = max(C(:));
              rot_tmp = r;
              [ind_y,ind_x] = find(C == max_C);
            elseif max(C(:)) == max_C;
              rot_tmp = [rot_tmp r];
              disp('same')
            end
            [ind_y_tmp,ind_x_tmp] = find(C == max(C(:)));
  %            disp(sprintf('max: %5.3g, rot: %5.3g, x/y: %d/%d',max(C(:)),r,(floor(footprints.data.imSize(1)/2) - ind_y_tmp),(floor(footprints.data.imSize(2)/2) - ind_x_tmp)))
          end
          %% need to adjust for possibly different shifts as well!
          disp(sprintf('final shift: rot: %5.3g, x/y: %d/%d',rot_tmp,(floor(footprints.data.imSize(1)/2) - ind_y),(floor(footprints.data.imSize(2)/2) - ind_x)))
          rot_tmp = mean(rot_tmp);
          
          %% imtranslate takes [x,y,z] vector
          footprints.data.session(s).shift(3) = 0;
          footprints.data.session(s).shift(2) = floor(footprints.data.imSize(1)/2) - ind_y;
          footprints.data.session(s).shift(1) = floor(footprints.data.imSize(2)/2) - ind_x;
          footprints.data.session(s).rotation = rot_tmp;
          
          A_tmp = imtranslate(A_tmp,-footprints.data.session(s).shift(:));
          if footprints.data.session(s).rotation ~= 0
            A_tmp = imrotate(A_tmp,footprints.data.session(s).rotation,'crop');
          end
        end
        
        for n=1:nROI
          footprints.session(s).ROI(n).A = sparse(A_tmp(:,:,n));
          
          A_tmp_norm = sparse(footprints.session(s).ROI(n).A/sum(footprints.session(s).ROI(n).A(:)));
          footprints.session(s).ROI(n).centroid = [sum((1:footprints.data.imSize(1))*A_tmp_norm),sum(A_tmp_norm*(1:footprints.data.imSize(2))')];
          footprints.session(s).ROI(n).norm = norm(footprints.session(s).ROI(n).A(:));
          footprints.session(s).centroids(n,:) = footprints.session(s).ROI(n).centroid;
          
          x_pos = footprints.session(s).ROI(n).centroid(2)+footprints.data.session(s).shift(1);
          y_pos = footprints.session(s).ROI(n).centroid(1)+footprints.data.session(s).shift(2);
          
          border_prox = min(min(y_pos-1,footprints.data.imSize(1)-y_pos),min(x_pos-1,footprints.data.imSize(2)-x_pos));
          mask(n) = (border_prox < border_prox_thr);
        end
        
        footprints.session(s).ROI(mask) = [];
        footprints.session(s).centroids(mask,:) = [];
        
        rm_ct = rm_ct + nnz(mask);
        footprints.data.session(s).nROI = nnz(~mask);
        nROIs = nROIs + footprints.data.session(s).nROI;
        
        
        saveCaPath = pathcat(pathMouse,pathSessions(s).name,'CaData.mat');
%          if ~exist(saveCaPath,'file')
        load(path_ROI,'C2')
        C2(mask,:) = [];
%          S2(mask,:) = [];
        save(saveCaPath,'C2','-v7.3')
        disp(sprintf('saved CaData @ %s',saveCaPath))
        clear C2
        clear S2
%          end
        
      end
      
      disp(sprintf('removed %d ROIs due to border proximity',rm_ct))
      disp(sprintf('loading of %d ROIs done',nROIs))
      toc
      
      save(savePath,'footprints','-v7.3')
      disp(sprintf('saved data @ %s',savePath))
    else
      load(savePath);
    end
end
