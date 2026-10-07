function [modm, mods, dz_dist]=modcorr(subject,band)



bcol=[[0 0 1];[0 1 0];[1 0 0];[.5 .5 0];[.5 .5 .5]]; %colors for different classes

%%
load(['data/' subject '/' subject '_spatstats_' num2str(band(1)) '_' num2str(band(2))])
clear modm mods r* lnA*

%%

for chan=1:size(mod_blocks,2)
    for k=1:5
        rm=mod_blocks(tr_sc==k,chan);
        ma=angle(mean(rm));
        mz=abs(mean(rm));
        dz=abs(rm).*cos(angle(rm)-ma); %projected values
        %
        modm(k,chan)=mz;
        mods(k,chan)=3*std(dz)/sqrt(length(dz));
%         mods(k,chan)=std(dz);
        %
        angm(k,chan)=ma;
        angs(k,chan)=3*std(dz)/sqrt(length(dz));
        %
        dz_dist{k,chan}=dz;
    end
end

modm=modm';
mods=mods';