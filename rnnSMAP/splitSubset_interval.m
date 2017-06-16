function splitSubset_interval(varName,saveFolder,interval,offset)
%split dataset to sub_xx

% varName='SMAP';
% saveFolder='E:\Kuai\rnnSMAP\Database\CONUS_sub4\';
% interval=3;
% offset=1;

dirData='H:\Kuai\rnnSMAP\Database\Daily\CONUS\';

if ~isdir(saveFolder)
    mkdir(saveFolder)
end

if isempty(strfind(varName,'const_'))
    [grid,xx,yy,t]=csv2grid_SMAP(dirData,varName,1);
else
    [grid,xx,yy,t]=csv2grid_SMAP(dirData,varName,2);
end

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
dlmwrite(saveFile, dataSub,'precision',8);
dlmwrite(crdFile, [latSub,lonSub],'precision',8);

%% copy stat and t
copyfile([dirData,varName,'_stat.csv'],[saveFolder,varName,'_stat.csv'])
copyfile([dirData,'date.csv'],[saveFolder,'date.csv'])


end

