function indSub=subsetSMAP_interval(interval,offset,doGlobal)
% split dataset from CONUS for given interval and offset
% have to start from Global/CONUS

global kPath
if doGlobal
    maskFile=kPath.maskSMAP;
    rootDB=kPath.DBSMAP_L3_Global;
    subsetRoot='Global';
else
    maskFile=kPath.maskSMAP_CONUS;
    rootDB=kPath.DBSMAP_L3;
    subsetRoot='CONUS';
end

maskMat=load(maskFile);
dirSubset=[rootDB,filesep,'Subset',filesep];

%% pick grid by interval
maskIndSub=maskMat.maskInd(offset:interval:end,offset:interval:end);
indSub=maskIndSub(:);
indSub(indSub==0)=[];

%% save index file. Name by default
subsetName=[subsetRoot,'v',num2str(interval),'f',num2str(offset)];
indFile=[dirSubset,subsetName,'.csv'];
dlmwrite(indFile,subsetRoot,'');
dlmwrite(indFile, indSub,'precision',8,'-append');

end

