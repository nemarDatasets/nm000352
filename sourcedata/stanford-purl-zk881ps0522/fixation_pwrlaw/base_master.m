



%%
    subjects=[...
    'al';...
%     'ca';...
%     'cc';...
%     'de';...
%     'fp';...
%     'gc';...
%     'gf';...
%     'gw';...
%     'h0';...
%     'hh';...
%     'jc';...
%     'jm';...
%     'jp';...
%     'mv';...
%     'rh';...
%     'rr';...
%     'ug';...
%     'wc';...
%     'wm';...
    'zt'...
    ];

%%
for k=1:size(subjects,1)
    subject=subjects(k,:);
    
    %% load data, pair-wise re-reference
        load(['data/' subject '_base'])
        if or(subject=='gc',subject=='gw')
            bp_locs1=pairwise_meanloc(locs(1:32,:)); bp_data1=pairwise_reref(data(:,1:32));
            bp_locs2=pairwise_meanloc(locs(33:64,:)); bp_data2=pairwise_reref(data(:,33:64));
            bp_locs=[bp_locs1; bp_locs2]; bp_data=[bp_data1 bp_data2];
        else
            bp_locs=pairwise_meanloc(locs);
            bp_data=pairwise_reref(data);
        end
    
    %% calculate spectra, normalize by roll-off function    
        load('ns_1k_1_300_filt','nsfilt') % amplifier roll-off function (in amplitude)
        % fft parameters
            dlength=size(bp_data,1); %time length of data
            wsize=1024; %window size for spectral calculation
            h_env=hann(wsize); %hann window for edge effects
            st_size=floor(wsize/2); %step size
            ns=floor(dlength/st_size)-2; %number of steps
        % perform fft
            for chan=1:size(bp_data,2)
                tp=zeros(300,1);
                for q=1:ns
                    tm=abs(fft(h_env.*bp_data((st_size*q+1):(st_size*q+wsize),chan))); % amplitude spectra
                    tp=tp+((tm(1:300)./nsfilt(1:300)').^2); % correct for amplifier roll-off
                end
                bp_spectra(:,chan)=tp/ns;
            end
    
    %% isolate only those without clear low-frequency rhythms
        fid2=figure; kchans=[];
        for m=1:size(bp_spectra,2)
            clf,
            subplot(1,2,2),loglog(1:200,bp_spectra(1:200,m)),axis tight,xlabel('f'),ylabel('p'),title([subject ' spectra ch ' num2str(m)]),
            subplot(1,2,1),plot(5:60,bp_spectra(5:60,m)),axis tight,xlabel('f'), ylabel([subject ' - Power(f)'])
            title('y to keep, n to pass'),
            disp('waiting for input (y to keep, n to pass)')
            km=waitforbuttonpress; temp=get(fid2); temp2=get(gca);
            if km==1 %key button
                key=temp.CurrentCharacter;
                if key=='y', 
                    kchans=[kchans m];
                    disp([num2str(m) 'channel kept'])
                elseif key=='n';
                    disp([num2str(m) 'channel rejected'])
                end
            end
        end
    
    %% perform 2-lorentzian fit
        [xL,lf_naive,hf_naive,f]=twolorentzfit(bp_spectra(:,kchans));        
            xL0{k}=xL;
            lf_naive0{k}=lf_naive;
            hf_naive0{k}=hf_naive;            
    
end


%%
    clear xL lf_naive hf_naive
    xL=[]; lf_naive=[]; hf_naive=[];

    for k=1:length(xL0)
        xL=[xL; xL0{k}];
        lf_naive=[lf_naive; lf_naive0{k}]; 
        hf_naive=[hf_naive; hf_naive0{k}];
    end

%%
    figure, 
    subplot(2,1,1), hist(-lf_naive,[1.05:.05:3.45])
    subplot(2,1,2), hist(xL,[1.05:.05:3.45])

