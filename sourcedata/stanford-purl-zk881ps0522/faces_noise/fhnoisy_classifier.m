function fhnoisy_classifier(subject)

%%

preselect_r2=.1;
disc_type='linear';
% disc_type='quadratic';
% disc_type='mahalanobis';

%% load data, concatenate, dump what is not needed
        load(['data/' subject '/' subject '_fhplain'],'rvals'), ch2use=find(sum(rvals(1:2,:)>.1)>0);
        load(['data/' subject '/fhnchans/' subject '_' num2str(ch2use(end)) '_fhnchan'],'kp','rt','tr_fh')
  
%% load features from all channels       
        bb_proj_all=[];
        erp_proj_all=[];
        loc_bb_proj_all=[];
        loc_erp_proj_all=[];

    for k =1:length(ch2use)
        load(['data/' subject '/fhnchans/' subject '_' num2str(ch2use(k)) '_fhnnlevs'],'loc*','*proj','nlevs','tr_coh','tr_fh')    
        bb_proj_all=[bb_proj_all bb_proj.'];
        erp_proj_all=[erp_proj_all erp_proj.'];
        loc_bb_proj_all=[loc_bb_proj_all loc_bb_proj.'];
        loc_erp_proj_all=[loc_erp_proj_all loc_erp_proj.'];

    
    end
    
%     % for both bb and erp
%     fhn_proj = [bb_proj_all erp_proj_all];
%     loc_proj = [loc_bb_proj_all loc_erp_proj_all];

    % for BB only
    fhn_proj = [bb_proj_all];
    loc_proj = [loc_bb_proj_all];    
    
    
    
    loc_fh=locpts(:,2);

%     clear locpts bb_proj  erp_proj  loc_bb_proj  loc_erp_proj *all k rvals ch2use

    
    
%% down-select to discriminable channels only for feature space - decided not to explicitly include face vs house
clear rfh
for k=1:size(loc_proj,2)
    rfh(k)=rsa(loc_proj(find(loc_fh==2),k),loc_proj(find(loc_fh==1),k));
    
end    

%%
fhn_proj(:,abs(rfh)<preselect_r2)=[];
loc_proj(:,abs(rfh)<preselect_r2)=[];


%% classifier

%     [fh_class_out, err_out,fh_post_prob,fh_logp] = classify(...
%         fhn_proj,...
%         loc_proj,...
%         loc_fh,disc_type); 
%     

%     [fh_class_out, err_out,fh_post_prob,fh_logp] = classify(...
%         zscore(fhn_proj),...
%         zscore(loc_proj),...
%         loc_fh,disc_type);     
        

for k=1:size(fhn_proj,2)
%     fhn_proj(:,k)=fhn_proj(:,k)/std(fhn_proj(:,k));
%     loc_proj(:,k)=loc_proj(:,k)/std(loc_proj(:,k));
    fhn_proj(:,k)=fhn_proj(:,k)/mean(fhn_proj(:,k));
    loc_proj(:,k)=loc_proj(:,k)/mean(loc_proj(:,k));
end

    [fh_class_out, err_out,fh_post_prob,fh_logp] = classify(...
        fhn_proj,...
        loc_proj,...
        loc_fh,disc_type); 


%% identify face choices  

    br=fh_class_out==2;
%     br=0*bb_proj;
%     [a,b]=sort(fh_post_prob(:,2),'descend');
%     br(b(1:floor(length(br)/2)))=1;



%% calculate keypress performance (this is just a convenient place to do it, so all is saved in one file -- not part of classifier)

    % true positive = keystrokes that were on face trials 
    kp_tp=kp(:,1).*(tr_fh==2);

    % false positive = keystrokes on house trials
    kp_fp=kp(:,1).*(tr_fh==1);

    % true negative = NO keystroke on house trials 
    kp_tn=(1-kp(:,1)).*(tr_fh==1);

    % false negative = NO keystroke on face trials
    kp_fn=(1-kp(:,1)).*(tr_fh==2);
    
for k = 1:size(nlevs,1)   
    n_inds=and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2)));
    
    % dprime
    kp_dpr(k)=fh_dprime(n_inds.*kp_tp,n_inds.*kp_fp,n_inds.*kp_tn,n_inds.*kp_fn);
    
    % precision = true_pos / (true_pos + false_pos)
    kp_pre(k)=sum(n_inds.*kp_tp)./ (sum(n_inds.*kp_tp)+sum(n_inds.*kp_fp));
    
    % accuracy = (true_pos+true_neg) / (true_pos + false_pos + true_neg + false_neg)
    kp_acc(k)=(sum(n_inds.*kp_tp)+sum(n_inds.*kp_tn))./...
        (sum(n_inds.*kp_tp)+sum(n_inds.*kp_fp)+sum(n_inds.*kp_tn)+sum(n_inds.*kp_fn));
        
    
end

%% to analyze decoding of stimulus accuracy

    % true positive = brain face predictions that were on face trials 
    br_tp=br(:,1).*(tr_fh==2);

    % false positive = brain face predictions on house trials
    br_fp=br(:,1).*(tr_fh==1);

    % true negative = brain house predictions on house trials 
    br_tn=(1-br(:,1)).*(tr_fh==1);

    % false negative = brain house predictions on face trials
    br_fn=(1-br(:,1)).*(tr_fh==2);

%% decoder accuracy


for k = 1:size(nlevs,1)   
    n_inds=and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2)));
    
    % dprime
    br_dpr(k)=fh_dprime(n_inds.*br_tp,n_inds.*br_fp,n_inds.*br_tn,n_inds.*br_fn);
    
    % precision = true_pos / (true_pos + false_pos)
    br_pre(k)=sum(n_inds.*br_tp)./ (sum(n_inds.*br_tp)+sum(n_inds.*br_fp));
    
    % accuracy = (true_pos+true_neg) / (true_pos + false_pos + true_neg + false_neg)
    br_acc(k)=(sum(n_inds.*br_tp)+sum(n_inds.*br_tn))./...
        (sum(n_inds.*br_tp)+sum(n_inds.*br_fp)+sum(n_inds.*br_tn)+sum(n_inds.*br_fn));
        
    
