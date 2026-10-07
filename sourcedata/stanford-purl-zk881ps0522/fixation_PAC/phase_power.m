function [bin_power, bin_centers]=phase_power(power,phase,num_bins)
% function [bin_power]=phase_powr(data,num_bins)
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

bin_edges=[-pi:(2*pi/(num_bins)):(pi)];
bin_centers=bin_edges(1:(num_bins))+pi/num_bins;
bin_power=zeros(1,num_bins);


for k=1:num_bins
    t_ind=find(and(phase<bin_edges(k+1),phase>=bin_edges(k)));
    bin_power(k)=mean(power(t_ind));
end

%