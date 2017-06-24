function splitSubset_interval(varName,dataName,interval,offset)
%split dataset to sub_xx

% varName='SMAP';
% saveFolder='E:\Kuai\rnnSMAP\Database\CONUS_sub4\';
% interval=3;
% offset=1;

global kPath
dirData=kPath.DBSMAP_L3_CONUS;
saveFolder=[kPath.DBSMAP_L3,dataName,kPath.s];
maskMat=load(kPath.maskSMAP_CONUS);

if ~isdir(saveFolder)
    mkdir(saveFolder)
end

% transfer to grid and fill to CONUS mask
[gridRaw,x,y,t]=csv2grid_SMAP(dirData,varName);
xx=maskMat.lon;
yy=maskMat.lat;
xx=str2num(num2str(xx,8));
yy=str2num(num2str(yy,8));
x=str2num(num2str(x,8));
y=str2num(num2str(y,8));
[C,indY1,indY2]=intersect(yy,y,'stable');
[C,indX1,indX2]=intersect(xx,x,'stable');
grid=ones(length(yy),length(xx),length(t))*-9999;
grid(indY1,indX1,:)=gridRaw;

%% pick grid by interval
gridSub=grid(offset:interval:end,offset:interval:end,:);
xxSub=xx(offset:interval:end);
yySub=yy(offset:interval:end);
dataSub=reshape(gridSub,[length(xxSub)*length(yySub),length(t)]);
ind=find(isnan(nanmean(dataSub,2)));
if isempty(strfind(varName,'const_'))
    dataSub=dataSub';
    dataSub(:,ind)=[];
else
    dataSub(ind)=[];
end

[lonSubMesh,latSubMesh]=meshgrid(xxSub,yySub);
lonSub=lonSubMesh(:);
latSub=latSubMesh(:);
lonSub(ind)=[];
latSub(ind)=[];

%[grid2] = data2grid3d( dataSub',lonSub,latSub);

%% save data
saveFile=[saveFolder,varName,'.csv'];
crdFile=[saveFolder,'crd.csv'];
statFile=[saveFolder,varName,'_stat.csv'];
timeFile=[saveFolder,'time.csv'];

dlmwrite(saveFile, dataSub,'precision',8);
copyfile([dirData,varName,'_stat.csv'],statFile);
if ~exist(crdFile,'file')
	dlmwrite(crdFile, [latSub,lonSub],'precision',8);
end
if ~exist(timeFile,'file')
	copyfile([dirData,'time.csv'],[saveFolder,'time.csv']);
end

end

