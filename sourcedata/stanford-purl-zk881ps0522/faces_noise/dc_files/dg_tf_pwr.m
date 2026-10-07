function tf=dg_tf_pwr(data)

fmax=200;
srate=1000;

size(data), pack
tf=zeros(length(data),200);
    
for freq=fmax:-1:1;
    if mod(freq,10)==0, disp(['on ' num2str(freq) ' of ' num2str(fmax)]), end
    t=1:floor(5*srate/freq);
    %create wavelet
%     wvlt=exp(i*2*pi*freq*t/srate).*hann(max(t))';  %1-.5*cos envelope
%     wvlt=exp(i*2*pi*freq*t/srate).*hamming(max(t))'; %hamming envelope
    wvlt=exp(i*2*pi*(freq/srate)*(t-floor(2.5*srate/freq))).*exp(-((t-floor(2.5*srate/freq)).^2)/(2*(srate/freq)^2)); %gaussian
    %calculate convolution
    tconv=conv(wvlt,data);
    tconv([1:(floor(length(wvlt)/2)-1) floor(length(tconv)-length(wvlt)/2+1):length(tconv)])=[]; %eliminate edges 
    tconv=abs(tconv).^2;
    if mean(tconv)==0, error('mean power 0','mean power 0'),end  %if there is some problem
    tconv=tconv/mean(tconv);  %norm step
    tf(:,freq)=tconv;
end
