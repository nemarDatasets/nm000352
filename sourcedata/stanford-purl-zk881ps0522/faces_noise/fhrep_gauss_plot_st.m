function [electrodes]=fhrep_gauss_plot_st(electrodes,weights)
% function [electrodes]=tail_gauss_plot_l(electrodes,weights)
% projects electrode locations onto their cortical spots in the 
% left hemisphere and plots about them using a gaussian kernel

rel_dir=which('loc_plot');
rel_dir((length(rel_dir)-10):length(rel_dir))=[];
addpath(rel_dir)

load('dg_colormap') 

    %which template?
    template='wholebrain.mat';load(strcat(rel_dir,'/template/',template));




brain=cortex.vert;

%gaussian "cortical" spreading parameter - in mm, so if set at 10, its 1 cm
%- distance between adjacent electrodes
gsp=50;

c=zeros(length(cortex(:,1)),1);
for i=1:length(electrodes(:,1))
    b_z=abs(brain(:,3)-electrodes(i,3));
    b_y=abs(brain(:,2)-electrodes(i,2));
    b_x=abs(brain(:,1)-electrodes(i,1));
%     d=weights(i)*exp((-(b_x.^2+b_z.^2+b_y.^2).^.5)/gsp); %gaussian 
    d=weights(i)*exp((-(b_x.^2+b_z.^2+b_y.^2))/gsp); %gaussian 
    c=c+d';
end
% c=(c/max(c));
a=tripatch(cortex, '', c');
set(gcf,'Renderer', 'zbuffer')
shading interp;
a=get(gca);
%%NOTE: MAY WANT TO MAKE AXIS THE SAME MAGNITUDE ACROSS ALL COMPONENTS TO REFLECT
%%RELEVANCE OF CHANNEL
d=a.CLim;
set(gca,'CLim',[-max(abs(d)) max(abs(d))])
l=light;
colormap(cm)
lighting gouraud;
material dull;
view(180,-90);
set(l,'Position',[0 0 -1]) 
axis off
set(gcf,'Color','w')