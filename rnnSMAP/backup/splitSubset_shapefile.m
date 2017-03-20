function [output,indRegion]=splitSubset_shapefile( shapefile,saveName,varargin)
% split gridInd by shapefile

% example: 
% shapefile='Y:\Maps\CONUS.shp';
% saveName='E:\Kuai\rnnSMAP\output\indFile\CONUS';
% varargin{1} -> subset. Pick a grid every varargin{1} grids

dSub=1;
offset=0;
if ~isempty(varargin)
    dSub=varargin{1};    
end
if length(varargin)>1
    offset=varargin{2};    
end

load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
cellsize=lat(1)-lat(2);
output=zeros(length(lat),length(lon));
shape=shaperead(shapefile);
for k=1:length(shape)
    k
    temp = GridinShp(shape(k), lon,lat,cellsize,1 );
    output=output+temp*k;
end

maskInd = mask2Ind_SMAP;
maskInd=maskInd(1+offset:dSub:end,1+offset:dSub:end);
output=output(1+offset:dSub:end,1+offset:dSub:end);

indRegion={};
for k=1:length(shape)
    indTemp=maskInd(output==k);
    indTemp(indTemp==0)=[];
    dlmwrite([saveName,num2str(k),'.csv'],indTemp,'precision',8);    
    indRegion{k}=indTemp;
%     crdFile='Y:\Kuai\rnnSMAP\Database\tDB_SMPq\crdIndex.csv';
%     crd=csvread(crdFile);
%     plot(crd(indRegion{k},2),crd(indRegion{k},1),'*','color',rand(1,3));hold on
%     plot(shape(k).X,shape(k).Y,'-k');hold on
end

end

