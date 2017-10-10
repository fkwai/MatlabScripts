
flagTab=readtable([kPath.SMAP,'SMAP_L3_flag.csv']);
dirDB=kPath.DBSMAP_L3_CONUS;

dataSMAP=csvread([dirDB,'SMAP.csv']);
nanSMAP=dataSMAP==-9999;

k=1;
for k=1:length(flagTab.Filename)
    fileName=[dirDB,flagTab.Filename{k},'.csv'];
    
    data=csvread(fileName);
    data(nanSMAP)=nan;
    vecStd=nanstd(data,1,2);
    disp([flagTab.Filename{k},': ',num2str(length(find(vecStd>1e-10)))]);
end