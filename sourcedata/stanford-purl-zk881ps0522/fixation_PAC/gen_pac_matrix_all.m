function gen_pac_matrix_all(subject)
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


%% general stuff, path, samplerate, etc
    samplerate=1000;
    fmax=50; num_bins=24;

%% load relevant data
    load(['data/' subject '/' subject '_decoupled'],'data'), % load re-reffed data from "decoupled" file
    load(['data/' subject '/' subject '_pc_ts'],'lnA') % loads lnA (broadband)

%% gen pacs in normalized units - note embedded zscore call
    pac_matrix=zeros(fmax,num_bins,size(data,2));
    amp_corr=zeros(fmax,size(data,2));

    for chan=1:size(data,2)
        [pac_matrix(:,:,chan), amp_corr(:,chan), bin_centers]=phase_pac_range(zscore(lnA(:,chan)),data(:,chan),samplerate,num_bins,fmax);    
    end


%% save
    save(['data/' subject '/' subject '_pac_all'],'pac_matrix','bin_centers','fmax'),


