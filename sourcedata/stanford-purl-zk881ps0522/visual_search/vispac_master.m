% function vispac_master(subject)



%% general stuff, path, samplerate, etc
    addpath dc_files
    warning('off','signal:psd:PSDisObsolete'); %annoying
    samplerate=1000;
    fmax=50; num_bins=24; %parameters for pac pallette
    erp_win=[-999 3000]; %length of ERP to examine
    bands=[[4 8];[8 12];[12 20]];

%% load data
    load(['data/' subject '/' subject '_vissearch'])

%% chop up data appropriately
    stim=(floor((stim-1)/10))+1; %puts directions (in groups of 10) into groups of 1
    ns=find((stim-[0; stim(1:(end-1))])~=0); ns(stim(ns)==0)=[]; %onset of each stimulus
    pts=[ns; ns+1000]; pts(pts<600)=[]; %events variable
    pts=[pts pts stim(pts(:,1))];

%% pre-process data - note that this has already been done, including
    % 1) rejecting artifactual channels, 
    % 2) common average re-referencing across all remaining cortical electrodes
    % 3) downselecting the data to only early visual regions    
    
%% decoupling

    %Calculate snapshots of power spectrum
    [spectra]=calc_dg_spectra(data,pts);

    %normalize
    [nspectra]=calc_nspectra(spectra);

    %perform PCA
    [pc_weights, pc_vecs, pc_vals, f]=dg_pca_step(subject,nspectra);
    
    %save
    save(['data/' subject '/' subject '_decoupled'],'pc_*','*spectra', 'pts','f'), clear *spectra pc_* f

%% get pc timeseries and save
    gen_pc_all(subject,data)
    load(['data/' subject '/' subject '_pc_ts'])
    

%% gen pacs in normalized units - note embedded zscore call

    pac_matrix=zeros(fmax,num_bins,size(data,2)); % this will have the pac palettes for all channels
    amp_corr=zeros(fmax,size(data,2));
    disp('generating pac palettes')
    for chan=1:size(data,2)
        disp([subject ' channel ' num2str(chan) ' / ' num2str(size(data,2))])
        [pac_matrix(:,:,chan), amp_corr(:,chan), bin_centers]=phase_pac_range(zscore(lnA(:,chan)),data(:,chan),samplerate,num_bins,fmax);    
    end

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
    
    tr_bbs=zeros(max(trialnr),size(data,2));

    fprintf(1, 'Calculating power for all trials ...\n');
    for cur_trial=1:max(trialnr), 
        %index counter for display
        if (mod(cur_trial+1, 20) == 0), fprintf(1, '%03d ', cur_trial+1); if (mod(cur_trial+1, 100) == 0), fprintf(1, '* /%d\r', max(trialnr)); end, end
        %isolate relevant data 
        tt=find(trialnr == cur_trial);
        tr_bbs(cur_trial,:)=mean(bbs(tt,:));
    end % session

    tr_bbs(tr_sc==0,:)=[];
    tr_sc(tr_sc==0)=[];

    for k=1:size(data,2) %calculate signed r2, task vs ISI
        r1(k)=rsa(tr_bbs(find(tr_sc==1),k),tr_bbs(find(tr_sc==5),k));
        r2(k)=rsa(tr_bbs(find(tr_sc==2),k),tr_bbs(find(tr_sc==5),k));
        r3(k)=rsa(tr_bbs(find(tr_sc==3),k),tr_bbs(find(tr_sc==5),k));
        r4(k)=rsa(tr_bbs(find(tr_sc==4),k),tr_bbs(find(tr_sc==5),k));
    end

%% erp and erbb
    st_data=zeros(length(erp_win(1):erp_win(2)), size(data,2), length(ns));
    st_bbs=zeros(length(erp_win(1):erp_win(2)), size(data,2), length(ns));

    for chan = 1:size(data,2)
        for k=1:length(ns)
            if ((ns(k)+erp_win(1))>0)&((ns(k)+erp_win(2))<size(data,1))
            st_data(:,chan,k)=data(ns(k)+[erp_win(1):erp_win(2)], chan);
            st_bbs(:,chan,k)=bbs(ns(k)+[erp_win(1):erp_win(2)], chan);
            end
        end
    end

%% dynamic spectra
    disp('generating dynamic spectra (spectrograms)')
    for chan = 1:size(data,2) 
        disp([subject ' channel ' num2str(chan) ' / ' num2str(size(data,2))])
        %[dynamic_spectrum(time_onset-time_offset,length(freq)), frequencies] = dyn_pwr_spectra(data,triggered points, [time_onset time offset], maximum_frequency);
        dyn_spec(:,:,chan) = dyn_pwr_spectra(data(:,chan),ns(stim(ns)<5),[-999 3000], 200);
    end

%%
    for chan=1:size(bbs,2)
        for k=1:5
            chm(chan,k)=mean(tr_bbs(find(tr_sc==k),chan));
            chs(chan,k)=std(tr_bbs(find(tr_sc==k),chan));
        end
    end

%% save intermediate results
    save(['data/' subject '/' subject '_vis_pac_results'], 'st*', 'dyn_spec','chm','chs', 'erp_win','bin_centers','pac_matrix')


%% analyze different frequency bands for coupling and amplitude
    for k=1:size(bands,1)
        get_rhythm_dist(subject, bands(k,:))
    end

%% create plots of data
    disp('making channel figures')
    for chan = 1:size(data,2) 
        disp([subject ' channel ' num2str(chan) ' / ' num2str(size(data,2))])
        vis_make_elec_fig, close
    end


