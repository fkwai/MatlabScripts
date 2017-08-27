
%% NLDAS 
% load a NLDAS matfile
load('H:\Kuai\rnnNLDAS\LSOIL_0-10.mat')
[lonMesh,latMesh]=meshgrid(lon,lat);
mask=double(~isnan(nanmean(data,3)));

% bounding box
boundingbox=[-125,-66;25,50];
indY=find(lat>boundingbox(2,1)&lat<boundingbox(2,2));
indX=find(lon>boundingbox(1,1)&lon<boundingbox(1,2));
mask(indY,indX)=mask(indY,indX)+1;

% v8f1
vv=10;
ff=1;
mask(ff:vv:end,ff:vv:end)=mask(ff:vv:end,ff:vv:end)+1;
mask=double(mask==3);

maskInd=zeros(size(mask));
maskInd(mask==1)=1:sum(mask(:));
lon1D=lonMesh(mask==1);
lat1D=latMesh(mask==1);

global kPath
maskFile=[kPath.NLDAS,'maskNLDASv',num2str(vv),'f',num2str(ff),'.mat'];
save(maskFile,'lat','lat1D','latMesh','lon','lon1D','lonMesh','mask','maskInd')
