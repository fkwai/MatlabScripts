function shuffleAll(dbName,outName,tInd)
% shuffle time steps and save order in shuffle.csv
% dbName='CONUSs4f1';
% outName='CONUSs4f1_SFy1';
% tInd=1:366;

%% pre-define
global kPath
dbDir=[kPath.DBSMAP_L3,dbName,kPath.s];
outDir=[kPath.DBSMAP_L3,outName,kPath.s];
mkdir(outDir);

varFile=[dbDir,'varLst.csv'];
varConstFile=[dbDir,'varConstLst.csv'];
crdFile=[dbDir,'crd.csv'];
timeFile=[dbDir,'time.csv'];

varLst=textread(varFile,'%s');
varConstLst=textread(varConstFile,'%s');
crd=csvread(crdFile);
t=csvread(timeFile);

%% generate random order
nt=length(t);
nGrid=size(crd,1);
sfMat=repmat([1:nt],[nGrid,1]);
for k=1:nGrid
    sfMat(k,tInd)=tInd(randperm(length(tInd)));
end
sfFile=[outDir,'shuffle.csv'];
dlmwrite(sfFile,sfMat,'precision',8);

%% Deal with each timeseries variables
for k=1:length(varLst)
    varName=varLst{k};
    disp(['Shuffling ', varName]);
    data=csvread([dbDir,varName,'.csv']);
    dataSF=zeros(nGrid,nt);
    for i=1:nGrid
        ord=sfMat(i,:);
        dataSF(i,:)=data(i,ord);
    end
    
    % % swap back
    % dataBack=zeros(nGrid,nt);
    % for i=1:nGrid
    %     ord=sfMat(i,:);
    %     dataBack(i,ord)=dataSF(i,:);
    % end
    
    outFile=[outDir,varName,'.csv'];
    dlmwrite(outFile,dataSF,'precision',8);
    
    fileStatName=[dbDir,varName,'_stat.csv'];
    outStatName=[outDir,varName,'_stat.csv'];
    copyfile(fileStatName,outStatName);
end

%% SMAP and SMAP_anomaly
smapLst={'SMAP','SMAP_anomaly'};
for k=1:length(smapLst)
    varName=smapLst{k};
    disp(['Shuffling ', varName]);
    data=csvread([dbDir,varName,'.csv']);
    dataSF=zeros(nGrid,nt);
    for i=1:nGrid
        ord=sfMat(i,:);
        dataSF(i,:)=data(i,ord);
    end
    
    outFile=[outDir,varName,'.csv'];
    dlmwrite(outFile,dataSF,'precision',8);
    
    fileStatName=[dbDir,varName,'_stat.csv'];
    outStatName=[outDir,varName,'_stat.csv'];
    copyfile(fileStatName,outStatName);
end

%% Copy time, crd, varLst, varConstLst
copyfile([dbDir,'time.csv'],[outDir,'time.csv']);
copyfile([dbDir,'crd.csv'],[outDir,'crd.csv']);
copyfile([dbDir,'varLst.csv'],[outDir,'varLst.csv']);
copyfile([dbDir,'varConstLst.csv'],[outDir,'varConstLst.csv']);

%% Copy const_var,const_var_stat, var_stat.
for k=1:length(varConstLst)
    fileName=[dbDir,'const_',varConstLst{k},'.csv'];
    outName=[outDir,'const_',varConstLst{k},'.csv'];
    copyfile(fileName,outName);
    fileStatName=[dbDir,'const_',varConstLst{k},'_stat.csv'];
    outStatName=[outDir,'const_',varConstLst{k},'_stat.csv'];
    copyfile(fileStatName,outStatName);
end

end