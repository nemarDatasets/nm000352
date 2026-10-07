







%%

tasks={'verbs','nouns'};

band=[76 200];

subjects={...
        'bp',...   
        'hl',...    
        'in',...
        'jc',...
        'zt',...    
        'wc',...   
        'ww'...
         };
     
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(subjects)
    subject=subjects{k};
    for q=1:2
        fname=[subject '_' tasks{q}];
        if exist(['data/' fname '.mat'],'file')==2, %checks for files or directories.            
            [lang_cum, band_power, tt, sp_overlap] = rtlang_bandpoweranalysis(fname);            
        end
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





