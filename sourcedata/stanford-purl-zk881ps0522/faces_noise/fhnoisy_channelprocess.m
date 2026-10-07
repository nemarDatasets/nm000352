function fhnoisy_channelprocess(subject,chan,spectype)

% NOTE - chan should refer to index in chan label (e.g. not to electrode number, but channel after rejection)
% spectype is the type that this channel is specific for (important for projections)



%% check spectype

    if spectype=='f'
        fhtype=2;
    elseif spectype=='h'
        fhtype=1;
    else
        error('input has to be ''f'' or ''h''','input has to be ''f'' or ''h''')
    end

%% load templates from localizer task
    load(['data/' subject '/' subject '_erp_erbb'])

    % broadband - reject 200 ms prior to stim, normalize
    erbb=[erbb{1}(201:800,chan) erbb{2}(201:800,chan)]; erbb=erbb-1; 
    erbb=erbb/max(max(erbb)); %normalize
    
    % erp - get baseline using -200 to 100
    erp=[erp{1}(:,chan) erp{2}(:,chan)]; 
    erp(:,1)=erp(:,1)-mean(erp(1:300,1)); 
    erp(:,2)=erp(:,2)-mean(erp(1:300,2)); 
    erp(1:200,:)=[];
    erp=erp/(max(max(erp))-min(min(erp)));

    clear smp_interval    
    
%% load data from fhnoisy
    load(['data/' subject '/' subject '_fhnoisy'],'tr_coh','tr_fh','key','stim','data')

    data=data(:,chan_lbls); % reject bad electrodes
    data=car(data); data=zscore(data(:,chan)); % chan is after bad electrodes have been rejected 

    load(['data/' subject '/' subject '_fhnoisy_lnA'],'lnA')
    lnA=lnA(:,chan);
    % emooth, zscore, re-exponentiate, subtract 1 (bc exp of ratio)
    bb=fh_pc_clean(lnA,stim); bb=bb-1; clear lnA

%% find keypresses
    kp=zeros(length(tr_coh),2);%keypress
    rt=NaN*zeros(1,length(tr_coh));%keypress reaction time

    % because any responses before 200ms are likely in response to the prior stimulus, set back by 200
    key(1:200)=[];
    for k=1:length(tr_coh)
        dt=key(stim==k);
        %need to make sure not held down from previous
        dtdiff=(dt(2:end)>0)-(dt(1:(end-1))>0); %only want keypress onset            
        if any(dtdiff) % actual keypress
            rt(k)=find(dtdiff,1); % reaction time
            kp(k,2)=dt(rt(k));
            kp(k,1)=1;
        end
     
    end
    
    rt=rt+200;
    clear key dtdiff

    
%% sort data into trial-by-trial
    trialsVo=zeros(1000,length(tr_coh));
    trialsBB=zeros(1000,length(tr_coh));
    for k=1:length(tr_coh)
        dt=data(stim==k);
        bbt=bb(stim==k);
        trialsVo(:,k)=dt(1:1000);
        trialsBB(:,k)=bbt(1:1000);     
    end

    clear bbt dt k
    
%% sort by coherence

    [b,c]=sort(tr_coh);
    %
    trialsVo=trialsVo(:,c);
    trialsBB=trialsBB(:,c);
    %
    tr_coh=tr_coh(c);
    tr_fh=tr_fh(c);
    rt=rt(c);
    kp=kp(c);
    
    clear b c

    
%% cycle through fhnoisy trials to get face or house projections from localizer waveforms
    proj_time=300;
    for trnum=1:length(tr_coh)
        trbb=trialsBB(:,trnum); % select bb portion
        trerp=trialsVo(:,trnum);trerp=trerp-mean(trerp(1:100)); % select erp portion and baseline

        trerp_proj=zeros(proj_time,1);trbb_proj=zeros(proj_time,1);

        for k=1:proj_time
            trerp_proj(k)=sum(trerp([1:600]+k).*erp(:,fhtype)); %ERP projection of paired template type 
            trbb_proj(k)=sum(trbb([1:600]+k).*erbb(:,fhtype)); %BB projection of paired template type 
        end
        [bb_proj(trnum),bb_time(trnum)]=max(trbb_proj);
        [erp_proj(trnum),erp_time(trnum)]=max(trerp_proj);
    end    

  
    clear trerp* trbb* proj_time bb k stim trnum

    

%% get projections for localizer task - can be used later for classifier
    load(['data/' subject '/' subject '_faceshouses'],'data','stim')
    data=car(data(:,chan_lbls)); data=zscore(data(:,chan));

    load(['data/' subject '/' subject '_fh_lnA'],'lnA')
    lnA=lnA(:,chan); bb=fh_pc_clean(lnA,stim)-1; clear lnA

    % get events 
    locpts=fh_get_events(stim); locpts(:,2)=[]; % discard midpoints - not needed for this study
    locpts(locpts(:,2)==0,:)=[];

    % loop through and get projections
    for k = 1:size(locpts,1) % just cycle through each point and channel. inefficient but straightforward
        dt0=data([1:600]+locpts(k,1)); %this is our single trial response, from stimulus onset
        dt0=dt0-mean(dt0(1:100));

        bb0=bb([1:600]+locpts(k,1)); %this is our single trial response, from stimulus onset, through ISI, 
        % "TA"	- total activity
        loc_erp_proj(k)=sum(dt0.*erp(:,fhtype)); %ERP projection of paired template type 
        loc_bb_proj(k)=sum(bb0.*erbb(:,fhtype)); %BB projection of paired template type 

    end

    clear bb0 dt0 bb data k stim
    
%% save      
    save(['data/' subject '/fhnchans/' subject '_' num2str(chan) '_fhnchan'])