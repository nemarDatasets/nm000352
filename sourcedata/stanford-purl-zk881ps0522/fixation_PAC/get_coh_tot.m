function get_coh_tot(subject,band)
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

%% get rhythm & overall coherence

load(['data/' subject '/' subject '_fband_' num2str(band(1)) '_' num2str(band(2))],'fband','*type*','dz_*','tr_sc'),  
num_chans=size(fband,2);
    % rhythm coherence
    for k=1:(num_chans-1)
        for q=(k+1):num_chans
         coh_tot(k,q)=mean(exp(1i*(angle(fband(:,k))-angle(fband(:,q)))),1);
        end        
    end
        
    coh_tot(num_chans,:)=0;
    coh_tot=coh_tot+coh_tot';
    
save(['data/' subject '/' subject '_coh_tot_' num2str(band(1)) '_' num2str(band(2))], 'coh_tot', 'band')




