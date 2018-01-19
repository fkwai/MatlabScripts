function subsetSplit(subsetName,varargin)
% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.
% subset will be wrote as an individual database instead of a index file.
% And the inds in subset file is replace by -1

global kPath
if isempty(kPath)
    initPath workstation
end    

pnames={'dirRoot','varLst','varConstLst'};
dflts={kPath.DBSMAP_L3,'varLst','varConstLst'};
[dirRoot,varLstName,varConstLstName]=internal.stats.parseArgs(pnames, dflts, varargin{:});


%% read variable list
varFile=[dirRoot,'Variable',kPath.s,varLstName,'.csv'];
varConstFile=[dirRoot,'Variable',kPath.s,varConstLstName,'.csv'];
varLst=textread(varFile,'%s');
varConstLst=textread(varConstFile,'%s');

%% read subset index
subsetFile=[dirRoot,'Subset',filesep,subsetName,'.csv'];
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
rootName=C{1}{1};
C = textscan(fid,'%f');
indSub=C{1};
fclose(fid);

%% write crd and time
rootFolder=[dirRoot,rootName,filesep];
saveFolder=[dirRoot,subsetName,filesep];
if ~isdir(saveFolder)
    mkdir(saveFolder)
end

crdFileRoot=[rootFolder,'crd.csv'];
crd=csvread(crdFileRoot);
crdSub=crd(indSub,:);
crdFile=[saveFolder,'crd.csv'];
dlmwrite(crdFile,crdSub,'precision',8);

timeFile=[saveFolder,'time.csv'];
copyfile([rootFolder,'time.csv'],timeFile);

%% time series variable
parfor k=1:length(varLst)
    disp([subsetName,' ',varLst{k}])
    tic
    subsetSplit_var(varLst{k},rootFolder,saveFolder,indSub)
    toc
end

%% constant variable
for k=1:length(varConstLst)
    disp([subsetName,' ',varConstLst{k}])
    tic
    subsetSplit_var(['const_',varConstLst{k}],rootFolder,saveFolder,indSub)
    toc
end

%% SMAP
%{
disp([subsetName,' SMAP'])
tic
subsetSplit('SMAP',subsetName)
toc
%}


%% replace the subset file
dlmwrite(subsetFile,subsetName,'');
dlmwrite(subsetFile, -1,'-append');

end

function subsetSplit_var(varName,rootFolder,saveFolder,indSub)

% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.

% write a subset database for given subset index and variable name

%% pick data by indSub
dataFileRoot=[rootFolder,varName,'.csv'];
data=csvread(dataFileRoot);
dataSub=data(indSub,:);

%% save data
saveFile=[saveFolder,varName,'.csv'];
statFile=[saveFolder,varName,'_stat.csv'];
dlmwrite(saveFile, dataSub,'precision',8);
copyfile([rootFolder,varName,'_stat.csv'],statFile);

end



