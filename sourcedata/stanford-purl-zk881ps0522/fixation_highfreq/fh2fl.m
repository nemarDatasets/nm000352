function [chi]=fh2fl(a)

% a=spectra_cor(:,30);

fL=1;

fH=450:-25:150;
% fH=300:-25:150;

%create indices to exclude around harmonics of 60
no60=[];
for k=1:ceil(max(fH/60))
    no60=[no60 (60*k-3):(60*k+3)]; %3 hz up or down
end

chi=[];

for m=1:length(fH)
    
    clear p
    p=zeros(2,max(fH));
    for n=fL:(fH(m)-50)
        fit_int=[(n:fH(m))]; %fit interval
        fit_int=setdiff(fit_int,no60); %dispose of 60hz stuff
        p(:,n)=polyfit(log(fit_int'),log(a(fit_int)),1);
    end
    chi=[chi; p(1,:)];
end

chi(find(chi==0))=NaN;

clf, plot(real(chi'))

legend(num2str(fH'))
title('fH to fL','FontSize',12)
xlabel('frequency (Hz)','FontSize',12)
ylabel('exponent \chi','FontSize',12)
set(gca,'FontSize',12)
set(gcf,'Color',[1 1 1])


