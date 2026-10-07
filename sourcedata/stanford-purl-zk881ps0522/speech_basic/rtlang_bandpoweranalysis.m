function [lang_cum, band_power, tt, sp_overlap] = rtlang_bandpoweranalysis(fname)
% function [lang_cum, band_power, tt, sp_overlap] = rtlang_bandpoweranalysis(fname)
% lang_cum: cumulative activity after subtracting expected signal deviation
% band_power: power in frequency band
% tt: time steps
% sp_overlap: sequential overlap correlation in activation maps over time
% notches around harmonics of 60
% Common Average Referenced, etc, see comments within code.  comment things
% in and out to add or take away features.
% results will be saved in data folder named 'an_"fname"_band'
% kjm, 8/2010

%%
    load(['data/' fname])
    band=[76 200]; samplerate=1000;

    num_chans=size(data,2); % number of channels
    tlength=size(data,1); %number of total time (sample) points
    % samplerate=1000; % sampling rate
    sample_block=.040*samplerate; % sample block size
    bnum_int=2; % number of sample blocks to integrate over
    prewindow_size=8*samplerate; %pre action window for baseline and std calculation  - for language, we only have 5 seconds
    postwindow_size=8*samplerate; %post action window for baseline and std check
    act_bl_size=floor(3*samplerate/sample_block); % activity block size in units of sampleblocks (3 sec. action, not using 3 sec rest)
    threshold_std=2; %number of standard deviations below which to discard data

%% Common Average Reference
    disp('common avg spatial filtering')
    for k=1:tlength
        data(k,:)=data(k,:)-mean(data(k,:));
    end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Filter data in each channel for desired band, notch filter around 60Hz
    % and 120Hz
    %butterworth notch filter - model order, [low/(samplerate/2) high/(samplerate/2)]
    [n1_b, n1_a]=butter(3,2*[57 63]/samplerate,'stop'); %60hz
    [n2_b, n2_a]=butter(3,2*[117 123]/samplerate,'stop'); %120hz
    [n3_b, n3_a]=butter(3,2*[177 183]/samplerate,'stop'); %180hz
    disp('notch filtering for 60Hz harmonics')
    % Filter data in each channel for desired band, notch filter around 120Hz -
    % change for 60 later if necessary
    band_sig=zeros(size(data));
    [bf_b bf_a] = getButterFilter(band, samplerate); %band pass
    for k=1:num_chans
        if mod(k,5)==0,disp(strcat(num2str(k),'/',num2str(num_chans))),end %this is to tell us our progress as the program runs
        data(:,k)=filtfilt(n1_b, n1_a, data(:,k)); %notch out at 60
        data(:,k)=filtfilt(n2_b, n2_a, data(:,k)); %notch out at 120
        data(:,k)=filtfilt(n3_b, n3_a, data(:,k)); %notch out at 180
        band_sig(:,k)=filtfilt(bf_b, bf_a, data(:,k)); %band pass
    end
    clear data %to save space and memory

%% calculate power in band_sig
    disp(strcat(['calculating power in ',num2str(2*sample_block), ' sample window, stepping by ',num2str(2*sample_block),' samples each time']))
    band_power=zeros(ceil(tlength/sample_block)-1,num_chans);
    band_sig=band_sig.^2; %this way we square each index at the start, rather than doing it redundantly later,, can put it inside loop
    for k=bnum_int:ceil(tlength/sample_block) %step every 40 ms (sampleblocksize), but start at 2nd since we're using 80 ms window for power
        band_power(k-1,:)=log(sum(band_sig((sample_block*k-(bnum_int*sample_block-1)):(sample_block*k),:),1)); %calculate power in 80 ms window in units of amplifier amplitude squared
    end
    clear band_sig %to save space, memory

