function [chan_lbls, pvals, rvals]=fhplain_get_chans(subject)




%% load bb timeseries, 
    load(['data/' subject '/' subject '_fh_lnA'],'lnA')
    load(['data/' subject '/' subject '_faceshouses'],'stim')
    load(['data/' subject '/' subject '_erp_erbb'],'chan_lbls')

    % emooth, zscore, re-exponentiate
    bb=fh_pc_clean(lnA,stim);

    % subtract 1 (bc exp of ratio)
    bb=bb-1;
    
    clear lnA

    
%% get events 
    pts=fh_get_events(stim);    
    pts(:,2)=[]; % discard midpoints - not needed for this study

%% - quantities for each trial
for q=1:size(bb,2)
for k = 1:size(pts,1) % just cycle through each point and channel. inefficient but straightforward
%%
    data=bb([101:500]+pts(k,1),q); %this is our single trial response, from stimulus onset, through ISI, until next stimulus
    
    % "TA"	- total activity
    tr_bb(k,q)=sum(data);
    


end
end

%% get stats

for k =1:size(tr_bb,2)
    rvals(1,k)=rsa(tr_bb(pts(:,2)==1,k),tr_bb(pts(:,2)==0,k));
    rvals(2,k)=rsa(tr_bb(pts(:,2)==2,k),tr_bb(pts(:,2)==0,k));
    rvals(3,k)=rsa(tr_bb(pts(:,2)==2,k),tr_bb(pts(:,2)==1,k));
    %
    [h,pvals(1,k)]=ttest2(tr_bb(pts(:,2)==1,k),tr_bb(pts(:,2)==0,k));
    [h,pvals(2,k)]=ttest2(tr_bb(pts(:,2)==2,k),tr_bb(pts(:,2)==0,k));
    [h,pvals(3,k)]=ttest2(tr_bb(pts(:,2)==2,k),tr_bb(pts(:,2)==1,k));
end


%%

    figure, plot(chan_lbls,rvals.','o')
    legend('house vs null', 'face vs null', 'house vs face')


%%
save(['data/' subject '/' subject '_fhplain'],'chan_lbls', 'pvals', 'rvals')


