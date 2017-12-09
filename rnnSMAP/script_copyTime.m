% Time.csv is wrong for all database. Copy updated one into them. 

dirDB='/mnt/sdb1/Kuai/rnnSMAP_inputs/hucv2n6/';
timeFile=[kPath.DBSMAP_L3,filesep,'CONUS',filesep,'time.csv'];

subDirDB=dir(dirDB);

skipNameLst={'.','..','Subset','Varible',...
    'CONUS','LongTerm_2yr','LongTerm_35yr','hlr'};
for k=1:length(subDirDB)
    subDirDB(k).name
    if ~ismember(subDirDB(k).name,skipNameLst) && subDirDB(k).isdir
        newTimeFile=[dirDB,subDirDB(k).name,filesep,'time.csv'];
        copyfile(timeFile,newTimeFile);
    end
end