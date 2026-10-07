function [pac_matrix, amp_corr, bin_centers]=phase_pac_range(power,raw,srate,num_bins,fmax)
% function [pac_matrix, bin_centers]=phase_pac_range(power,raw,srate,num_bins,fmax)
% this function calculates the mean power in "num_bins" evenly spaced bins
% note that it explicitly normalizes for uneven density
% need to modify to return a reshuffling statistic
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

bin_edges=[-pi:(2*pi/num_bins):(pi)];
bin_centers=bin_edges(1:(num_bins))+pi/num_bins;

for f=fmax:-1:1;
%     if mod(f,10)==0, disp(['on ' num2str(f) ' of ' num2str(fmax)]), end
    
    %create wavelet
    t=1:floor(5*srate/f);
    wvlt=exp(1i*2*pi*f*(t-floor(max(t)/2))/srate).*altgwin(max(t))'; %gaussian envelope
    
    %calculate convolution
    tconv=conv(wvlt,raw);
    tconv([1:(floor(length(wvlt)/2)-1) floor(length(tconv)-length(wvlt)/2+1):length(tconv)])=[]; %eliminate edges 
    
    %calculate pac matrix
    for k=1:num_bins
        t_ind=find(and(angle(tconv)<bin_edges(k+1),angle(tconv)>=bin_edges(k)));
        pac_matrix(f,k)=mean(power(t_ind));
    end
    
    %calculate amplitude correlation
    amp_corr(f)=corr(power,abs(tconv));

end


%
