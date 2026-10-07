function gen_10k_spectra_fits(subject)

load(['data/' subject '_10k_spectra']) %load spectra
warning('off','all')

outfolder='figs'; %folder to send figures to

cfitlo=250; %low value for fit of c and a
cfithi=490; %high value for fit of c and a
chilo=300;  %low value for mean to get chi from fL to fH
chihi=400;  %high value for mean to get chi from fL to fH

cmax=13939;  %mean+std ... based upon measured values
cmin=10717;  %mean-std ... based upon measured values

%% %%
%create indices to exclude around harmonics of 60
no60=[];
for k=1:ceil(max(cfithi/60))
    no60=[no60 (60*k-4):(60*k+4)]; %3 hz up or down
end
fit_int=[cfitlo:cfithi]; %fit interval
fit_int=setdiff(fit_int,no60); %dispose of 60hz stuff

%% %%%
for chan=1:52
% for chan=1
    disp(strcat(['channel ' num2str(chan)]))
    spec_temp=bp_spectra(:,chan); %calculate the spectrum corrected for the amplifier transfer function (rolloff)
    chi0=-3.5; %preliminary guess at exponent (only useful to reduce convergence time)
    del_chi=1; %set iterated difference
    n=0; %iteration number 0
    while del_chi>.01 %if iteration difference is small, exclude
        y=(1:4000).^(chi0(n+1)); %get y(f^chi) to estimate c
        n=n+1; %increase counter
        %dispose of indices in fit region that are less than 0
        fit_int(find(spec_temp(fit_int)<=1))=[];
        %%%%
        p2=polyfit(y(fit_int),spec_temp(fit_int)',1); c(n)=p2(2); a(n)=p2(1); %estimate c, a from linear fit
%         if c(n)>cmax, c(n)=cmax; elseif c(n)<cmin, c(n)=cmin; end
%         figure,chi=fl2fh(spec_temp-c(n),'y'); %calculate chi(f) by going fL to fH at different starting points
        chi=fl2fh(spec_temp-c(n),'n'); %calculate chi(f) by going fL to fH at different starting points
        chi0(n+1)=mean(mean(chi(9:13,chilo:chihi),2));  %use the last six fits get new values of "reasonable chi" by averaging the mean offset of avg between
        del_chi=min(abs(chi0(1:n)-chi0(n+1))); %calculate the change in chi
        %display current values
        disp(strcat(['iteration ' num2str(n)]))
        disp(strcat(['chi = ' num2str(chi0(n+1))]))
        disp(strcat(['noise floor = ' num2str(c(n))]))
    end
    
    % get the last c into an overall index -
    nf(chan)=c(n);
    
    %list of all exponents
    chi_n(chan)=chi0(n+1);
    
    % first time where its less than zero 
    l0=find(spec_temp-c(n)<=1);
    l0=sort(l0);
    l0=l0(1);
    
    % calculate A(f)
    a_f=(spec_temp-c(n))./((1:4000)'.^(chi0(n+1)));
    
    % save fit parameters in structures
    eval(strcat('chi_all.c',num2str(chan),'=chi0;'))
    eval(strcat('c_all.c',num2str(chan),'=c;'))
    eval(strcat('a_all.c',num2str(chan),'=a;'))
    eval(strcat('a_f_all.c',num2str(chan),'=a_f;'))
    eval(strcat('l0_all(',num2str(chan),')=l0;'))
    
    % make plots for this channel
    %plot spectra
    clf, loglog(1:4000,spec_temp-c(n),'k')
    xlabel(strcat(['frequency (Hz), c=' num2str(c(n))]),'FontSize',12)
    ylabel(strcat(['Power, \chi=' num2str(chi0(n+1))]),'FontSize',12)
    title(strcat(['Log-log of corrected power spectrum for 5 chan group ' num2str(chan)]))    
    set(gca,'FontSize',12)
    set(gcf,'Color',[1 1 1])
%     axis tight
    exportfig(gcf, strcat(cd,'/',outfolder,'/sc_1_spectrum_',num2str(chan),'.jpg'), 'format', 'jpeg', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 300, 'Width', 9, 'Height', 6);
    %A(f) plot
    clf,loglog(1:4000,a_f,'k','LineWidth',2)
    xlabel(strcat(['frequency (Hz), c=' num2str(c(n))]),'FontSize',12)
    ylabel(strcat(['A(f), \chi=' num2str(chi0(n+1))]),'FontSize',12)
    set(gcf,'Color',[1 1 1])
    title(strcat(['A(f) for channel ' num2str(chan)]))
    exportfig(gcf, strcat(cd,'/',outfolder,'/sc_1_a_f_',num2str(chan),'.jpg'), 'format', 'jpeg', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 300, 'Width', 9, 'Height', 6);    
    %fl2fh plot
    chi=fl2fh(spec_temp-c(n),'y'); 
    axis tight
    exportfig(gcf, strcat(cd,'/',outfolder,'/sc_1_fl2fh_',num2str(chan),'.jpg'), 'format', 'jpeg', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 300, 'Width', 9, 'Height', 6);
    
    disp('--------------')
    clear c chi0 a_f l0 a chi
end

save(['data/' subject '_fit'], 'chi_all', 'c_all', 'a_all', 'a_f_all', 'l0_all', 'nf', 'chi_n')