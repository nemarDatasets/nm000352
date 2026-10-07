function [dyn_spec, f]=dyn_pwr_spectra(data,trigs,rng,fmax)
% event triggered dynamic spectrum
%[dynamic_spectrum(time_onset-time_offset,length(freq)), frequencies] = ...
%   dyn_pwr_spectra(data,triggered points, [time_onset time offset]);
    
srate=1000;

dyn_spec=zeros(rng(2)-rng(1)+1,fmax);

if (trigs(1)+rng(1))<1, trigs(1)=[]; end
if (trigs(end)+rng(2))>size(data,1), trigs(end)=[]; end

for f=fmax:-1:1;
    if mod(f,10)==0, disp(['on ' num2str(f) ' of ' num2str(fmax)]), end
    
    %create wavelet
    t=1:floor(5*srate/f);
    wvlt=exp(1i*2*pi*f*(t-floor(max(t)/2))/srate).*altgwin(max(t))'; %gaussian envelope
    
    %calculate convolution
    tconv=conv(data,wvlt);
    tconv([1:(floor(length(wvlt)/2)-1) floor(length(tconv)-length(wvlt)/2+1):length(tconv)])=[]; %eliminate edges 

    %use power - modify elsewhere for phase, or to keep complex
    tconv=(abs(tconv)).^2;
    
    % smooth
    winlength=80;
    tconv=(conv(tconv,gausswin(winlength)));tconv(1:floor(winlength/2-1))=[];tconv((length(tconv)-floor(winlength/2-1)):length(tconv))=[]; 
        
    %normalize - use % of mean power (note that z-score of log power, or something else, might be better)
    tconv=tconv/mean(tconv);
    
    %calculate triggered power
    for k=1:length(trigs)
        dyn_spec(:,f)=dyn_spec(:,f)+tconv(trigs(k)+[rng(1):rng(2)]);
    end
    

end

dyn_spec=dyn_spec/length(trigs);
%
