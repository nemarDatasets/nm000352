function fhnoisy_chanfig(subject, chan,clims)

load(['data/' subject '/fhnchans/' subject '_cls_out']) 
load(['data/' subject '/fhnchans/' subject '_' num2str(chan) '_fhnnlevs'])

if subject == 'mv'
    bb_proj([213 378 435 ])=0;
    erp_proj([435])=0;
end
%% set generic figure properties, and initialize figure

    scrsz = get(0,'ScreenSize');

    if fhtype==2,  figtitle=[subject ' channel ' num2str(chan) ', face specific'];
    elseif fhtype==1, figtitle=[subject ' channel ' num2str(chan) ', house specific']; end

    figure('Position',[.05*scrsz(3) 1 .9*scrsz(3) .9*scrsz(4)],'Name',figtitle,'NumberTitle','off')
    subplot('position',[.4 .99 .3 .01]), axis off, text(0,0,figtitle)
    
%% Event-related averages, localizer task

    subplot('position',[.03 .785 .18 .18])
    plot(erbb(:,1),'r'), hold on, plot(erbb(:,2),'b')
    box off,set(gca,'ytick',0),set(gca,'xlim',[0 600])
    set(gca,'xticklabel',[])
    
    subplot('position',[.03 .58 .18 .18])
    plot(erp(:,1),'r'), hold on, plot(erp(:,2),'b')
    box off,set(gca,'ytick',0),set(gca,'xlim',[0 600]), xlabel('Time (ms)') 
    
%% response time vs latency or response magnitude (if face specific electrode)
      
    if fhtype==2
        
        load(['data/' subject '/fhnchans/' subject '_' num2str(chan) '_fhnchan'],'bb_proj','bb_time','kp','rt','tr_fh')
        kp_tp=kp(:,1).*(tr_fh==2); % true positive = keystrokes that were on face trials 
        rttp0=rt(find(kp_tp)); rttp0(isnan(rttp0))=[];
        bbtp=bb_proj(find(kp_tp)); bbtp(isnan(rttp0))=[];
        bltp=bb_time(find(kp_tp)); bltp(isnan(rttp0))=[];
        
        subplot('position',[.4 .785 .15 .18])
        plot(rttp0,bltp,'.')
        axis tight, set(gca,'xticklabel',[]), ylabel('BB latency (ms)')
        box off,% a=get(gca,'ylim'); text(5,.95*a(2),'RespTimes','FontSize',8)
        
        subplot('position',[.4 .58 .15 .18])
        plot(rttp0,bbtp,'.')
        axis tight, xlabel('response time (ms)'), ylabel('BB mag')
        box off,% a=get(gca,'ylim'); text(5,.95*a(2),'RespTimes','FontSize',8)
    end
%% precision, accuracy, and dprime of behavior (keypress)
 
