function bb=fh_pc_clean(lnA,stim)
%this function smooths the pcs, puts them in units of mean/std of baseline 200ms


%% %%%%% IF want to PUT IN MEAN/STD OF "STIM OFF" PERIOD

b=(stim==0);

%% %%DO SMOOTHING%%%%%%%
winlength=80;

bb=0*lnA;
for k = 1:size(lnA,2)
    lnAs=(conv(gausswin(winlength),lnA(:,k)));
    lnAs(1:floor(winlength/2-1))=[];
    lnAs((length(lnAs)-floor(winlength/2-1)):length(lnAs))=[]; 
    
    lnAs=(lnAs-mean(lnAs))/std(lnAs);
%     lnAs=(lnAs-mean(lnAs(find(b))))/std(lnAs(find(b)));
    
    bb(:,k)=exp(lnAs); % re-exponentiate
end
