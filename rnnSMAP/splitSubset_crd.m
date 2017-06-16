function splitSubset_crd(varName,crdLst,saveFolder)
% split a subset from CONUS database for given coordinate list
% crdlst -> [lat1, lon1; lat2, lon2;]
% varName='SMAP';
% saveFolder='E:\Kuai\rnnSMAP\Database\cell_IL\';
% crdLst=[40.875,-88.125];

dirData='E:\Kuai\rnnSMAP\Database\Daily\CONUS\';

if ~isdir(saveFolder)
    mkdir(saveFolder)
end

%% read data
fileData=[dirData,varName,'.csv'];
fileCrd=[dirData,'crd.csv'];
data=csvread(fileData);
crd=csvread(fileCrd);

%% find grid
ind=zeros(size(crdLst,1),1);
for k=1:size(crdLst,1)
    ind(k)=find(crdLst(k,1)==crd(:,1) & crdLst(k,2)==crd(:,2));    
end

%% subset of data
if isempty(strfind(varName,'const_'))
    dataSub=data(:,ind);
else
    dataSub=data(ind);
end

%% save data
saveFile=[saveFolder,varName,'.csv'];
crdFile=[saveFolder,'crd.csv'];
dlmwrite(saveFile, dataSub,'precision',8);
dlmwrite(crdFile, crdLst,'precision',8);

%% copy stat and t
copyfile([dirData,varName,'_stat.csv'],[saveFolder,varName,'_stat.csv'])
copyfile([dirData,'date.csv'],[saveFolder,'date.csv'])


end

