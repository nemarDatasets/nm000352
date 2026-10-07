function get_rhythm_dist(subject, band)

%% load data, set defaults
    load(['data/' subject '/' subject '_vis_pac_results']),
    load(['data/' subject '/' subject '_vissearch']),
    load(['data/' subject '/' subject '_pc_ts'])
    srate=1000; num_bins=24; num_chans=size(data,2);

%% get rhythm
    fband=0*data;
    disp('getting rhythm')
    [bf_b bf_a] = getButterFilter(band, srate); %band pass
    for k=1:size(data,2) %loop to save
        fband(:,k)=hilbert(filtfilt(bf_b, bf_a, data(:,k))); %band pass
    end
    clear data
    save(['data/' subject '/' subject '_fband_' num2str(band(1)) '_' num2str(band(2))],'fband')

%% isolate broadband and smooth timecourse
    bbs=0*lnA;
    for k=1:size(bbs,2);
        [bbs(:,k)]=exp(pc_clean(zscore(lnA(:,k))));
    end

%% isolate stimulus periods
    trtemp=1;
    trialnr=0*stim; %initialize
    trialnr(1)=trtemp;
    tr_sc=0;
    for n=2:length(stim)
        if stim(n)~=stim(n-1)
            trtemp=trtemp+1;
            tr_sc=[tr_sc stim(n)];
        end
        trialnr(n)=trtemp;
    end
    clear n trtemp

%% trial by trial mean data - can add in power in freq bands here later  
    fprintf(1, 'Calculating power and modulation for all trials ...\n');
    for cur_trial=1:max(trialnr), 
        %index counter for display
        if (mod(cur_trial+1, 20) == 0), fprintf(1, '%03d ', cur_trial+1); if (mod(cur_trial+1, 100) == 0), fprintf(1, '* /%d\r', max(trialnr)); end, end
        %isolate relevant data 
        tt=find(trialnr == cur_trial);
        tr_bbs(cur_trial,:)=mean(bbs(tt,:));
        % log power - change here if want to go to A(t) instead of lnA(t)
            lnA_blocks(cur_trial,:)=mean(lnA(tt,:),1);
        % rhythm amplitude - square if want power instead of amplitude
            rhythm_blocks(cur_trial,:)=mean(abs(fband(tt,:)),1); 
        % Z modulation
            for k=1:num_chans
                % get coupling by phase
                    [bin_pwr, bin_centers]=phase_power(...
                        zscore(lnA(tt,k)),... %broadband
                        angle(fband(tt,k)), ...  %phase
                        num_bins);
                % total coupling
                    mod_blocks(cur_trial,k)=2*mean((bin_pwr-mean(bin_pwr)).*exp(1i*bin_centers));
            end
            tr_sc(cur_trial)=mean(stim(tt));
    end % session

%% stats
    % in case of too small of epochs for calculation of mod
    mod_blocks(isnan(sum(mod_blocks,2)),:)=0;


    for k=1:size(lnA,2)
        rr1(k)=rsa(rhythm_blocks(find(tr_sc==1),k),rhythm_blocks(find(tr_sc==5),k));
        rr2(k)=rsa(rhythm_blocks(find(tr_sc==2),k),rhythm_blocks(find(tr_sc==5),k));
        rr3(k)=rsa(rhythm_blocks(find(tr_sc==3),k),rhythm_blocks(find(tr_sc==5),k));
        rr4(k)=rsa(rhythm_blocks(find(tr_sc==4),k),rhythm_blocks(find(tr_sc==5),k));

        rb1(k)=rsa(lnA_blocks(find(tr_sc==1),k),lnA_blocks(find(tr_sc==5),k));
        rb2(k)=rsa(lnA_blocks(find(tr_sc==2),k),lnA_blocks(find(tr_sc==5),k));
        rb3(k)=rsa(lnA_blocks(find(tr_sc==3),k),lnA_blocks(find(tr_sc==5),k));
        rb4(k)=rsa(lnA_blocks(find(tr_sc==4),k),lnA_blocks(find(tr_sc==5),k));    

        rm1(k)=rsa(abs(mod_blocks(find(tr_sc==1),k)),abs(mod_blocks(find(tr_sc==5),k)));
        rm2(k)=rsa(abs(mod_blocks(find(tr_sc==2),k)),abs(mod_blocks(find(tr_sc==5),k)));
        rm3(k)=rsa(abs(mod_blocks(find(tr_sc==3),k)),abs(mod_blocks(find(tr_sc==5),k)));
        rm4(k)=rsa(abs(mod_blocks(find(tr_sc==4),k)),abs(mod_blocks(find(tr_sc==5),k)));    
    end

    clear a b bf* crsa cstat cur_trial f pc_vecs k pts rinds num* 

%% distributions of lnA, modulation and rhythm magnitude for each stim or isi block
    for chan=1:size(lnA_blocks,2)
        lnA_blocks(:,chan)=lnA_blocks(:,chan)-mean(lnA_blocks(find(tr_sc==5),chan));
        for k=1:5
            lnAm(chan,k)=mean(lnA_blocks(find(tr_sc==k),chan));
            lnAs(chan,k)=std(lnA_blocks(find(tr_sc==k),chan))/sqrt(sum(tr_sc==k));
            %
            modm(chan,k)=mean(abs(mod_blocks(find(tr_sc==k),chan)));
            mods(chan,k)=std(abs(mod_blocks(find(tr_sc==k),chan)))/sqrt(sum(tr_sc==k)); 
            %
            rhythmm(chan,k)=mean(rhythm_blocks(find(tr_sc==k),chan));
            rhythms(chan,k)=std(rhythm_blocks(find(tr_sc==k),chan))/sqrt(sum(tr_sc==k));
        end
    end
    save(['data/' subject '/' subject '_spatstats_' num2str(band(1)) '_' num2str(band(2))],'tr_sc', '*_blocks','r*', 'lnAm','lnAs','rhythm*','mod*')




% NOTE - MAKE ELECTRODE - BY - ELECTRODE BARPLOTS FOR PAPER
