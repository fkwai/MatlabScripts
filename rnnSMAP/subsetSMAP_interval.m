function indSub=subsetSMAP_interval(interval,offset)
%split dataset from CONUS for given interval and offset

global kPath
maskMat=load(kPath.maskSMAP_CONUS);
dirSubset=[kPath.DBSMAP_L3,'Subset',kPath.s];

%% pick grid by interval
maskIndSub=maskMat.maskInd(offset:interval:end,offset:interval:end);
indSub=maskIndSub(:);
indSub(indSub==0)=[];

%% save index file. Name by default
indFile=[dirSubset,'CONUSv',num2str(interval),'f',num2str(offset),'.csv'];
dlmwrite(indFile,'CONUS','');
dlmwrite(indFile, indSub,'-append');

end

