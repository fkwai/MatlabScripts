
global kPath
rootDB=kPath.DBSMAP_L3_NA;
yrLst=2000:2016;

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
        fileLst=dir(folder);
        fieldNameLst=[];
        for k=1:length(fileLst)
            if ~strcmp(fileLst(k).name,'.') && ...
                    ~strcmp(fileLst(k).name,'..') && ...
                    ~strcmp(fileLst(k).name,'time.csv')
                fieldNameLst=[fieldNameLst;{fileLst(k).name(1:end-4)}];
            end
        end
        tnum=csvread([folder,'time.csv']);
        sdstr=datestr(tnum(1),'mmdd');
        edstr=datestr(tnum(end),'mmdd');
        if strcmp(sdstr,edstr)
            tnum=tnum(1:end-1);
            dlmwrite([folder,'time.csv'],tnum,'precision',12);
        end
        for k=1:length(fieldNameLst)
            tic
            dataFile=[folder,fieldNameLst{k},'.csv'];
            data=csvread(dataFile);
            if size(data,2)==length(tnum)+1
%                 dlmwrite(dataFile,data(:,1:end-1),'precision',8);
                disp([dataNameLst{iD},' ',fieldNameLst{k},' ',num2str(yrLst(iY)),' ',num2str(size(data,2))])
            end
            disp([dataNameLst{iD},' ',fieldNameLst{k},' ',num2str(yrLst(iY)),' ',num2str(toc)])
        end
    end
end