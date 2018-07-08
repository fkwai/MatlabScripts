global kPath
rootDB=kPath.DBSMAP_L4_NA;
yrLst=2000:2017;

%% get all database
folderLst=dir(rootDB);
dataNameLst=[];
for k=1:length(folderLst)
    if ~strcmp(folderLst(k).name,'.') && ...
            ~strcmp(folderLst(k).name,'..') && ...
            ~strcmp(folderLst(k).name,'Statistics') && ...
            ~strcmp(folderLst(k).name,'Subset') && ...
            ~strcmp(folderLst(k).name,'Variable')
        dataNameLst=[dataNameLst;{folderLst(k).name}];
    end
end

%%
for iD=1:length(dataNameLst)
    for iY=1:length(yrLst)
        folder=[rootDB,filesep,dataNameLst{iD},filesep,num2str(yrLst(iY)),filesep];
        timeFile=[folder,'time.csv'];
        timeStrFile=[folder,'timeStr.csv'];
        if exist(timeFile,'file')
            tnum=csvread([folder,'time.csv']);
            tStr=datestr(tnum,'yyyy-mm-dd');
            fid = fopen(timeStrFile, 'w');
            for k=1:length(tnum)
                fprintf(fid, '%s\n',tStr(k,:));
            end
            fclose(fid);
        end
    end
end