x=-179.5:1:179.5;
y=[89.5:-1:-89.5]';
[xx,yy]=meshgrid(x,y);

soilx=-179.75:0.5:179.75;
soily=[89.75:-0.5:-89.75]';
[soilxx,soilyy]=meshgrid(soilx,soily);

load('E:\Kuai\rnnGRACE\mapSILT.mat')
load('E:\Kuai\rnnGRACE\mapSAND.mat')
load('E:\Kuai\rnnGRACE\mapCLAY.mat')

mapSILT_T(isnan(mapSILT_T))=0;
mapSAND_T(isnan(mapSAND_T))=0;
mapCLAY_T(isnan(mapCLAY_T))=0;
silt=interp2(soilxx,soilyy,mapSILT_T,xx,yy);
sand=interp2(soilxx,soilyy,mapSAND_T,xx,yy);
clay=interp2(soilxx,soilyy,mapCLAY_T,xx,yy);

NDVI=load('Y:\GIMMS\NDVI_avg.mat');
ndx=NDVI.lon;
ndy=NDVI.lat;
[ndxx,ndyy]=meshgrid(ndx,ndy);
ndvi=interp2(ndxx,ndyy,NDVI.NDVI,xx,yy);

mask=load('indMask.mat');

SiltMat=zeros(length(mask.indMask),144);
SandMat=zeros(length(mask.indMask),144);
ClayMat=zeros(length(mask.indMask),144);
NdviMat=zeros(length(mask.indMask),144);

for i=1:length(mask.indMask)
    ind=mask.indMask(i);
    mx=mask.x(ind);
    my=mask.y(ind);    
    indx=find(x==mx);
    indy=find(y==my);
    SiltMat(i,:)=silt(indy,indx);
    SandMat(i,:)=sand(indy,indx);
    ClayMat(i,:)=clay(indy,indx);
    NdviMat(i,:)=ndvi(indy,indx);
end

%% save 
saveDir='E:\Kuai\rnnGRACE\data\';
prefix='gridTab';
perc=10;
fieldList={'Silt','Sand','Clay','Ndvi'};
for i=1:length(fieldList)
    i
    ff=fieldList{i};
    eval(['data=',ff,'Mat',';'])
    dlmwrite([saveDir,prefix,ff,'.csv'], data, 'precision',16);
    [data_norm,lb,ub,data_mean]=normalize_perc(data,perc);
    dlmwrite([saveDir,prefix,ff,'_norm.csv'], data_norm, 'precision',16);
end
