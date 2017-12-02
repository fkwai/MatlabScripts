global kPath
vecV=[4];
vecF=[1];
dbNameLst={'CONUS','LongTerm_85-95','LongTerm_95-05','LongTerm_05-15'};

for k=1:length(vecV)
    interval=vecV(k);
    offset=vecF(k);
    for kk=1:length(dbNameLst)
        dbName=dbNameLst{kk};
        subsetSMAP_interval(interval,offset,...
            'mask',kPath.maskSMAPL4_CONUS,'dirRoot',kPath.DBSMAP_L4,'subsetRoot',dbName);
        subsetSplit_All([dbName,'v',num2str(interval),'f',num2str(offset)],...
            'dirRoot',kPath.DBSMAP_L4);
    end
end

