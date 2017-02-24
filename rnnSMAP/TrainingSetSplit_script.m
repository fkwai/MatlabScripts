
%% this script is for global
% when do global previous code not work. 

%% Construct continant mat file
shapefile='Y:\Maps\WorldContinents.shp';
shape=shaperead(shapefile);
grid=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
load('Y:\GLDAS\maskGLDAS_025.mat');


mask1d=mask(:);
indMask=find(mask1d==1);

[xx,yy]=meshgrid(grid.lon,grid.lat);

xland=xx(indMask);
yland=yy(indMask);
cont=zeros(length(indMask),1);
for i=1:length(shape)
    i
    indpoly=[0,find(isnan(shape(i).X))];
    for j=1:length(indpoly)-1
        X=shape(i).X(indpoly(j)+1:indpoly(j+1)-1);
        Y=shape(i).Y(indpoly(j)+1:indpoly(j+1)-1);
        inout = int32(zeros(size(xland)));
        pnpoly(X,Y,xland,yland,inout);
        inout=double(inout);
        cont(inout==1)=i;
    end
end


%% make lat > 60 to be 0
grid=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
latind=find(grid.lat>60);

contmap1d=zeros(length(mask(:)),1);
contmap1d(indMask)=cont;
contmap=reshape(contmap1d,size(mask));

contmap(latind,:)=0;
contmap1d=contmap(:);
cont2=contmap1d(indMask);

save Y:\Maps\matfile\WorldContinent025.mat cont cont2

%% Split all grid into trainning set and test set based on continant.
% also, pick one cell every 5*5 grids
grid=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
load('Y:\Maps\matfile\WorldContinent025.mat')
load('Y:\GLDAS\maskGLDAS_025.mat');
folder='Y:\Kuai\rnnSMAP\output\trainNA\';

trainfile=[folder,'train.csv'];
testfile=[folder,'test.csv'];
maskSub=zeros(size(mask));
maskSub(2:3:end,2:3:end)=1;
mask1d=mask(:);
indMask=find(mask1d==1);
maskSub1d=maskSub(:);
bSub=maskSub1d(indMask);
indtrain=find(cont2==2&bSub==1);
indtest=find(cont2~=2&bSub==1);
dlmwrite(trainfile,indtrain,'precision',8);
dlmwrite(testfile,indtest,'precision',8);

trainfile=[folder,'train2.csv'];
testfile=[folder,'test2.csv'];
maskSub=zeros(size(mask));
maskSub(4:6:end,4:6:end)=1;
mask1d=mask(:);
indMask=find(mask1d==1);
maskSub1d=maskSub(:);
bSub=maskSub1d(indMask);
indtrain=find(cont2==2&bSub==1);
indtest=find(cont2~=2&bSub==1);
dlmwrite(trainfile,indtrain,'precision',8);
dlmwrite(testfile,indtest,'precision',8);




