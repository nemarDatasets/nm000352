function [xL,lf_naive,hf_naive,f]=twolorentzfit(bp_spectra)

%% defaults
    f_low=15;
    fL_high=80; %naive fit high
    high_bound=195;
    f0=70; %specific frequency of knee

%% create indices to exclude around harmonics of 60
    f=f_low:300; 
    no60=[];
    for k=1:ceil(max(f/60)), no60=[no60 (60*k-3):(60*k+3)]; end %3 hz up or down
    no60=[no60 247:253];
    f=setdiff(f,no60); %dispose of 60hz stuff
    f(find(f>high_bound))=[];
    
%% naive fit:
    fit_int_l=[f_low:57 63:fL_high];
    fit_int_h=f(find(f>fL_high));

    for m=1:size(bp_spectra,2)
        p2=polyfit(log(fit_int_l),log(bp_spectra(fit_int_l,m))',1); 
        lf_naive(m)=p2(1); %naive low freq fit
        p2=polyfit(log(fit_int_h),log(bp_spectra(fit_int_h,m))',1); 
        hf_naive(m)=p2(1); %naive high freq fit
    end
    lf_naive=lf_naive'; hf_naive=hf_naive';

%% free parameter fit
    xL=.01:.01:4;
    sd=zeros(size(bp_spectra,2),length(xL));
    for m=1:size(bp_spectra,2)
        spectemp=bp_spectra(:,m);
        ft=f(find(spectemp(f)>0));
        for k=1:length(xL)
            xH=4-xL(k); 
            g=(ft.^(-xL(k))).*(1./(1+(ft./f0).^xH));
            a=(log(spectemp(ft)./g'));% plot(f,a), title(num2str(xH)),xlabel(num2str(xL(m))), pause %diagnostic check
            sd(m,k)=sum((a-mean(a)).^2); %mean of error from slope zero after correction
        end
    end
    [y,ind]=min(sd,[],2);
    xL=ind/100;
    

    
