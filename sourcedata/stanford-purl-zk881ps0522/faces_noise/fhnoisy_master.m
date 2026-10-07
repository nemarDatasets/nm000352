function fhnoisy_master(subject)



%% things to run    
    dc_opt = 'y';
    lnA_opt= 'y';
    
    addpath dc_files
    warning('off','signal:psd:PSDisObsolete'); %annoying

%% area labels
area_lbls={...
	'Temporal pole', ... %1
	'Parahippocampal gyrus',... %2, parahippocampal part of the medial occipito-temporal gyrus
	'Inferior temporal gyrus',... %3
	'Middle temporal gyrus',... %4
	'fusiform gyrus',... %5 Lateral occipito-temporal gyrus, 
	'Lingual gyrus',... %6, lingual part of  the medial occipito-temporal gyrus
	'Inferior occipital gyrus',... %7
	'Cuneus',... %8
	'Post-ventral cingulate gyrus',... %9 Posterior-ventral part of the 
	'Middle Occipital gyrus',... %10 
	'occipital pole',... %11 
	'precuneus',... %12 
	'Superior occipital gyrus',... %13 
	'Post-dorsal cingulate gyrus',... %14 Posterior-dorsal part of the 
    ' ',...%15
    ' ',...%16    
    ' ',...%17
    ' ',...%18
    ' ',...%19
    'Non-included area',... %20
    };


%% select subject-specific parameters

% subject specific defaults
switch subject
    case 'ap' 
        clims=[150 400]; % color limits / scaling for MRI
    case 'ca' %%%
        clims=[80 125]; % color limits / scaling for MRI
    case 'ha' %%%
        clims=[50 130]; % color limits / scaling for MRI
    case 'ja' %%%         
        clims=[.2 .75]; % color limits / scaling for MRI
    case 'mv' %%%      
        clims=[400 725]; % color limits / scaling for MRI
    case 'wc' %%%
        clims=[1000 2500]; % color limits / scaling for MRI
    case 'zt' %%%
        clims=[300 650]; % color limits / scaling for MRI
end            


%% Localizer analysis
%     face_localizer(subject)

%% NOISY ANALYSIS
%% load data
    load(['data/' subject '/' subject '_fhnoisy'])

    % re-reference CAR or regress out 1st mode
    data=car(data); % common average reference
    %     data=pcr(data); % regress out first mode

    % get events 
    pts=fhnoisy_get_events(stim);
    
%% decouple and get broadband timeseries
        addpath dc_files\

        disp('decoupling ...')
        [spectra,pts]=calc_fhnoisy_spectra(data,pts); %spectral snapshots, note that 2nd column of pts is midpoints,
        [nspectra]=calc_nspectra(spectra); %normalize spectra
        [pc_weights, pc_vecs, pc_vals, f]=dg_pca_step(nspectra); %perform PCA
        save(['data/' subject '/' subject '_fhnoisy_decoupled'], 'pc_*', '*spectra','f','pts') %save
        clear('pc_*', '*spectra','f') % cleanup

        disp('calculating lnA ...')
        gen_fhnoisy_pc_all(subject,data)


%% get "basic picture" from localizer task with rvals pvals
    [chan_lbls, pvals, rvals]=fhplain_get_chans(subject);


%% channels to use and processing
    load(['data/' subject '/' subject '_fhplain'])
    ch2use=find(sum(rvals(1:2,:)>.1)>0);
    for k =1:length(ch2use)
        if rvals(2,ch2use(k))>rvals(1,ch2use(k))
            fhnoisy_channelprocess(subject,ch2use(k),'f')
        else
            fhnoisy_channelprocess(subject,ch2use(k),'h')        
        end
        fhnoisy_analyze(subject, ch2use(k))
    end
    
%% classifier (note that reaction time stuff is in here)  
    load(['data/' subject '/' subject '_fhplain'])
    ch2use=find(sum(rvals(1:2,:)>.1)>0);
    fhnoisy_analyze(subject, ch2use(end))
    fhnoisy_classifier(subject)
    

%% figures
    close all

    for k =1:length(ch2use)
        fhnoisy_chanfig(subject, ch2use(k),clims)
    end
    

