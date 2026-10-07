function gen_10k_base(subject)


% load amp roll-off correction
load('ns_10k_1_4000_filt')

%load pairwise channel assignment table
pair_sort_32

% load data
load(['data/' subject '_10kbase'])

% differential re-ref and calculate spectra
for k=1:size(cps,1)
    bpsig=data(:,cps(k,2))-data(:,cps(k,1));
    bp_spectra_raw=psd(double(bpsig),10000,10000,10000,5000);
    bp_spectra(:,k)=bp_spectra_raw(1:4000)./((nsfilt.').^2);
end
clear data k

save(['data/' subject '_10k_spectra'], 'bp_spectra')