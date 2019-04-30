function [varLst,varConstLst]=scanDatabaseGlobal(dbName,writeVar,varargin)
% this function will scan given database and write varLst.csv and varConstLst.csv

global kPath

pnames={'dirRoot','doLog','stdB'};
dflts={kPath.DBSMAP_L3_Global,0,0};
[dirRoot,doLog,stdB]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

dirDB=[dirRoot,dbName,filesep];
dirVar=[dirRoot,'Variable',filesep];

%% get year lst
dirLst=dir(dirDB);
yrLst=[];
for k=1:length(dirLst)
    if dirLst(k).isdir && ...
            ~strcmp(dirLst(k),'.') && ...
            ~strcmp(dirLst(k),'..') && ...
            ~strcmp(dirLst(k),'const')
        yrLst=[yrLst;str2num(dirLst(k).name)];
    end
end

%% time series variables
varLstTemp={};
for iY=1:length(yrLst)
    dirDByear=[dirDB,filesep,num2str(yrLst(iY)),filesep];
    fileLst=dir([dirDByear,'*.csv']);
    for k=1:length(fileLst)
        varName=fileLst(k).name(1:end-4);
        if ~strcmp(varName,'time') && ~strcmp(varName,'timeStr')
            varLstTemp=[varLstTemp;varName];
        end
    end
end
varLst=unique(varLstTemp);

%% const variables
varConstLstTemp={};
dirDBconst=[dirDB,filesep,'const',filesep];
fileLst=dir([dirDBconst,'*.csv']);
for k=1:length(fileLst)
    varName=fileLst(k).name(1:end-4);
    varConstLstTemp=[varConstLstTemp;varName];
end
varConstLst=unique(varConstLstTemp);

%% write variable files
if writeVar==1
    if ~isdir(dirVar)
        mkdir(dirVar)
    end
    fid=fopen([dirVar,'varLst.csv'],'w');
    fprintf(fid,'%s\n',varLst{:});
    fclose(fid);
    
    fid=fopen([dirVar,'varConstLst.csv'],'w');
    fprintf(fid,'%s\n',varConstLst{:});
    fclose(fid);
end

%% set std lower bound
if stdB>0
    dirStat=[dirRoot,'Statistics',filesep];
    for k=1:length(varLst)
        varName=varLst{k};
        statFile=[dirStat,varName,'_stat.csv'];
        stat=csvread(statFile);
        if stat(4)<stdB            
            copyfile(statFile,[dirStat,varName,'_stat_',date,'.csv'])
            stat(4)=1;
            dlmwrite(statFile, stat,'precision',8);
        end
    end
    for k=1:length(varConstLst)
        varName=varConstLst{k};
        statFile=[dirStat,'const_',varName,'_stat.csv'];
        stat=csvread(statFile);
        if stat(4)<stdB
            copyfile(statFile,[dirStat,'const_',varName,'_stat_',date,'.csv'])
            stat(4)=1;
            dlmwrite(statFile, stat,'precision',8);
        end
    end
end

