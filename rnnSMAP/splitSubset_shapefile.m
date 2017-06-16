function splitSubset_shapefile(varName,shape,saveFolder,varargin )
% split dataset by shapefile

% example: 
% shape=shaperead('Y:\Maps\State\OK.shp');
% varName='SMAP';
% varargin{1} -> subset. Pick a grid every varargin{1} grids
% varargin{2} -> offset

dirData='H:\Kuai\rnnSMAP\Database\Daily\CONUS\';

dSub=1;
offset=1;
if ~isempty(varargin)
    dSub=varargin{1};    
end
if length(varargin)>1
    offset=varargin{2};    
end

if ~isdir(saveFolder)
    mkdir(saveFolder)
end

%% find intersection of shape
if isempty(strfind(varName,'const_'))
    [grid,xx,yy,t]=csv2grid_SMAP(dirData,varName,1);
else
    [grid,xx,yy,t]=csv2grid_SMAP(dirData,varName,2);
end
maskShape = GridinShp(shape, xx,yy,0.25,1 );    % hard code to 0.25 for CONUS database

%% pick by intervel
maskSub=zeros(size(maskShape));
maskSub(offset:dSub:end,offset:dSub:end)=1;
mask=maskSub.*maskShape;

%% grid to data table
data=reshape(grid,[length(xx)*length(yy),length(t)]);
maskTab=reshape(mask,[length(xx)*length(yy),1]);
ind=find(maskTab);
if isempty(strfind(varName,'const_'))
    data=data';
    dataSub=data(:,ind);
else
    dataSub=data(ind);
end

%% crd
[lonMesh,latMesh]=meshgrid(xx,yy);
lonVec=lonMesh(:);
latVec=latMesh(:);
lonSub=lonVec(ind);
latSub=latVec(ind);

%% save data
saveFile=[saveFolder,varName,'.csv'];
crdFile=[saveFolder,'crd.csv'];
dlmwrite(saveFile, dataSub,'precision',8);
dlmwrite(crdFile, [latSub,lonSub],'precision',8);

%% copy stat and t
copyfile([dirData,varName,'_stat.csv'],[saveFolder,varName,'_stat.csv'])
copyfile([dirData,'date.csv'],[saveFolder,'date.csv'])

end

