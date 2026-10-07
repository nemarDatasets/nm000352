function ten_k_master

subjects = [...
            's1';...
            's2';...
            's3';...
            's4'...
            ];

for k=1:size(subjects,1)
    subject=subjects(k,:);
    %%
    gen_10k_base(subject)
    gen_10k_spectra_fits(subject)
    
    %isolate bad channels
    switch subject
        case 's1',        bad_els=[24 25 26];
        case 's2',        bad_els=[17 26 31];
        case 's3',        bad_els=[1 6 8 14 16 21 22 23 24 31 32];
        case 's4',        bad_els=[11 16 20 27 31];
    end
    pair_sort_32,
    bad_chans=find(sum([ismember(cps(:,1),bad_els) ismember(cps(:,2),bad_els)],2)>0);
    %%
    save(['data/' subject '_10k_result'])
end

