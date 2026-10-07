% function vis_make_elec_fig


%% load generals, add paths, etc
load dg_colormap
% load loc_colormap

%% 
bands=[[4 8];[8 12];[12 20]];

bcol=[[0 0 1];[0 1 0];[1 0 0];[.5 .5 0];[.5 .5 .5]]; %colors for different classes

sf=.0298; %scalefactor from amp units to microvolts

%% find isi and visual stim indices
    [a,b]=max(abs(diff(pts(:,2))));
    %
    vis_ind=find(pts(:,3)>0&pts(:,3)<5); % middle of stimulus presentation
    isi_ind=find(pts(:,3)==5); % middle of isi period
    %
    vis_ind(vis_ind<b)=[];
    isi_ind(isi_ind<b)=[];



%% make dynamic spectrum mesh plot
subplot('position',[.07 .7 .63 .2])

ds=squeeze(dyn_spec(:,:,chan));
for k=1:200
    ds(:,k)=ds(:,k)/mean(ds([1:1000 3001:4000],k));
end


kjm_imagesc(-999:3000,0:50:200,ds)
colormap(cm)

if mean(std(ds,1))>.15
    set(gca,'clim',[0 2]),
    text(2000,20,'0 to 200%','FontSize',8)
    %title([subject ' , electrode' num2str(chan) ', colorscale - 0 to 200%'])
else 
    set(gca,'clim',[.5 1.5]), 
    text(2000,20,'50 to 150%','FontSize',8)
%     title([subject ' , electrode' num2str(chan) ', colorscale - 50 to 150%'])    
end
% ylabel('Time from stimulus onset (ms)')
ylabel('Frequency (Hz)')

set(gca,'ytick',[ 50 100 150 200]), set(gca,'yticklabel',[150 100 50 0])
set(gca,'xtick',[])

box off

vis_figfix


%% stimulus-triggered average potential


subplot('position',[.07 .6 .63 .1])
hold on, plot([-999:3000],sf*mean(squeeze(st_data(:,chan,find(stim(ns)==1))),2),'color',bcol(1,:))
hold on, plot([-999:3000],sf*mean(squeeze(st_data(:,chan,find(stim(ns)==2))),2),'color',bcol(2,:))
hold on, plot([-999:3000],sf*mean(squeeze(st_data(:,chan,find(stim(ns)==3))),2),'color',bcol(3,:))
hold on, plot([-999:3000],sf*mean(squeeze(st_data(:,chan,find(stim(ns)==4))),2),'color',bcol(4,:))
axis tight
a=get(gca,'ylim');
set(gca,'ylim', [min([0 1.1*a(1)]) max([a(2) 1.1*a(2)])])
set(gca,'ytick',10*[ceil(.8*a(1)/10) floor(.8*a(2)/10)])
ylabel('\mu V')
text(2000,.8*a(2),'E.R.P.','FontSize',8)
set(gca,'xtick',1000*[ 0 1 2])
xlabel('Time from stimulus onset (ms)')
vis_figfix
%% stimulus triggered average broadband

subplot('position',[.07 .9 .63 .1])
hold on, plot([-999:3000],mean(squeeze(st_bbs(:,chan,find(stim(ns)==1))),2),'color',bcol(1,:))
hold on, plot([-999:3000],mean(squeeze(st_bbs(:,chan,find(stim(ns)==2))),2),'color',bcol(2,:))
hold on, plot([-999:3000],mean(squeeze(st_bbs(:,chan,find(stim(ns)==3))),2),'color',bcol(3,:))
hold on, plot([-999:3000],mean(squeeze(st_bbs(:,chan,find(stim(ns)==4))),2),'color',bcol(4,:))
axis tight
a=get(gca,'ylim');
set(gca,'ylim', [min([0 1.1*a(1)]) max([a(2) 1.1*a(2)])])
set(gca,'xtick',[])
set(gca,'ytick',[min([ceil(a(1)) floor(.8*a(2))-1]) floor(.8*a(2))])
ylabel('N.U.')
text(2000,.8*a(2),'E.R.BB.','FontSize',8)
vis_figfix

%% phase-amp pallette
pm=squeeze(pac_matrix(:,:,chan));
subplot('position',[.78 .6 .2 .33])