end

%% to analyze behavior prediction / accuracy

    % true positive = brain face predictions that were on face choices
    pr_tp=br(:,1).*kp(:,1);

    % false positive = brain face predictions on house  choices
    pr_fp=br(:,1).*(1-kp(:,1));

    % true negative = brain house predictions on house choices
    pr_tn=(1-br(:,1)).*(1-kp(:,1));

    % false negative = brain house predictions on face  choices
    pr_fn=(1-br(:,1)).*kp(:,1);
    
    

%% decoder prediction of behavior


for k = 1:size(nlevs,1)   
    n_inds=and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2)));
    
    % dprime
    pr_dpr(k)=fh_dprime(n_inds.*pr_tp,n_inds.*pr_fp,n_inds.*pr_tn,n_inds.*pr_fn);
    
    % precision = true_pos / (true_pos + false_pos)
    pr_pre(k)=sum(n_inds.*pr_tp)./ (sum(n_inds.*pr_tp)+sum(n_inds.*pr_fp));
    
    % accuracy = (true_pos+true_neg) / (true_pos + false_pos + true_neg + false_neg)
    pr_acc(k)=(sum(n_inds.*pr_tp)+sum(n_inds.*pr_tn))./...
        (sum(n_inds.*pr_tp)+sum(n_inds.*pr_fp)+sum(n_inds.*pr_tn)+sum(n_inds.*pr_fn));
        
    
end


%% rt by nlevs (tp and fp)
    
    
    % to analyze keystrokes / accuracy
    kp_tp=kp(:,1).*(tr_fh==2); % true positive = keystrokes that were on face trials 
    kp_fp=kp(:,1).*(tr_fh==1); % false positive = keystrokes on house trials
    kp_tn=(1-kp(:,1)).*(tr_fh==1);  % true negative = NO keystroke on house trials    
    kp_fn=(1-kp(:,1)).*(tr_fh==2);  % false negative = NO keystroke on face trials

for k = 1:size(nlevs,1)   
    n_inds=and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2)));
    
    % rt - tp
    rttp=rt(find(n_inds.*kp_tp));rttp(isnan(rttp))=[]; rt_tp{k}=rttp;    
    rt_tp_m(k)=mean(rt_tp{k}); rt_tp_s(k)= std(rt_tp{k});    
    
    % rt - fp
    rtfp=rt(find(n_inds.*kp_fp));rtfp(isnan(rtfp))=[]; rt_fp{k}=rtfp;    
    rt_fp_m(k)=mean(rt_fp{k}); rt_fp_s(k)= std(rt_fp{k});    

    
end

%%
% only if BB used and not both -- MODIFY if change for ERP as well
    ch_used=ch2use;
    ch_used(abs(rfh)<preselect_r2)=[];

save(['data/' subject '/fhnchans/' subject '_cls_out'],'br','br_*','rt_*','nlevs','pr_*','kp_*','rfh','ch_used')    
        


%% %% precision, accuracy, and dprime of brain decoding
%  
%     figure, 
%     
%     subplot(2,1,2)
%     plot(mean(nlevs.'),br_pre,'m-o')
%     hold on, plot(mean(nlevs.'),br_acc,'-o','color',[.8 .3 .3]) 
%     box off, set(gca,'xtick',[nlevs(:,1).' 100])
%     ylabel('precision or accuracy')
%     a=legend('prec','accu'); set(a,'Fontsize',8)
% 
%     subplot(2,1,1)
%     plot(mean(nlevs.'),br_dpr,'-o','color',[.3 .3 .3]) 
%     box off, set(gca,'xtick',[nlevs(:,1).' 100],'xticklabel',[])
%     ylabel('d-prime') 
%     a=get(gca,'ylim'); text(3,.95*a(2),'Decoder','FontSize',8)
%     

