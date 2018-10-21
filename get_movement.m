

function [movement] = get_movement(clusters,footprints,data)
    
    
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
    
    figure('position',[200 200 1500 1200]);
    hold on
    mv_field = quiver(movement.centr(:,1,1),movement.centr(:,1,2),movement.d_centr(:,1,1),movement.d_centr(:,1,2),'k');
    mv_field_old = quiver(movement.centr(:,1,1),movement.centr(:,1,2),movement.d_centr(:,1,1),movement.d_centr(:,1,2),'r');
    
    xlim([0,512])
    ylim([0,512])
    
    s = 1
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