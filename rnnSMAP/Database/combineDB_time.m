function combineDB_time( dataNameLst,saveName,varargin)

% example

% rootDB=kPath.DBSMAP_L3;
% varLst=readVarLst([rootDB,'Variable',filesep,'varLst_Noah.csv']);
% varConstLst=readVarLst([rootDB,'Variable',filesep,'varConstLst_Noah.csv']);
% dataNameLst={'LongTerm8595_Core','LongTerm9505_Core','LongTerm0515_Core','CONUS_Core'};
% saveName='LongTermSite';

global kPath
varinTab={'rootDB',kPath.DBSMAP_L3;...
    'statDB','CONUS';... % suffix for all subsets
    'varName','varLst_Noah';...
    'varConstName','varConstLst_Noah';...
    };  
[rootDB,statDB,varName,varConstName]=...
    internal.stats.parseArgs(varinTab(:,1),varinTab(:,2), varargin{:});

dirSave=[rootDB,filesep,saveName,filesep];
if ~exist(dirSave,'dir')
    mkdir(dirSave);
end

varLst=readVarLst([rootDB,'Variable',filesep,varName,'.csv']);
varConstLst=readVarLst([rootDB,'Variable',filesep,varConstName,'.csv']);

%% time and crd
tnum=[];
for i =1:length(dataNameLst)
    dataName=dataNameLst{i};
    temp=csvread([rootDB,filesep,dataName,filesep,'time.csv']);
    tnum=[tnum;temp];    
end
tnum=unique(tnum);
timeFile=[rootDB,filesep,saveName,filesep,'time.csv'];
dlmwrite(timeFile,tnum,'precision',12);

copyCrdFile=[rootDB,filesep,dataNameLst{end},filesep,'crd.csv'];
saveCrdFile=[rootDB,filesep,saveName,filesep,'crd.csv'];
copyfile(copyCrdFile,saveCrdFile)    
crd=csvread(saveCrdFile);


%% ts variable
parfor k=1:length(varLst)
    data=zeros(size(crd,1),length(tnum))-9999;
    varName=varLst{k};    
    tic
    for i =1:length(dataNameLst)
        dataName=dataNameLst{i};
        dataTemp=csvread([rootDB,filesep,dataName,filesep,varName,'.csv']);
        tTemp=csvread([rootDB,filesep,dataName,filesep,'time.csv']);
        [~,indTemp,indAll]=intersect(tTemp,tnum);
        data(:,indAll)=dataTemp(:,indTemp);
    end    
    % remove unique time
    
    dataFile=[rootDB,filesep,saveName,filesep,varName,'.csv'];
    dlmwrite(dataFile,data,'precision',8);
    copyStatFile=[rootDB,filesep,statDB,filesep,varName,'_stat.csv'];
    saveStatFile=[rootDB,filesep,saveName,filesep,varName,'_stat.csv'];
    copyfile(copyStatFile,saveStatFile)    
    disp(varName)        
    toc
end

%% const variable
for k=1:length(varConstLst)
    varName=['const_',varConstLst{k}];
    copyFile=[rootDB,filesep,dataNameLst{end},filesep,varName,'.csv'];
    saveFile=[rootDB,filesep,saveName,filesep,varName,'.csv'];
    copyfile(copyFile,saveFile)    
    copyStatFile=[rootDB,filesep,statDB,filesep,varName,'_stat.csv'];
    saveStatFile=[rootDB,filesep,saveName,filesep,varName,'_stat.csv'];
    copyfile(copyStatFile,saveStatFile)    
end

%% crd
copyCrdFile=[rootDB,filesep,dataNameLst{end},filesep,'crd.csv'];
saveCrdFile=[rootDB,filesep,saveName,filesep,'crd.csv'];
copyfile(copyCrdFile,saveCrdFile)    

%% subset file
subsetFile=[rootDB,filesep,'Subset',filesep,saveName,'.csv'];
dlmwrite(subsetFile,saveName,'');
dlmwrite(subsetFile, -1,'-append');

end

