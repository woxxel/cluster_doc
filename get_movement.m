

function [movement] = get_movement(clusters,footprints,data,animation,pathMouse)
    
    
    movement = struct('d_centr',zeros(data.nCluster,data.nSes,2)*NaN,'centr',zeros(data.nCluster,data.nSes,2)*NaN);
    
    for c = 1:data.nCluster
%          if data.ct(c) == 15
            centr_ref = [];
            s_ref = 1;
            
            for s = 1:data.nSes
                
                n = clusters(c).session(s).list;
                if ~isempty(n)
                    movement.centr(c,s,:) = footprints.session(s).centroids(n,:);
                    
                    if ~isempty(centr_ref)
                        movement.d_centr(c,s,:) = movement.centr(c,s,:) - centr_ref;
                    end
                        
                    centr_ref = movement.centr(c,s,:);
                    s_ref = s;
                end
            end
%          end
    end
    
    figure('position',[200 200 900 700]);
    hold on
    
    
    xlim([0,512])
    ylim([0,512])
    
    if animation
        mv_field = quiver(movement.centr(:,1,1),movement.centr(:,1,2),movement.d_centr(:,1,1),movement.d_centr(:,1,2),'k');
        mv_field_old = quiver(movement.centr(:,1,1),movement.centr(:,1,2),movement.d_centr(:,1,1),movement.d_centr(:,1,2),'r');
        s=1;
        while true
            mean_movement = nanmean(squeeze(movement.d_centr(:,s,:)));
            pause(0.5)
            if s < 15
                set(mv_field,'xdata',movement.centr(:,s,2),'ydata',movement.centr(:,s,1),'udata',movement.d_centr(:,s+1,2),'vdata',movement.d_centr(:,s+1,1))
            end
            if s>1
                set(mv_field_old,'xdata',movement.centr(:,s-1,2),'ydata',movement.centr(:,s-1,1),'udata',movement.d_centr(:,s,2),'vdata',movement.d_centr(:,s,1))
            end
            s = mod(s,15)+1;
        end
    else
    
        centr_start = zeros(data.nCluster,2);
        for c = 1:data.nCluster
            for s = 1:data.nSes
                if length(clusters(c).session(s).list)
                    centr_start(c,:) = footprints.session(s).centroids(clusters(c).session(s).list(1),:);
                    break
                end
            end
        end
        quiver(centr_start(:,1),centr_start(:,2),nansum(movement.d_centr(:,:,1),2),nansum(movement.d_centr(:,:,2),2),'k');
        
        pathSv = pathcat(pathMouse,'Figures/ROI_movement.mat')
        print(pathSv,'-dpng','-r300')
    end
    
    
end


%  idxes = find(data.ct == 15);
%  for i = idxes'
%  close all
%  hold on
%  plot(movement.d_centr(i,:,2))
%  plot(movement.d_centr(i,:,1))
%  plot([0,15],[0,0],'k--')
%  hold off
%  ylim([-10,10])
%  waitforbuttonpress
%  end
%  
%  now, do linear (or partwise linear?) regression to obtain overall movement