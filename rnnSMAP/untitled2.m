nHucLst=[3:6];
for i=1:length(nHucLst)
    i
    tic
    nHUC=nHucLst(i);
    rootOut=['/mnt/sdb1/Kuai/rnnSMAP_outputs/hucv2n',num2str(nHUC),filesep];
    matFile=[rootOut,'hucv2n',num2str(nHUC),'.mat'];
    saveFile=['/mnt/sdb1/Kuai/rnnSMAP_outputs/','hucv2n',num2str(nHUC),'_stat.mat'];
    load(matFile)
    save(saveFile,'statMat','crdMat','optLst')
    toc
    tic
    matFile=[rootOut,'hucv2n',num2str(nHUC),'_CONUSv2f1.mat'];
    saveFile=['/mnt/sdb1/Kuai/rnnSMAP_outputs/','hucv2n',num2str(nHUC),'_CONUSv2f1_stat.mat'];
    load(matFile)
    save(saveFile,'statMat','crdMat','optLst')
    toc
end