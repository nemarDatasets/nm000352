% function call_fhrep_master





%%
subjects = {...
    'mv', ...
    'zt', ...
    'ja', ...
    'wc', ... 
    'ca', ...
    'ap', ...
    'ha', ...    
    };
  

% locs=[];
% el_cat=[];


%% call fhnoisy master
for k = 1:length(subjects)
   disp(subjects{k})
    fhnoisy_master(subjects{k});
end

clear k 

%% get aggregate data
br_acc_all=[]; br_pre_all=[]; br_dpr_all=[];
kp_acc_all=[]; kp_pre_all=[]; kp_dpr_all=[];
pr_acc_all=[]; pr_pre_all=[]; pr_dpr_all=[];

for k = 1:length(subjects)
    disp(subjects{k})

    load(['data/' subjects{k} '/fhnchans/' subjects{k} '_cls_out'],'br_*','pr_*','kp_*','nlevs')
    br_acc_all=[br_acc_all; br_acc]; 
    br_pre_all=[br_pre_all; br_pre]; 
    br_dpr_all=[br_dpr_all; br_dpr];
    %
    kp_acc_all=[kp_acc_all; kp_acc]; 
    kp_pre_all=[kp_pre_all; kp_pre]; 
    kp_dpr_all=[kp_dpr_all; kp_dpr];
    %
    pr_acc_all=[pr_acc_all; pr_acc]; 
    pr_pre_all=[pr_pre_all; pr_pre]; 
    pr_dpr_all=[pr_dpr_all; pr_dpr];
    %
    clear br_acc  br_pre  br_dpr  kp_acc  kp_pre  kp_dpr  pr_acc  pr_pre  pr_dpr 


end

clear k 

% behavioral data is meaningless for the last 3 patients
    kp_acc_all(5:7,:)=[]; 
    kp_pre_all(5:7,:)=[]; 
    kp_dpr_all(5:7,:)=[]; 
    %
    pr_acc_all(5:7,:)=[]; 
    pr_pre_all(5:7,:)=[];  
    pr_dpr_all(5:7,:)=[]; 

%% save or plot aggregate data
subj_colors=[...
    [1 .5 .5];...
    [.5 1 .5];...
    [.5 .5 1];...
    [.7 .3 .7];...
    [1 0 0];...
    [0 1 0];...
    [0 0 1]...
    ];


    figure,
    nlevs0=mean(nlevs.');

    subplot(2,2,1), 
    for k = 1:length(subjects)
    plot(nlevs0, kp_acc_all(k,:),'-o','color',subj_colors(k,:))
    end
%     hold on, plot(nlevs0, mean(kp_acc_all),'-','color',.1*[1 1 1])
%     hold on, plot(nlevs0, mean(kp_acc_all),'o','color',0*[1 1 1])
    legend(subjects{1:4})
    box off, set(gca,'ygrid','on'), title('accuracy of pt choice')
    set(gca,'xtick',[nlevs(:,1).' 100],'ylim',[.4 1])


    subplot(2,2,2), plot(nlevs0, br_acc_all.','.')
    hold on, plot(nlevs0, mean(br_acc_all),'-','color',.4*[1 1 1])
    hold on, plot(nlevs0, mean(br_acc_all),'o','color',.3*[1 1 1])
    legend(subjects)
    box off, set(gca,'ygrid','on'), title('accuracy of brain decoding')
    set(gca,'xtick',[nlevs(:,1).' 100],'ylim',[.4 1])
    %
    subplot(2,2,3), plot(nlevs0, pr_acc_all.','.')
    hold on, plot(nlevs0, mean(pr_acc_all),'-','color',.7*[1 1 1])
    hold on, plot(nlevs0, mean(pr_acc_all),'o','color',.6*[1 1 1])
    legend(subjects{4:7})
    box off, set(gca,'ygrid','on'), title('predictive accuracy of pt choice from brain decoding')
    set(gca,'xtick',[nlevs(:,1).' 100],'ylim',[.4 1])

    subplot(2,2,4), 
    plot(nlevs0, mean(br_acc_all(4:7,:)),'-','color',.4*[1 1 1]), hold on
    plot(nlevs0, mean(br_acc_all(4:7,:)),'o','color',.3*[1 1 1]), hold on
    plot(nlevs0, mean(pr_acc_all),'-','color',.7*[1 1 1]), hold on
    plot(nlevs0, mean(pr_acc_all),'o','color',.6*[1 1 1]), hold on
    legend('decoding of stimulus','decoding of choice')
    box off, set(gca,'ygrid','on'), title('decoding of stimulus & decoding of choice')
    set(gca,'xtick',[nlevs(:,1).' 100],'ylim',[.4 1])
