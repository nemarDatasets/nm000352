function fhnoisy_analyze(subject, chan)
% analyze and make figure for each channel


load(['data/' subject '/fhnchans/' subject '_' num2str(chan) '_fhnchan'])


%% noise levels for averaging
    nlevs= [[0 10]; [15 25]; [30 40]; [45 55]; [60 70]; [75 100]];
    
%% averaged traces by type and coherence
clear *traces* 
for k = 1:size(nlevs,1)
    f_inds=find((tr_fh==2).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2))));
    h_inds=find((tr_fh==1).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2))));   
    %
    ftraces_Vo(:,k)=mean(trialsVo(:,f_inds).');
    ftraces_BB(:,k)=mean(trialsBB(:,f_inds).');
    htraces_Vo(:,k)=mean(trialsVo(:,h_inds).');
    htraces_BB(:,k)=mean(trialsBB(:,h_inds).');
end


%% averaged projections
clear *_means *_sems
for k = 1:size(nlevs,1)
    f_inds=find((tr_fh==2).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2))));
    h_inds=find((tr_fh==1).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2))));  
    %
    fbb_means(k)=mean(bb_proj(f_inds).');
    fbb_sems(k)=sem(bb_proj(f_inds).');
    %
    ferp_means(k)=mean(erp_proj(f_inds).');
    ferp_sems(k)=sem(erp_proj(f_inds).');
    %
    hbb_means(k)=mean(bb_proj(h_inds).');
    hbb_sems(k)=sem(bb_proj(h_inds).'); 
    %
    herp_means(k)=mean(erp_proj(h_inds).');
    herp_sems(k)=sem(erp_proj(h_inds).'); 
end


%% averaged latencies
clear *_tmeans *_tsems
for k = 1:size(nlevs,1)
    f_inds=find((tr_fh==2).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2))));
    h_inds=find((tr_fh==1).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2)))); 
    %
    fbb_tmeans(k)=mean(bb_time(f_inds).');
    fbb_tsems(k)=sem(bb_time(f_inds).');
    %
    hbb_tmeans(k)=mean(bb_time(h_inds).');
    hbb_tsems(k)=sem(bb_time(h_inds).'); 
    %
    ferp_tmeans(k)=mean(erp_time(f_inds).');
    ferp_tsems(k)=sem(erp_time(f_inds).');
    %
    herp_tmeans(k)=mean(erp_time(h_inds).');
    herp_tsems(k)=sem(erp_time(h_inds).'); 
end


clear trerp* trbb* proj_time
    
%% to analyze keystrokes / accuracy

    % true positive = keystrokes that were on face trials 
    kp_tp=kp(:,1).*(tr_fh==2);

    % false positive = keystrokes on house trials
    kp_fp=kp(:,1).*(tr_fh==1);

    % true negative = NO keystroke on house trials 
    kp_tn=(1-kp(:,1)).*(tr_fh==1);

    % false negative = NO keystroke on face trials
    kp_fn=(1-kp(:,1)).*(tr_fh==2);


%% sort physiology by choice -- projection magnitudes
   
for k = 1:size(nlevs,1)
    
if fhtype==2 % only analyze face physiology in face electrodes
    f_inds=(tr_fh==2).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2)));
    %
    %true positives
    fbb_tp_means(k)=mean(bb_proj(find(f_inds.*kp_tp)).');
    fbb_tp_sems(k)=sem(bb_proj(find(f_inds.*kp_tp).'));
    %
    ferp_tp_means(k)=mean(erp_proj(find(f_inds.*kp_tp)).');
    ferp_tp_sems(k)=sem(erp_proj(find(f_inds.*kp_tp)).');
    %
    %false negatives
    fbb_fn_means(k)=mean(bb_proj(find(f_inds.*kp_fn)).');
    fbb_fn_sems(k)=sem(bb_proj(find(f_inds.*kp_fn)).');
    %
    ferp_fn_means(k)=mean(erp_proj(find(f_inds.*kp_fn)).');
    ferp_fn_sems(k)=sem(erp_proj(find(f_inds.*kp_fn)).');
    
elseif fhtype==1 % only analyze house physiology in house electrodes
    h_inds=(tr_fh==1).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2)));
    %
    %true negatives
    hbb_tn_means(k)=mean(bb_proj(find(h_inds.*kp_tn)).');
    hbb_tn_sems(k)=sem(bb_proj(find(h_inds.*kp_tn).'));
    %
    herp_tn_means(k)=mean(erp_proj(find(h_inds.*kp_tn)).');
    herp_tn_sems(k)=sem(erp_proj(find(h_inds.*kp_tn)).');
    %
    %false positives
    hbb_fp_means(k)=mean(bb_proj(find(h_inds.*kp_fp)).');
    hbb_fp_sems(k)=sem(bb_proj(find(h_inds.*kp_fp)).');
    %
    herp_fp_means(k)=mean(erp_proj(find(h_inds.*kp_fp)).');
    herp_fp_sems(k)=sem(erp_proj(find(h_inds.*kp_fp)).');
    
end
end

%% sort physiology by choice -- projection latencies
   
for k = 1:size(nlevs,1)
    
if fhtype==2 % only analyze face physiology in face electrodes
    f_inds=(tr_fh==2).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2)));
    %
    %true positives
    fbb_tp_tmeans(k)=mean(bb_time(find(f_inds.*kp_tp)).');
    fbb_tp_tsems(k)=sem(bb_time(find(f_inds.*kp_tp).'));
    %
    ferp_tp_tmeans(k)=mean(erp_time(find(f_inds.*kp_tp)).');
    ferp_tp_tsems(k)=sem(erp_time(find(f_inds.*kp_tp)).');
    %
    %false negatives
    fbb_fn_tmeans(k)=mean(bb_time(find(f_inds.*kp_fn)).');
    fbb_fn_tsems(k)=sem(bb_time(find(f_inds.*kp_fn)).');
    %
    ferp_fn_tmeans(k)=mean(erp_time(find(f_inds.*kp_fn)).');
    ferp_fn_tsems(k)=sem(erp_time(find(f_inds.*kp_fn)).');
    
elseif fhtype==1 % only analyze house physiology in house electrodes
    h_inds=(tr_fh==1).*and((tr_coh>=nlevs(k,1)),(tr_coh<=nlevs(k,2)));
    %
    %true negatives
    hbb_tn_tmeans(k)=mean(bb_time(find(h_inds.*kp_tn)).');
    hbb_tn_tsems(k)=sem(bb_time(find(h_inds.*kp_tn).'));
    %
    herp_tn_tmeans(k)=mean(erp_time(find(h_inds.*kp_tn)).');
    herp_tn_tsems(k)=sem(erp_time(find(h_inds.*kp_tn)).');
    %
    %false positives
    hbb_fp_tmeans(k)=mean(bb_time(find(h_inds.*kp_fp)).');
    hbb_fp_tsems(k)=sem(bb_time(find(h_inds.*kp_fp)).');
    %
    herp_fp_tmeans(k)=mean(erp_time(find(h_inds.*kp_fp)).');
    herp_fp_tsems(k)=sem(erp_time(find(h_inds.*kp_fp)).');
    
end
end


%% calculate keypress performance

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

%%

save(['data/' subject '/fhnchans/' subject '_' num2str(chan) '_fhnnlevs'])