%% calculate mean and standard deviation in a pre-stimulus window, and check with post-stimulus window 
    pre_window=band_power(1:floor(prewindow_size/sample_block),:); %prewindow
    post_window=band_power((size(band_power,1)+1-(floor(postwindow_size/sample_block))):(size(band_power,1)),:); %postwindow
    prew_mean=mean(pre_window,1); %pre activity window mean
    prew_std=std(pre_window,1); %pre activity window standard deviation
    postw_mean=mean(post_window,1); %post activity window mean
    postw_std=std(post_window,1); %post activity window standard deviation
    bb_mean=mean([pre_window; post_window],1);  %baseline mean from both pre and post
    bb_std=std([pre_window; post_window],1);  %baseline std from both pre and post
    % plot pre and post -- quality control
    figure
    subplot(2,1,1)
    errorbar(1:num_chans,prew_mean,prew_std,prew_std,'bo'), hold on, errorbar(1:num_chans,postw_mean,postw_std,postw_std,'ko'),
    legend('pre-activity','post-activity','Location','NorthEastOutside'),xlabel('channel'),ylabel('power')
    title(strcat([fname ' pre- and post- mean and variance']))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % normalize by baseline, then threshold: subtract pre-activity mean and divide by pre-activity std.  Then threshold by 2std devs
    for k=1:num_chans
        bp_temp(:,k)=(band_power(:,k)-bb_mean(k))/bb_std(k); % subtract off preactivity mean, divide to put in units of std.
    %     bp_temp(:,k)=bp_temp(:,k).*(bp_temp(:,k)>threshold_std); %threshold, discarding changes less than threshold_std    
    end
    band_power=bp_temp;
    bp_temp=(bp_temp>threshold_std); %threshold, discarding changes less than threshold_std
    lang_cum=cumsum(bp_temp((floor(prewindow_size/sample_block)+1):end,:),1);
    %clear leftovers (some of these are now legacy)
    clear  f n runnr bf_a n_a sample_block  bf_b n_b samplenr bnum_int n* num_chans samplerate Running dpts post_window SelectedStimulus SourceTime tlength postwindow_size StimulusTime i pre_window StimulusType indices prew_mean trialnr act_bl_size itxt prew_std k prewindow_size 
%% %%%%%%%%%%%%%%%%%%%
    subplot(2,1,2)
    imagesc(.04*[1:size(lang_cum,1)],[1:size(lang_cum,2)],(lang_cum./(repmat(max(lang_cum,[],2),1,size(lang_cum,2))))'), xlabel('Time (s)'), ylabel('Channel')
    exportfig(gcf, ['figs/',fname,'_prepost_tdev.eps'], 'format', 'eps', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 300, 'Width', 3, 'Height', 2);    
%% normalize, reject noise stuff, etc
    % subtract off expected >2sd 
        a=(lang_cum-.023*((([1:size(lang_cum,1)])')*ones(1,size(lang_cum,2))));
    % normalize by time
        a=a./((([1:size(lang_cum,1)])')*ones(1,size(lang_cum,2)));
    % threshold above zero (due to subtraction of expected noise
    a(a<=0)=0;
    %
    lang_cum=a;
%% plot raster of cumulative activity
    subplot(2,1,2)
    imagesc(.04*[1:size(lang_cum,1)],[1:size(lang_cum,2)],(lang_cum./(repmat(max(lang_cum,[],2),1,size(lang_cum,2))))'), xlabel('Time (s)'), ylabel('Channel')
    exportfig(gcf, ['figs/',fname,'_prepost_tdev.eps'], 'format', 'eps', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 300, 'Width', 3, 'Height', 2);    

%% overlap stuff
    for k = 2:(floor(size(a,1)/(25*3))-4) % every 3 seconds
        % overlap conditions - 1 last spot (3 sec ago)
        sp_overlap(k) = corr(a(25*3*k,:)',a(25*3*(k-1),:)');    
        % overlap conditions - 3 spots ahead (9 sec ahead)
        sp_overlap(k) = sp_overlap(k).*corr(a(25*3*k,:)',a(25*3*(k+3),:)');
    end
    sp_overlap=sp_overlap.^.5;
    tt=3*[1:k];
%% plot overlap as a fxn of time
    figure, plot(tt,sp_overlap), xlabel('time (s)'), ylabel('overlap correlation')
    exportfig(gcf, ['figs/',fname,'_overlapcorr.eps'], 'format', 'eps', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 300, 'Width', 3, 'Height', 2);

%% plot activity with stimulation    
    % calculate appropriate weights, etc
    sp_overlap(sp_overlap==0)=NaN;
    ctmp=find((sp_overlap>=.99)&(([0 sp_overlap(1:(end-1))])<.99));
    if numel(ctmp)==0, disp([fname(1:2) ' is over']), 
        ctmp=floor(size(lang_cum,1)/(3*25)); 
        sp=zeros(ctmp,1); 
        sp(1:length(sp_overlap))=sp_overlap;
        sp_overlap=sp;
    end
    ta_99=ctmp(1);
    t_thresh=75*ta_99;

    load dg_colormap
        load(['brains/' fname(1:2) '_brain']) % load brain and positions
        lang_cum=lang_cum(t_thresh,:);    
        clf,reddot_surf_stim(brain,locs,lang_cum,stimsites,ecssites) % make plot
        set(gcf,'color',[.01 .01 .01]), title(fname(1:2),'Color','k')        
        exportfig(gcf, ['figs/' fname '_w_stim'], 'format', 'png', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 300, 'Width', 6, 'Height', 4);

       
save(['data/an_' fname '_res_' num2str(band(1)) '_' num2str(band(2))])
