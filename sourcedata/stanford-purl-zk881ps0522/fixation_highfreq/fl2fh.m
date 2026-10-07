function [chi]=fl2fh(a,plotopt)

% a=spectra_cor(:,30);
% if exist(plotopt)~=1, plotopt='n'; end
fH=750;
% fH=300;

fL=1:10:121;

%create indices to exclude around harmonics of 60
no60=[];
for k=1:ceil(max(fH/60))
    no60=[no60 (60*k-4):(60*k+4)]; %3 hz up or down
end
%get rid of 500Hz peak
no60=[no60 485:515];


chi=[];

for m=1:length(fL)
    
    clear p
    for n=(fL(m)+30):fH
        fit_int=[((fL(m)):n)]; %fit interval
        fit_int=setdiff(fit_int,no60); %dispose of 60hz stuff        
        fit_int(find(a(fit_int)<=1))=[];  %dispose of stuff that is less than 0
        p(:,n)=polyfit(log(fit_int'),log(a(fit_int)),1);
    end
    chi=[chi; p(1,:)];
end

chi(find(chi==0))=NaN;
if plotopt=='y'
    plot(real(chi'))

%     legend(num2str(fL'),'Location','Best')
%     legend(num2str(fL'),'Location','SouthWest')
    title('fL to fH','FontSize',12)
    xlabel('frequency (Hz)','FontSize',12)
    ylabel('exponent \chi','FontSize',12)
    set(gca,'FontSize',12)
    set(gcf,'Color',[1 1 1])
end

