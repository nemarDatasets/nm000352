% function call_subs

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

addpath dc_files
warning('off','signal:psd:PSDisObsolete'); %annoying
%%
subjects=[
    'bp';...
    'cc';...
    'hl';...
    'jc';...
    'jm';...
    'jp';...
    'ug';...
    'wc';...
    'wm';...
    'zt';...    
];


%%
bands=[[4 8];[8 12];[12 20]];

for q=1:size(subjects,1)
    subject=subjects(q,:);
    disp(subject)
    
    %% steps in analysis
    % Note: bad channels have been rejected already
    
    % do decoupling
    base_dc_master(subject)
    
    % generate pc timeseries
    gen_pc_all(subject)
    
    % gen coupling pallettes    
    gen_pac_matrix_all(subject)

    % cycle through rhythm bands
    for k=1:size(bands,1)
        % get coupling by band
        band=bands(k,:);
        disp(num2str(band))
        get_rhythm_dist(subject, band)
        % get total coherence
        get_coh_tot(subject,band)    
    end


    make_indsub_rhy_fig(subject), close

end

