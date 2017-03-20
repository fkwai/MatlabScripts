function splitSubset_interval(varName,saveFolder,interval,offset)
%split dataset to sub_xx

% varName='SMAP';
% saveFolder='E:\Kuai\rnnSMAP\Database\CONUS_sub4\';
% interval=3;
% offset=1;
% 
dirData='E:\Kuai\rnnSMAP\Database\CONUS\';

if ~isdir(saveFolder)
    mkdir(saveFolder)
end

if isempty(strfind(varName,'const_'))
    [grid,xx,yy,t]=csv2grid_SMAP(dirData,varName,1);
else
    [grid,xx,yy,t]=csv2grid_SMAP(dirData,varName,2);
end

gridSub=grid(offset:interval:end,offset:interval:end,:);
xxSub=xx(offset:interval:end);
yySub=yy(offset:interval:end);
dataSub=reshape(gridSub,[length(xxSub)*length(yySub),length(t)]);

[lonSubMesh,latSubMesh]=meshgrid(xxSub,yySub);
lonSub=lonSubMesh(:);
latSub=latSubMesh(:);
ind=find(isnan(nanmean(dataSub,2)));
dataSub(ind,:)=[];
lonSub(ind)=[];
latSub(ind)=[];

%[grid2,xx,yy] = data2grid3d( dataSub,lonSub,latSub);
%[grid2,xx,yy] = data2grid( dataSub,lonSub,latSub);


saveFile=[saveFolder,varName,'.csv'];
crdFile=[saveFolder,'crd.csv'];
dlmwrite(saveFile, dataSub,'precision',8);
dlmwrite(crdFile, [latSub,lonSub],'precision',8);



end

