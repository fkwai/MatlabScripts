
global kPath
dataFolder=[kPath.SCAN,'Daily',kPath.s];
tab=readtable([kPath.SCAN,'nwcc_inventory_CONUS.csv']);
smapMat=load('H:\Kuai\Data\SMAP_L3_CONUS.mat');

%% SCAN data
% hard code depth list
depthLst=[2,4,6,8,12,15,20,40,60,80];
nDepth=length(depthLst);
sidLst=tab.stationId;
nS=length(sidLst);

indS=zeros(nS,1);

statMat=zeros(length(sidLst),length(depthLst))*nan;
stat='rmse';

for k=1:nS
    k
    try
        [scan_tmp,tnum_tmp]=readSCAN_DB(sidLst(k));
        lat=tab.lat(k);
        lon=tab.lon(k);
        [C,indY]=min(abs(smapMat.lat-lat));
        [C,indX]=min(abs(smapMat.lon-lon));
        smap_tmp=permute(smapMat.data(indY,indX,:),[3,1,2]);
        [C,indT_smap,indT_scan]=intersect(smapMat.tnum(1:803),tnum_tmp);
        if ~isempty(C)
            for kk=1:length(depthLst)
                statTmp=statCal(scan_tmp(indT_scan,kk)./100,smap_tmp(indT_smap));
                statMat(k,kk)=statTmp.(stat);
            end
        end
        
        
    end
end