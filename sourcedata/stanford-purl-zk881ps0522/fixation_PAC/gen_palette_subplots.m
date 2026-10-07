function gen_palette_subplots(pac_matrix)
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


%% load generals, add paths, etc
    addpath /Users/kai/toolbox/ 
    addpath /Users/kai/toolbox/ctmr
    addpath /Users/kai/toolbox/loc    
    load dg_colormap
    % load loc_colormap
    
%%
num_els=size(pac_matrix,3);
num_colu=ceil(num_els/8);
fmax=size(pac_matrix,1);


%%
    num_bins = 24;
    bin_edges=[-pi:(2*pi/num_bins):(pi)];
    bin_centers=bin_edges(1:(num_bins))+pi/num_bins;

%% 
k=1; chan=1;
% cscale=max(max(abs(max(pac_matrix(12:20,:,:)))));
% cscale=max(max(abs(squeeze(pac_matrix(fmax:-1:5,:,8)))));
w_lines=[4 8 12 20];
for k=1:num_els
        % phase-amp pallette
        % subplot('position',[.78 .6 .2 .33])
        subplot(num_colu,8,k)
        pm=squeeze(pac_matrix(:,:,chan));
        cscale=max(max(abs(squeeze(pac_matrix((fmax-10):-1:5,:,chan)))));
        if cscale<.1, cscale=.1; end
        kjm_imagesc_lines(bin_centers,0:10:fmax,pm',cm, cscale, w_lines)
        loc_view(0,90)
        text(-4/5*pi,5,num2str(round(cscale*100)/100))

        set(gca,'ytick',[]), % box off
        set(gca,'xtick',[]), % box off

            % set(gca,'ytick',[0:10:(fmax-10)]),% box off
            % set(gca,'xtick',max(bin_centers)*[-1:1]),set(gca,'xticklabel',{'- pi','0','pi'}), box off% axis tight
            % xlabel('Phase of rhythm')
            % ylabel('Frequency of rhythm')
            % % a=colorbar; b=get(a,'ytick'); set(a,'ytick',b([1 ceil(length(b)/2) end]))
            % 
            % dg_figfix
        chan=chan+1;
end

figfix


function kjm_imagesc_lines(x,y,z,cm, cscale, w_lines)
% this function plots imagesc like it should work. fo sho.
% also adds lines in y at each element of 'w_lines'


if exist('z')~=1, z=x; x=1:size(z,1); y=1:size(z,2); end

z=z.';
z=z(size(z,1):-1:1,:); 

if min(y)==1, y=[0 y]; end

imagesc(x,y,z)

hold on, 
if exist('w_lines')
    for k = 1: length(w_lines)
        plot(get(gca,'xlim'), max(y)-[w_lines(k) w_lines(k)], 'color', .95*[1 1 1])
    end
end

set(gca,'clim', cscale*[-1 1]),
colormap(cm), 



 a=get(gca,'yticklabel'); set(gca,'yticklabel',a(end:-1:1,:))





