function face_localizer(subject)


    addpath dc_files
    warning('off','signal:psd:PSDisObsolete'); %annoying

%% defaults
    srate=1000;
    smp_interval=[-199 600]; %peristimulus times for averages, etc



%% load data
    load(['data/' subject '/' subject '_faceshouses'])
    chan_lbls=1:size(data,2);

%% re-reference / regress out 1st mode
    data=car(data); % common average reference
%     data=pcr(data); % regress out first mode

%% get events 
    pts=fh_get_events(stim);
    
%% decouple

    disp('decoupling ...')
    [spectra]=calc_dg_spectra(data,pts); %spectral snapshots, note that 2nd column of pts is midpoints, correct?
    [nspectra]=calc_nspectra(spectra); %normalize spectra
    [pc_weights, pc_vecs, pc_vals, f]=dg_pca_step(nspectra); %perform PCA
    save(['data/' subject '/' subject '_fh_decoupled'], 'pc_*', '*spectra','f','pts') %save
    clear('pc_*', '*spectra','f') % cleanup
     disp('...')
%% broadband timeseries
    disp('calculating lnA ...')
    gen_pc_all(subject,data)
    
%% get bb
    load(['data/' subject '/' subject '_fh_lnA'],'lnA')
    bb=fh_pc_clean(lnA,stim); clear lnA

%% get and save ERPs / ERBBs - note, need to make so it loads lnA
    for fh_class=1:2
        erp{fh_class}=fh_sta(data, pts, fh_class, smp_interval);
        erbb{fh_class}=fh_sta(bb, pts, fh_class, smp_interval);
    end
    save(['data/' subject '/' subject '_erp_erbb'],'erp','erbb','smp_interval','chan_lbls')