%     subplot('position',[.35 .55 .15 .21])
%     plot(mean(nlevs.'),kp_pre,'m-o')
%     hold on, plot(mean(nlevs.'),kp_acc,'-o','color',[.8 .3 .3]) 
%     box off, set(gca,'xtick',[nlevs(:,1).' 100])
%     ylabel('precision or accuracy')
%     a=legend('prec','accu'); set(a,'Fontsize',8)
% 
%  
%     subplot('position',[.35 .765 .15 .21])
%     plot(mean(nlevs.'),kp_dpr,'-o','color',[.3 .3 .3]) 
%     box off, set(gca,'xtick',[nlevs(:,1).' 100],'xticklabel',[])
%     ylabel('d-prime') 
%     a=get(gca,'ylim'); text(3,.95*a(2),'Pt performance','FontSize',8)
    
%% precision, accuracy, and dprime of machine learning decoder

%     subplot('position',[.55 .55 .15 .21])
%     plot(mean(nlevs.'),br_pre,'m-o')
%     hold on, plot(mean(nlevs.'),br_acc,'-o','color',[.8 .3 .3]) 
%     box off, set(gca,'xtick',[nlevs(:,1).' 100])
%     ylabel('precision or accuracy')
%     a=legend('prec','accu'); set(a,'Fontsize',8)
% 
%     subplot('position',[.55 .765 .15 .21])
%     plot(mean(nlevs.'),br_dpr,'-o','color',[.3 .3 .3]) 
%     box off, set(gca,'xtick',[nlevs(:,1).' 100],'xticklabel',[])
%     ylabel('d-prime') 
%     a=get(gca,'ylim'); text(3,.95*a(2),'Decoder performance','FontSize',8)
        
%% plot brains with electrode positions
    load(['locs/' subject '_xslocs'])
    load(['data/' subject '/' subject '_erp_erbb'],'chan_lbls')
    locs=locs(chan_lbls,:); elcode=elcode(chan_lbls);

    % convert from mni to indices
    locs=mni2vox(locs,subject);

    % load MR
    mrStruct=spm_vol([cd '/brains/' subject '/' subject '_mri.nii']); % get the mri 
    mrmat=spm_read_vols(mrStruct); % from structure to data matrix and xyz matrix (voxel coordinates)
    
    % transpose elements - best guess
    [a,b]=max(abs(round(mrStruct.mat(1:3,1:3))),[],1);
    mrmat=permute(mrmat,b);
    locs=locs(:,b);

    % convert to appropriate orientation
    mrmat=mrmat(:,end:-1:1,:);
    locs(:,2)=size(mrmat,2)-locs(:,2);
        
    %% plot cross section and add electrodes - centered on electrode of interest
    subplot('position',[.75 .55 .23 .4])
    imagesc(squeeze(mrmat(:,:,locs(chan,3))')), colormap('gray')
    axis tight, axis equal, axis off, 
    set(gca,'clim',clims)
    hold on, plot(locs(:,1),locs(:,2),'.','color',.99*[1 1 1]), hold on, plot(locs(chan,1),locs(chan,2),'r.') 
    


%% averaged traces by type and coherence

    if fhtype==2 % face traces
        %erp
        subplot('position',[.03 .05 .3 .22])
        plot(ftraces_Vo), box off, set(gca,'ytick',[0 1]),xlabel('Time (ms)')
        a=get(gca,'ylim'); text(10,.8*a(2),'ERP','FontSize',8) 
        %bb
        subplot('position',[.03 .3 .3 .22])
        plot(ftraces_BB), 
        box off, set(gca,'xticklabel',[],'ytick',[0 1])
        a=get(gca,'ylim'); %set(gca,'ylim', [min([0 1.1*a(1)]) max([a(2) 1.1*a(2)])])
        text(10,.8*a(2),'ERBB','FontSize',8)
    elseif fhtype==1 % house traces
        %erp
        subplot('position',[.03 .05 .3 .22])
        plot(htraces_Vo),box off, set(gca,'ytick',[0 1]),xlabel('Time (ms)')
            a=get(gca,'ylim'); text(10,.8*a(2),'ERP','FontSize',8)
        %bb
        subplot('position',[.03 .3 .3 .22]),
        plot(htraces_BB), box off, set(gca,'xticklabel',[],'ytick',[0 1])
            a=get(gca,'ylim'); text(10,.8*a(2),'ERBB','FontSize',8)
    end

    legend(num2str(nlevs))



%% plot averaged projections


    %erp
    subplot('position',[.35 .05 .15 .22])
    kjm_onlyerrbar(mean(nlevs.'),ferp_means,ferp_sems), hold on
    kjm_onlyerrbar(mean(nlevs.'),herp_means,herp_sems), hold on
    plot(mean(nlevs.'),ferp_means,'bo'), hold on
    plot(mean(nlevs.'),herp_means,'ro'), hold on
    box off, set(gca,'ytick',[],'xtick',[nlevs(:,1).' 100])
    a=get(gca,'ylim'); text(30,.95*a(2),'ERP proj, F and H','FontSize',8)
    

    %bb
    subplot('position',[.35 .3 .15 .22])
    kjm_onlyerrbar(mean(nlevs.'),fbb_means,fbb_sems), hold on
    kjm_onlyerrbar(mean(nlevs.'),hbb_means,hbb_sems), hold on
    plot(mean(nlevs.'),fbb_means,'bo'), hold on
    plot(mean(nlevs.'),hbb_means,'ro'), hold on
    box off, set(gca,'ytick',[],'xtick',[nlevs(:,1).' 100],'xticklabel',[])
    a=get(gca,'ylim'); text(30,.95*a(2),'BB proj, F and H','FontSize',8)

    
    subplot('position',[.34 .1 .01 .4]), axis off, 
    text(0,0,'cortical response magnitudes','Rotation',90)
    
% legend('Face','House')


    

%% plot cortical response magnitudes, sorted by keypress


if fhtype==2 % only analyze face physiology in face electrodes

    subplot('position',[.52 .05 .12 .22])
    kjm_errbar_grps([ferp_tp_means; ferp_fn_means],[ferp_tp_sems; ferp_fn_sems],[ferp_tp_sems; ferp_fn_sems])
    set(gca,'xtick',1:length(ferp_tp_means),'xticklabel',num2str(nlevs(:,1)),'ytick',[],'xlim',[.5 length(ferp_tp_means)+1])
    a=get(gca,'ylim'); text(1,.95*a(2),'face ERP proj, TP and FN','FontSize',8)
   
    subplot('position',[.52 .3 .12 .22])
    kjm_errbar_grps([fbb_tp_means; fbb_fn_means],[fbb_tp_sems; fbb_fn_sems],[fbb_tp_sems; fbb_fn_sems])
    set(gca,'xtick',1:length(fbb_tp_means),'xticklabel',num2str(nlevs(:,1)),'ytick',[],'xlim',[.5 length(ferp_tp_means)+1])
    a=get(gca,'ylim'); text(1,.95*a(2),'face BB proj, TP and FN','FontSize',8)
   

    
elseif fhtype==1 % only analyze house physiology in house electrodes

    subplot('position',[.52 .05 .12 .22])
    kjm_errbar_grps([herp_tn_means; herp_fp_means],[herp_tn_sems; herp_fp_sems],[herp_tn_sems; herp_fp_sems])
    set(gca,'xtick',1:length(herp_tn_means),'xticklabel',num2str(nlevs(:,1)),'ytick',[],'xlim',[.5 length(herp_tn_means)+1])
    a=get(gca,'ylim'); text(1,.95*a(2),'house ERP proj, TN and FP','FontSize',8)
   
    subplot('position',[.52 .3 .12 .22])
    kjm_errbar_grps([hbb_tn_means; hbb_fp_means],[hbb_tn_sems; hbb_fp_sems],[hbb_tn_sems; hbb_fp_sems])
    set(gca,'xtick',1:length(hbb_tn_means),'xticklabel',num2str(nlevs(:,1)),'ytick',[],'xlim',[.5 length(herp_tn_means)+1])
    a=get(gca,'ylim'); text(1,.95*a(2),'house BB proj, TN and FP','FontSize',8)
   

    
end
    

%% plot averaged latencies

    %erp
    subplot('position',[.69 .05 .15 .22])
    if fhtype==2
        kjm_onlyerrbar(mean(nlevs.'),ferp_tmeans,ferp_tsems), hold on
        plot(mean(nlevs.'),ferp_tmeans,'bo'), hold on
    elseif fhtype==1
        kjm_onlyerrbar(mean(nlevs.'),herp_tmeans,herp_tsems), hold on
        plot(mean(nlevs.'),herp_tmeans,'ro'), hold on
    end
    box off, set(gca,'xtick',[nlevs(:,1).' 100])
    a=get(gca,'ylim'); text(5,.95*a(2),'ERP projection','FontSize',8)


    %bb
    subplot('position',[.69 .3 .15 .22])
    if fhtype==2
        kjm_onlyerrbar(mean(nlevs.'),fbb_tmeans,fbb_tsems), hold on
        plot(mean(nlevs.'),fbb_tmeans,'bo'), hold on
    elseif fhtype==1
        kjm_onlyerrbar(mean(nlevs.'),hbb_tmeans,hbb_tsems), hold on
        plot(mean(nlevs.'),hbb_tmeans,'ro'), hold on
    end
    box off, set(gca,'xtick',[nlevs(:,1).' 100],'xticklabel',[])
    a=get(gca,'ylim'); text(5,.95*a(2),'BB projection','FontSize',8)

    subplot('position',[.66 .1 .01 .4]), axis off, 
    text(0,0,'Cortical response delays (ms)','Rotation',90)


%% plot cortical response latencies, sorted by keypress


if fhtype==2 % only analyze face physiology in face electrodes

    subplot('position',[.87 .05 .12 .22])
    kjm_errbar_grps([ferp_tp_tmeans; ferp_fn_tmeans],[ferp_tp_tsems; ferp_fn_tsems],[ferp_tp_tsems; ferp_fn_tsems])
    set(gca,'xtick',1:length(ferp_tp_tmeans),'xticklabel',num2str(nlevs(:,1)),'xlim',[.5 length(ferp_tp_tmeans)+1])
    a=get(gca,'ylim'); text(1,.95*a(2),'face ERPdelay, TP and FN','FontSize',8)
   
    subplot('position',[.87 .3 .12 .22])
    kjm_errbar_grps([fbb_tp_tmeans; fbb_fn_tmeans],[fbb_tp_tsems; fbb_fn_tsems],[fbb_tp_tsems; fbb_fn_tsems])
    set(gca,'xtick',1:length(fbb_tp_tmeans),'xticklabel',num2str(nlevs(:,1)),'xlim',[.5 length(ferp_tp_tmeans)+1])
    a=get(gca,'ylim'); text(1,.95*a(2),'face BBdelay, TP and FN','FontSize',8)
   

    
elseif fhtype==1 % only analyze house physiology in house electrodes

    subplot('position',[.87 .05 .12 .22])
    kjm_errbar_grps([herp_tn_tmeans; herp_fp_tmeans],[herp_tn_tsems; herp_fp_tsems],[herp_tn_tsems; herp_fp_tsems])
    set(gca,'xtick',1:length(herp_tn_tmeans),'xticklabel',num2str(nlevs(:,1)),'xlim',[.5 length(herp_tn_tmeans)+1])
    a=get(gca,'ylim'); text(1,.95*a(2),'house ERPdelay, TN and FP','FontSize',8)
   
    subplot('position',[.87 .3 .12 .22])
    kjm_errbar_grps([hbb_tn_tmeans; hbb_fp_tmeans],[hbb_tn_tsems; hbb_fp_tsems],[hbb_tn_tsems; hbb_fp_tsems])
    set(gca,'xtick',1:length(hbb_tn_tmeans),'xticklabel',num2str(nlevs(:,1)),'xlim',[.5 length(herp_tn_tmeans)+1])
    a=get(gca,'ylim'); text(1,.95*a(2),'house BBdelay, TN and FP','FontSize',8)
   

    
end



%%
kjm_printfig(['figs/' subject '/' subject '_fhnoisy_ch_' num2str(chan)],[20 12])
%     

    
%%         subplot('position',[.15 .95-q*.2 .8 .18])
% 
%         kjm_imagesc(-199:600,1:k,bb_rs.'),box off, colormap(cm), set(gca,'xtick',[],'ytick',[])
%         set(gca,'clim',3*[-1 1])
%         colormap(cm)
%         ylabel([clbls{q} ' trials'])
%         colorbar
% 
%     set(gca,'xtick',[0 200 400])
%     xlabel('time (ms)')
%     subplot('position',[.15 .96 .01 .01]),axis off
%     text(0,0,[subject ' - electrode ' num2str(chan_lbls(chan)) ', ' area_lbls{elcode(chan_lbls(chan))} ])
%     set(gcf,'color','w')    
% 
%     subplot('position',[.05 .5 .01 .01]),axis off, 
%     h=text(0,0,['Broadband amplitude timecourse']); 
%         set(h,'Rotation',90),set(h,'HorizontalAlignment','center'), 
% 
%     kjm_printfig(['figs/' subject '/' subject '_fhrep_ch_' num2str(chan_lbls(chan)) '_rasters'],[9 9])
%     
    
    


