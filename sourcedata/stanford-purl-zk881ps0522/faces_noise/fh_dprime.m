function [dpr]=fh_dprime(tp,fp,tn,fn)
    % function fh_dprime(tp,fp,tn,fn)
    % tp - true positive = keystrokes that were on face trials 
    % fp - false positive = keystrokes on house trials
    % tn - true negative = NO keystroke on house trials 
    % fn - false negative = NO keystroke on face trials
    % kjm & dhm, 2/2014


%% calculate hit and false alarm rate
    % hit rate
    hr=sum(tp)/(sum(tp)+sum(fn));

    % false alarm rate
    fa=sum(fp)/(sum(fp)+sum(tn));


%% in order to avoid errors with infinity, just make much smaller than any one sample in my analyses would be (assumes less than 10000 samples)
    if hr==0, hr=1/sum(1+sum(tp)+sum(fn)+sum(fp)+sum(tn));        
    end
    if fa==0, fa=1/sum(1+sum(tp)+sum(fn)+sum(fp)+sum(tn));  end
    if hr==1, hr=sum(sum(tp)+sum(fn)+sum(fp)+sum(tn))/sum(1+sum(tp)+sum(fn)+sum(fp)+sum(tn)); end
    if fa==1, fa=sum(sum(tp)+sum(fn)+sum(fp)+sum(tn))/sum(1+sum(tp)+sum(fn)+sum(fp)+sum(tn)); end

%%

    dpr=norminv(hr)-norminv(fa);

