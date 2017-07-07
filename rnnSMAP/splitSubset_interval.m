function splitSubset_interval(varName,dataName,interval,offset)
%split dataset to sub_xx

global kPath
dirData=kPath.DBSMAP_L3_CONUS;
saveFolder=[kPath.DBSMAP_L3,dataName,kPath.s];
maskMat=load(kPath.maskSMAP_CONUS);

if ~isdir(saveFolder)
    mkdir(saveFolder)
end

%% pick grid by interval
dataFileCONUS=[dirData,varName,'.csv'];
crdFileCONUS=[dirData,'crd.csv'];
data=csvread(dataFileCONUS);
crd=csvread(crdFileCONUS);
maskIndSub=maskMat.maskInd(offset:interval:end,offset:interval:end);
indSub=maskIndSub(:);
indSub(indSub==0)=[];
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

