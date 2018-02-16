function indSub=subsetSMAP_interval(interval,offset,varargin)
%split dataset from CONUS for given interval and offset

global kPath
pnames={'mask','rootDB','subsetRoot'};
dflts={kPath.maskSMAP_CONUS,kPath.DBSMAP_L3,'CONUS'};
[maskFile,rootDB,subsetRoot]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

maskMat=load(maskFile);
dirSubset=[rootDB,filesep,'Subset',filesep];

%% pick grid by interval
maskIndSub=maskMat.maskInd(offset:interval:end,offset:interval:end);
indSub=maskIndSub(:);
indSub(indSub==0)=[];

%% save index file. Name by default
indFile=[dirSubset,subsetRoot,'v',num2str(interval),'f',num2str(offset),'.csv'];
dlmwrite(indFile,subsetRoot,'');
dlmwrite(indFile, indSub,'precision',8,'-append');

end