kjm_imagesc(bin_centers,0:10:50,pm')
cscale=max(max(abs(squeeze(pac_matrix(50:-1:5,:,chan)))));
set(gca,'clim', cscale*[-1 1]),
colormap(cm), 
loc_view(0,90)
set(gca,'ytick',[0:10:40])
box off
set(gca,'xtick',max(bin_centers)*[-1:1]),set(gca,'xticklabel',{'- pi','0','pi'}), box off
axis tight
xlabel('Phase of rhythm')
ylabel('Frequency of rhythm')
% a=colorbar; b=get(a,'ytick'); set(a,'ytick',b([1 ceil(length(b)/2) end]))

title([subject ' chan ' num2str(chan) ', max=' num2str(cscale)])

vis_figfix

% t = colorbar('peer',gca);
% set(get(t,'ylabel'),'String', 'Z-Score of Log Broadband Power','FontSize',8,'FontName','Times');
% a=get(t,'ytick');  set(t,'ytick',a([1 ceil(length(a)/2) end])); 
% a=get(t,'yticklabel'); set(t,'yticklabel',a,'FontSize',8,'FontName','Times');

%%
load(['data/' subject '/' subject '_decoupled'])
pk=[2:4];

% dc matrix
mm=squeeze(pc_vecs(:,chan,:))';  %mixing matrix
imm=pinv(mm); %inverse mixing matrix
imm_pl=imm; imm_pl(pk,:)=0;
imm_rh=imm; imm_rh(setdiff(1:size(imm,2),pk),:)=0;

spectra_isi_pl=exp(mean(squeeze(nspectra(f,chan,isi_ind))'*mm*imm_pl,1))'.*mean(sf^2*squeeze(spectra(f,chan,:)),2);
spectra_vis_pl=exp(mean(squeeze(nspectra(f,chan,vis_ind))'*mm*imm_pl,1))'.*mean(sf^2*squeeze(spectra(f,chan,:)),2);

spectra_isi_rh=exp(mean(squeeze(nspectra(f,chan,isi_ind))'*mm*imm_rh,1))'.*mean(sf^2*squeeze(spectra(f,chan,:)),2);
spectra_vis_rh=exp(mean(squeeze(nspectra(f,chan,vis_ind))'*mm*imm_rh,1))'.*mean(sf^2*squeeze(spectra(f,chan,:)),2);

subplot('position',[.08 .34 .25 .13]), semilogy(f,mean(squeeze(spectra(f,chan,isi_ind)),2),'k'), hold on, semilogy(f,mean(squeeze(spectra(f,chan,vis_ind)),2),'r'), axis tight, set(gca,'xtick',[])
text(100, mean(get(gca,'ylim'))/4,'raw spectra','FontSize',8)
title('Visual (red) vs. ISI (black) Power Spectra')
vis_figfix
%
subplot('position',[.08 .21 .25 .13]), semilogy(f,spectra_isi_pl,'k'), hold on, semilogy(f,spectra_vis_pl,'r'), axis tight, set(gca,'xtick',[])
text(100, mean(get(gca,'ylim'))/4,'no rhythms','FontSize',8)
ylabel('\mu V')
vis_figfix
%
subplot('position',[.08 .08 .25 .13]), semilogy(f,spectra_isi_rh,'k'), hold on, semilogy(f,spectra_vis_rh,'r'), axis tight
text(100, mean(get(gca,'ylim'))/4,'rhythms only','FontSize',8)
xlabel('Frequency')
vis_figfix

%% sample distributions with errorbars, etc.
for k=1:3
    band=bands(k,:);
    load(['data/' subject '/' subject '_spatstats_' num2str(band(1)) '_' num2str(band(2))]), clear modm mods 
    [modm, mods, dz_dist]=modcorr(subject,band); %%% THIS FIXES THINGS
    rhythmm=sf*rhythmm;rhythms=sf*rhythms; % normalize properly
    %
    subplot('position',[.64 .48-.13*k .12 .12])
    kjm_errbar(1:5,rhythmm(chan,:),rhythms(chan,:),rhythms(chan,:),bcol);
    set(gca,'xtick',1:5), set(gca,'xticklabel',{'r','l','d','u','ISI'})
    ylabel('\mu V')
    a=min(rhythmm(chan,:)-rhythms(chan,:));
    b=max(rhythmm(chan,:)+rhythms(chan,:));
    set(gca,'ylim',[a-.2*(b-a) b+.2*(b-a)])
    set(gca,'xlim',[0 6])
    if k==1, title('Rhythm amplitude'), ylabel({'4-8 Hz';'\mu V'}), elseif k==2, ylabel({'8-12 Hz';'\mu V'}), elseif k==3, ylabel({'12-20 Hz';'\mu V'}),end
    vis_figfix
    %
    subplot('position',[.82 .48-.13*k .12 .12])        
    kjm_errbar(1:5,modm(chan,:),mods(chan,:),mods(chan,:),bcol);
    set(gca,'xtick',1:5), set(gca,'xticklabel',{'r','l','d','u','ISI'})
    ylabel('Z_{mod}')
    a=min(modm(chan,:)-mods(chan,:));
    b=max(modm(chan,:)+mods(chan,:));
    set(gca,'ylim',[a-.2*(b-a) b+.2*(b-a)])
    set(gca,'xlim',[0 6])
    if k==1, title('Phase-Amp Modulation'), end
    vis_figfix
    clear rhythmm rhythms modm mods
end

    %
    subplot('position',[.42 .09 .12 .2])
    kjm_errbar(1:5,lnAm(chan,:),lnAs(chan,:),lnAs(chan,:),bcol);
    set(gca,'xtick',1:5), set(gca,'xticklabel',{'r','l','d','u','ISI'})
%     ylabel('Log Broadband, Z-score units')
    set(gca,'ylim',1.1*[min(lnAm(chan,:)-lnAs(chan,:)) max(lnAm(chan,:)+lnAs(chan,:))])
    set(gca,'xlim',[0 6])
    title('Broadband Amplitude'), ylabel('lnA')
    vis_figfix
%% legend
subplot('position',[.38 .5 .01 .01])
for k=1:5, hold on, plot(1,1,'-','color',bcol(k,:),'LineWidth',1),end, plot(1,1,'w-', 'LineWidth',2)
legend('right','left','up','down','ISI','Location', 'NorthEastOutside'), axis off

%% print figure

kjm_printfig(['figs/' subject '/' subject '_' num2str(chan) '_elec_fig'],[12 9])
