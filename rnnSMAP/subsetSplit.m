function subsetSplit(varName,subsetName)
% do split of subset of gridSMAP, L3, Daily, CONUS of all datset from
% reading varLst and varConstLst and SMAP.

% write a subset database for given subset index and variable name

global kPath

%% read subset index
subsetFile=[kPath.DBSMAP_L3,'Subset',kPath.s,subsetName,'.csv'];
fid=fopen(subsetFile);
C = textscan(fid,'%s',1);
rootName=C{1}{1};
C = textscan(fid,'%f');
indSub=C{1};
fclose(fid);

%% pick data by indSub
rootFolder=[kPath.DBSMAP_L3,rootName,kPath.s];
dataFileRoot=[rootFolder,varName,'.csv'];
crdFileRoot=[rootFolder,'crd.csv'];
data=csvread(dataFileRoot);
crd=csvread(crdFileRoot);
dataSub=data(indSub,:);
crdSub=crd(indSub,:);

%% save data
saveFolder=[kPath.DBSMAP_L3,subsetName,kPath.s];
if ~isdir(saveFolder)
    mkdir(saveFolder)
end

saveFile=[saveFolder,varName,'.csv'];
crdFile=[saveFolder,'crd.csv'];
statFile=[saveFolder,varName,'_stat.csv'];
timeFile=[saveFolder,'time.csv'];

dlmwrite(saveFile, dataSub,'precision',8);
copyfile([rootFolder,varName,'_stat.csv'],statFile);
if ~exist(crdFile,'file')
	dlmwrite(crdFile,crdSub,'precision',8);
end

if ~exist(timeFile,'file')
	copyfile([rootFolder,'time.csv'],[saveFolder,'time.csv']);
end

