function base_dc_master(subject)
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

%
%master file for the baseline fixation data decoupling analysis
srate=1000;
load(['data/' subject '/' subject '_base'],'data')
data=car(double(data));

%Calculate snapshots of power spectrum
pts=(1500+floor(rand*500)):1000:(size(data,1)-1500);
pts=[pts' pts' pts'];
[spectra]=calc_dg_spectra(data,pts);

%normalize
[nspectra]=calc_nspectra(spectra);

%perform PCA
[pc_weights, pc_vecs, pc_vals, f]=dg_pca_step(nspectra);


%save
save(['data/' subject '/' subject '_decoupled'])

disp('...')