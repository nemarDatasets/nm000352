function gen_pc_all(subject)
%     This is code for calculating principal spectral components in rest datasets. See
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

load(['data/' subject '/' subject '_decoupled'])
clear pc_weights

%% create indices to exclude around harmonics of 60
    f0=1:300; no60=[];
    for k=1:ceil(max(f0/60)), no60=[no60 (60*k-3):(60*k+3)]; end %3 hz up or down
    no60=[no60 247:253]; 
    f0=setdiff(f0,no60); %dispose of 60hz stuff
    f0(find(f0>200))=[];


%%
lnA=0*data;

for chan=1:size(data,2)
    disp([subject ' channel ' num2str(chan) ' / ' num2str(size(data,2))])
    dt=data(:,chan); 
    mm=squeeze(pc_vecs(:,chan,:))';  %mixing matrix
    pcvec1=mm(:,1);  
    lnA(:,chan)=kjm_lnA_timecourse(dt,pcvec1,srate,f0);
end

%% save data
save(['data/' subject '/' subject '_pc_ts'],'lnA')
