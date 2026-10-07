function gen_fhnoisy_pc_all(subject,data)

load(['data/' subject '/' subject '_fhnoisy_decoupled'],'pc_vecs')
clear pc_weights


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create indices to exclude around harmonics of 60
f0=1:300; no60=[];
for k=1:ceil(max(f0/60)), no60=[no60 (60*k-3):(60*k+3)]; end %3 hz up or down
no60=[no60 247:253]; 
f0=setdiff(f0,no60); %dispose of 60hz stuff
f0(find(f0>200))=[];
if subject=='jc', f0(find(f0>195))=[]; f0(find(and(f0>97,f0<103)))=[]; f0(find(and(f0>155,f0<165)))=[]; f0(find(and(f0>53,f0<67)))=[]; end
if subject=='cc', f0(find(f0<5))=[]; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


lnA=0*data;

for chan=1:size(data,2)
    disp([subject ' channel ' num2str(chan) ' / ' num2str(size(data,2))])
    dt=data(:,chan); 
    mm=squeeze(pc_vecs(:,chan,:))';  %mixing matrix
    pcvec1=mm(:,1);  
    lnA(:,chan)=dg_tf_pwr_rm(dt,pcvec1,f0);
end

save(['data/' subject '/' subject '_fhnoisy_lnA'],'lnA')
