function make_indsub_rhy_fig(subject)
% function make_indsub_rhy_fig(subject)
% Note: this function requires use of the ctmr package - it should be in your analysis pathway
% there are also some add-ons that will be needed, they are in the folder ctmr_addons

addpath ctmr_addons

% multcompcorr = 'y';
multcompcorr = 'n';

%%
    switch subject %viewing angle
        case 'bp'; vth=250; vph=15;
        case 'cc'; vth=80; vph=35;     
        case 'hl'; vth=270; vph=10;            
        case 'jc'; vth=270; vph=30;            
        case 'jm'; vth=270; vph=30;            
        case 'jp'; vth=270; vph=30;
        case 'ug'; vth=90; vph=20;            
        case 'wc'; vth=280; vph=35;
        case 'wm'; vth=100; vph=35;
        case 'zt'; vth=270; vph=15;    
    end
    
%%
    load(['data/' subject '/' subject '_fband_4_8'],'mod_blocks','dz_dist'), 
        [h, pdz_th]=ttest(dz_dist);
        mb_th=mean(mod_blocks,1);    
        
    load(['data/' subject '/' subject '_fband_12_20'],'mod_blocks','dz_dist'), 
        [h, pdz_bt]=ttest(dz_dist);
        mb_bt=mean(mod_blocks,1);  
    
    load(['data/' subject '/' subject '_base'],'brain','locs', 'el_codes'), 

%% make brain plots with dots


% text position
tx=max(brain.vert(:,1));
ty=max(brain.vert(:,2));
tz=.95*max(brain.vert(:,3));

% correct for multiple comparisons?
if multcompcorr == 'y'
    bfcorrect = .05/num_chans;
else
    bfcorrect = 1;
end

%%
figure, % note that they are thresholded by bonferron sign.

    % coupling theta
    subplot('position',[0  0 .32 .8]), 
    ph_dot_surf_view(brain,locs,mb_th,vth,vph);
%     text(tx,ty,tz,['Th ' num2str(max(abs(mb_th)))])
    title(['Th ' num2str(max(abs(mb_th)))])
    
    % coupling beta
    subplot('position',[0.33  0 .32 .8]), 
    ph_dot_surf_view(brain,locs,mb_bt,vth,vph);
%     text(tx,ty,tz,['Bt ' num2str(max(abs(mb_bt)))]) 
    title(['Bt ' num2str(max(abs(mb_bt)))]) 
    
    % anatomic classification
    msize=30;
    subplot('position',[0.66  0 .32 .8]),     
        ctmr_gauss_plot(brain,[0 0 0],0)
        el_add_popout(locs(el_codes(:,2)==0,:),.85*[1 1 1],msize,vth,vph) % undetermined
        el_add_popout(locs(el_codes(:,2)==1,:),'b',msize,vth,vph) % M1
        el_add_popout(locs(el_codes(:,2)==2,:),.85*[1 1 1],msize,vth,vph) % M/S
        el_add_popout(locs(el_codes(:,2)==3,:),'g',msize,vth,vph) % S1
        el_add_popout(locs(el_codes(:,2)==4,:),'y',msize,vth,vph) % ventral M/S
        el_add_popout(locs(el_codes(:,2)==5,:),.85*[1 1 1],msize,vth,vph) % foot
        el_add_popout(locs(el_codes(:,2)==6,:),'r',msize,vth,vph) % frontal
        el_add_popout(locs(el_codes(:,2)==7,:),'m',msize,vth,vph) % parietal
        el_add_popout(locs(el_codes(:,2)==8,:),'k',msize,vth,vph) % temporal
        el_add_popout(locs(el_codes(:,2)==9,:),.85*[1 1 1],msize,vth,vph) % occipital   
        loc_view(vth,vph)
        
    title(subject)
        
    dg_figfix
    
    exportfig(gcf,['figs/' subject '_indrhy'], 'format', 'png', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 300, 'Width', 20, 'Height', 7);    
    
    
    
    
    