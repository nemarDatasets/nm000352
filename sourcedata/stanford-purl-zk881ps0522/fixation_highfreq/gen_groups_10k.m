function gen_groups_10k(subject,bad_chans)


load(['data\' subject '_10k_spectra']), clear data %clear raw data to save memory
ch_range=1:52;

%load pair subsets,
pair_group 

%Unnormed spectra
for k=1:8, sp_g04(:,k)=mean(spectra_cor(:,group04(k,:)),2); end
for k=1:4, sp_g08(:,k)=mean(spectra_cor(:,group08(k,:)),2); end
for k=1:2, sp_g16(:,k)=mean(spectra_cor(:,group16(k,:)),2); end
sp_g32=mean(spectra_cor(:,(setdiff(ch_range, bad_chans))),2);


pg=['g04'; 'g08'; 'g16'; 'g32'];
% pg=['g32'];
for q=1:size(pg,1)
    eval(['spec_temp=sp_' pg(q,:) ';'])
    [chi_all, c_all, a_all, a_f_all, l0_all, nf, chi_n, c_hi]=group_fits(spec_temp,[subject '_' pg(q,:)]);
%     [chi_all, c_all, a_all, a_f_all, l0_all, nf, chi_n]=sc_fit_io(spec_temp,outfolder,[fnamein '_' pg(q,:)]);
end

save(['data\' subject '_groupfits'])