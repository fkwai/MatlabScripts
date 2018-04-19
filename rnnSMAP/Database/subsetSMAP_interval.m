function indSub=subsetSMAP_interval(interval,offset,option,varargin)
% split dataset from CONUS for given interval and offset
% have to start from Global/CONUS

global kPath
switch option
    case 'Global_L3'
        maskFile=kPath.maskSMAP;
        rootDB=kPath.DBSMAP_L3_Global;
        subsetRoot='Global';
    case 'CONUS_L3'
        maskFile=kPath.maskSMAP_CONUS;
        rootDB=kPath.DBSMAP_L3;
        subsetRoot='CONUS';
    case 'NA_L3'
        maskFile=kPath.maskSMAP_CONUS;
        rootDB=kPath.DBSMAP_L3_NA;
        subsetRoot='CONUS';
    case 'CONUS_L4'
        maskFile=kPath.maskSMAPL4_CONUS;
        rootDB=kPath.DBSMAP_L4;
        subsetRoot='CONUS';
    case 'NA_L4'
        maskFile=kPath.maskSMAPL4_CONUS;
        rootDB=kPath.DBSMAP_L4_NA;
        subsetRoot='CONUS';
end

maskMat=load(maskFile);

varinTab={'writeSubFile',1;};
[writeSubFile]=internal.stats.parseArgs(varinTab(:,1),varinTab(:,2), varargin{:});

%% pick grid by interval
maskIndSub=maskMat.maskInd(offset:interval:end,offset:interval:end);
indSub=maskIndSub(:);
indSub(indSub==0)=[];

%% save index file. Name by default
if writeSubFile
    subsetName=[subsetRoot,'v',num2str(interval),'f',num2str(offset)];
    subsetSMAP_indSub(indSub,rootDB,subsetRoot,subsetName )
end

end

