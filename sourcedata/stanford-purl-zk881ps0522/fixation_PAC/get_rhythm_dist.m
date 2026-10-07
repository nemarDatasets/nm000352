function get_rhythm_dist(subject, band)
% This gets the distribution of rhythm blocks during baseline
%     This is code for calculating phase entrainment in rest datasets. See
%     "Human Motor Cortical Activity Is Selectively Phase- Entrained on 
%     Underlying Rhythms", by Kai Miller and colleagues, in PLoS
%     Compuational Biology, 2012.
%     Please cite this manuscript in any setting (manuscripts, talks) 
%     where this program was used. 
%     Copyright (C) 2015, Kai J Miller, Stanford Neurosurgery
%     kai.miller@stanford.edu, kjmiller@gmail.com
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.



%% parameters

    srate=1000; % sampling rate
    num_bins=24; % number of phase bins

%% get rhythm

    load(['data/' subject '/' subject '_decoupled'],'data'), % load re-reffed data from "decoupled" file
    num_chans=size(data,2);

    fband=0*data;
    disp('getting rhythm')
    % CONSIDER REPLACING THIS WITH SOMETHING TAHT IS GAUSSIAN IN THE FREQ. DOMAIN
    [bf_b bf_a] = getButterFilter(band, srate); %band pass
    for k=1:size(data,2) %loop to save
        fband(:,k)=hilbert(filtfilt(bf_b, bf_a, data(:,k))); %band pass
    end
    clear data bf*

%% create block timing definitions
    disp('finding behavioral blocks')
    blocksize = 2 * srate;

    num_blocks = ceil(size(fband,1)/blocksize);
    trialnr=zeros(size(fband,1),1);
    tr_sc=0*[1:num_blocks]'; % trial stimuluscode
    tr_sc([1 end])=-1; % epochs to dump at the end - here set to first and last

    % all but last block
    for k=1:(num_blocks-1)
        trialnr((k-1)*blocksize+[1:blocksize])=k;
    end

    % last block
    trialnr((k*blocksize+1):end)=num_blocks;


%% trial by trial mean data - can add in power in freq bands here later  

    load(['data/' subject '/' subject '_pc_ts'],'lnA') % loads lnA (broadband)
     for k=1:num_chans, lnA(:,k)=zscore(lnA(:,k)); end % z-score broadband

    fprintf(1, 'Calculating power and modulation for all trials ...\n');
    for cur_trial=1:max(trialnr), 
        %index counter for display
        if (mod(cur_trial+1, 20) == 0), fprintf(1, '%03d ', cur_trial+1); if (mod(cur_trial+1, 100) == 0), fprintf(1, '* /%d\r', max(trialnr)); end, end
        %isolate relevant data 
        tt=find(trialnr == cur_trial);
        % log power - change here if want to go to A(t) instead of lnA(t)
            lnA_blocks(cur_trial,:)=mean(lnA(tt,:),1);
        % rhythm amplitude - square if want power instead of amplitude
            rhythm_blocks(cur_trial,:)=mean(abs(fband(tt,:)),1); 
        % Z modulation
            for k=1:num_chans
                % get coupling by phase
                    [bin_pwr, bin_centers]=phase_power( ...
                        lnA(tt,k), ...  %broadband
                        angle(fband(tt,k)), ...  %phase
                        num_bins);
                % total coupling
                    mod_blocks(cur_trial,k)=2*mean((bin_pwr-mean(bin_pwr)).*exp(1i*bin_centers));
            end
    end % session


%% get rid of dump epochs

    a=find(tr_sc==-1);
    tr_sc(a)=[];
    mod_blocks(a,:)=[]; rhythm_blocks(a,:)=[]; lnA_blocks(a,:)=[]; clear a

%% identify unique behavioral vars from 'pts' variable

    beh_types=[0];
    baseline_type=0; % rest is zero in this case

%% distributions - bb power and rhythm amp


    for chan=1:size(lnA_blocks,2)
        lnA_blocks(:,chan)=lnA_blocks(:,chan)-mean(lnA_blocks(find(tr_sc==baseline_type),chan)); % subtracts off mean of baseline (rest) state
    end

%% distributions - coupling
dz_dist=zeros(length(tr_sc),num_chans);
    for chan=1:size(mod_blocks,2)
        for k=1:length(beh_types)
            if any(tr_sc==beh_types(k))
                rm=mod_blocks(tr_sc==beh_types(k),chan);
                rm(find(isnan(abs(rm))))=[];
                ma=angle(mean(rm));
                mz=abs(mean(rm));
                dz=abs(rm).*cos(angle(rm)-ma); %projected values
                %
                dz_dist(:,chan)=dz;
            end
        end
    end


%% save

    save(['data/' subject '/' subject '_fband_' num2str(band(1)) '_' num2str(band(2))],'fband','*_blocks','dz_dist','*type*','tr_sc')

