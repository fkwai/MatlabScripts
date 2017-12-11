% a script to save all matfiles for huc cases

global kPath
nHucLst=[1:6];
rmStd=0;
saveTS=0;

%% temporal
%{
for i=1:length(nHucLst)
    nHUC=nHucLst(i);
    rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHUC),filesep];
    rootDB=['/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n',num2str(nHUC),filesep];
    
    if nHUC~=4
        jobHead=['hucv2n',num2str(nHUC)];
        postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB,...
            'rmStd',rmStd,'saveTS',saveTS);
    else
        jobHead=['huc2_'];
        postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB,...
            'saveName','hucv2n4','rmStd',rmStd,'saveTS',saveTS);
    end
end
%}

for i=1:length(nHucLst)
    nHUC=nHucLst(i);
    rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHUC),filesep];
    %rootDB=['E:\Kuai\rnnSMAP_inputs\hucv2n',num2str(nHUC),filesep];
    rootDB=kPath.DBSMAP_L3;
    if nHUC~=4
        jobHead=['hucv2n',num2str(nHUC)];
        postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB,...
            'rmStd',rmStd,'testName','CONUSv2f1','saveTS',saveTS);
    else
        jobHead=['huc2_'];
        postRnnSMAP_jobHead(jobHead,'rootOut',rootOut,'rootDB',rootDB,...
            'saveName','hucv2n4','rmStd',rmStd,'testName','CONUSv2f1','saveTS',saveTS);
    end
end


