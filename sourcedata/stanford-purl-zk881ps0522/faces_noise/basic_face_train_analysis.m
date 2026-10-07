function [bb,tr_bb,tr_stim]=basic_face_train_analysis(data, stim)
% function [bb,tr_bb,tr_stim]=kjm_bb_task(data, stim)
% this function:
%     generates a broadband estimate of power, and 
%     smooths in log domain - z-scores w.r.t. baseline first (you can also  set this to z-score across all time)
%     samples data by task. 
% inputs:
%     data - time-by-channels
%     stim - time-by-1
%         stim should have the stimulus at every point in time
%         make sure ISI is set to 0; others should be other integers
% outputs:
%     bb - broadband timeseries, time-by-channels
%     tr_bb - trial averaged broadband trial-by-channels
%     tr_stim - stimulus type of each trial trial-by-1
% Made by kjm, 11/2011

%% options
zscore_baseline='y'; % z-score log by baseline first (otherwise overall zscore)

%% defaults
band=[76 200]; %filtering range
samplerate=1000; %samplingrate
num_chans=size(data,2); % number of channels
tlength=size(data,1); %number of total time (sample) points

% %% Common Average Reference - may already be taken care of prior to downsample
%     disp('common avg spatial filtering')
%     for k=1:tlength
%         data(k,:)=data(k,:)-mean(data(k,:));
%     end

%% filter design

    % notch filter around 60Hz, 120Hz and 180Hz
    % butterworth notch filter - model order, [low/(samplerate/2) high/(samplerate/2)]
    [n1_b, n1_a]=butter(3,2*[57 63]/samplerate,'stop'); %60hz
    [n2_b, n2_a]=butter(3,2*[117 123]/samplerate,'stop'); %120hz
    [n3_b, n3_a]=butter(3,2*[177 183]/samplerate,'stop'); %180hz
        
    % bandpass filter data, using parameters borrowed from Pradeep Shenoy (from Rao lab)
    % replace with your elliptical filter here if you prefer
    Rp = 3; Rs = 60; 
    delta = 0.001*2/samplerate;
    low = band(1); high = band(2);
    low_p = band(2)*2/samplerate; high_p = band(1)*2/samplerate;
    high_s = max(delta, high_p - 0.1);
    low_s = min(1-delta, low_p + 0.1);
    [n_band, wn_band] = buttord([high_p low_p], [high_s low_s], Rp, Rs);
    [bf_b bf_a] = butter(n_band, wn_band);

%% do filtering and get power - use filtfilt so no offset/phase distortion
    disp('notch filtering for 60Hz harmonics, band-pass filtering for desired range')
    band_sig=zeros(size(data));
    for k=1:num_chans
        if mod(k,5)==0,disp(strcat(num2str(k),'/',num2str(num_chans))),end %this is to tell us our progress as the program runs
        data(:,k)=filtfilt(n1_b, n1_a, data(:,k)); %notch out at 60
        data(:,k)=filtfilt(n2_b, n2_a, data(:,k)); %notch out at 120
        data(:,k)=filtfilt(n3_b, n3_a, data(:,k)); %notch out at 180
        band_sig(:,k)=filtfilt(bf_b, bf_a, data(:,k)); %band pass
    end
    band_pwr=abs(hilbert(band_sig)).^2; 
    
    clear data band_sig %to save space and memory

%% smooth and z-score the data in log domain, and then re-exponentialte

winlength=floor(.25*samplerate);
bb=0*band_pwr;% initialize broadband

for k=1:num_chans
    a=band_pwr(:,k);
    a=log(a);a=(a-mean(a))/std(a); %z-score for memory considerations before convolution
    b=(conv(gausswin(winlength),a)); %smooth
    b(1:floor(winlength/2-1))=[];b((length(b)-floor(winlength/2-1)):length(b))=[]; % clip edges after convolution
    %
    if zscore_baseline=='y'
        b=(b-mean(b(find(stim==0))))/std(b(find(stim==0))); %z-score of baseline
    else 
        b=(b-mean(b))/std(b); % standard z-score
    end
    %
    bb(:,k)=exp(b);% re-exponentiate
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Now do task-sampling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% isolate stimulus periods
    trtemp=1;
    trialnr=0*stim; %initialize
    trialnr(1)=trtemp;
    tr_sc=0;
    for n=2:length(stim)
        if stim(n)~=stim(n-1)
            trtemp=trtemp+1;
        end
        trialnr(n)=trtemp;
    end
    clear n trtemp

%% cycle through trials and get mean power
    % initialize
    tr_bb=zeros(max(trialnr),num_chans);
    tr_stim=zeros(1,num_chans);

fprintf(1, 'Calculating power for all trials ...\n');
for cur_trial=1:max(trialnr),     
    %index counter for display
    if (mod(cur_trial+1, 20) == 0), fprintf(1, '%03d ', cur_trial+1); if (mod(cur_trial+1, 100) == 0), fprintf(1, '* /%d\r', max(trialnr)); end, end
    %
    %isolate relevant data and stimulus
    tt=find(trialnr == cur_trial);
    tr_bb(cur_trial,:)=mean(bb(tt,:));
    tr_stim(cur_trial)=mean(stim(tt));    
end
    
    
    
