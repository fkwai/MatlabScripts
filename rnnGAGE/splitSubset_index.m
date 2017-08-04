function indSub=splitSubset_index( varName,dataName,indSub )

global kPath
dirData=[kPath.DBSCAN,'CONUS',kPath.s];
saveFolder=[kPath.DBSCAN,dataName,kPath.s];

if ~isdir(saveFolder)
    mkdir(saveFolder)
end

%% pick grid by interval
dataFileCONUS=[dirData,varName,'.csv'];
crdFileCONUS=[dirData,'crd.csv'];
data=csvread(dataFileCONUS);
crd=csvread(crdFileCONUS);
dataSub=data(indSub,:);
crdSub=crd(indSub,:);

%% save data
saveFile=[saveFolder,varName,'.csv'];
crdFile=[saveFolder,'crd.csv'];
statFile=[saveFolder,varName,'_stat.csv'];
timeFile=[saveFolder,'time.csv'];

dlmwrite(saveFile, dataSub,'precision',8);
copyfile([dirData,varName,'_stat.csv'],statFile);
if ~exist(crdFile,'file')
	dlmwrite(crdFile,crdSub,'precision',8);
end

if ~exist(timeFile,'file')
	copyfile([dirData,'time.csv'],[saveFolder,'time.csv']);
end


end

