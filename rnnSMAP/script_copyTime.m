% Time.csv is wrong for all database. Copy updated one into them. 

dirDB=kPath.DBSMAP_L3;
timeFile=[kPath.DBSMAP_L3,filesep,'CONUS',filesep,'time.csv'];

subDirDB=dir(dirDB);

skipNameLst={'.','..','Subset','Varible',...
    'CONUS','LongTerm_2yr','LongTerm_35yr','hlr'};
for k=1:length(subDirDB)
    subDirDB(k).name
    if ~ismember(subDirDB(k).name,skipNameLst)
        newTimeFile=[dirDB,subDirDB(k).name,filesep,'time.csv'];
        copyfile(timeFile,newTimeFile);
    end
end