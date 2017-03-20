%% orgnize data for CART learning of nash. 

folder='Y:\Kuai\rnnSMAP\CART\';
NLDASfolder='Y:\NLDAS\matfile\monthly\NOAH\';
fileList=dir([NLDASfolder,'*.mat']);
testFile='Y:\Kuai\rnnSMAP\output\trainNA3\train.csv';
testInd=csvread(testFile);

%% start
grid=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\crdGLDAS025.mat');
load('Y:\GLDAS\maskGLDAS_025.mat');
tnum=grid.tnum;
mask1d=mask(:);
indMask=find(mask1d==1);
[xx,yy]=meshgrid(grid.lon,grid.lat);
testIndMask=indMask(testInd);
testX=xx(testIndMask);
testY=yy(testIndMask);
testLon=unique(testX);
testLat=flipud(unique(testY));
cellsize=min(min(testLon(2:end)-testLon(1:end-1)),min(testLat(1:end-1)-testLat(2:end)));
lon=min(testLon):cellsize:max(testLon);
lat=max(testLat):-cellsize:min(testLat);

%% orgnize NLDAS data
% Data=zeros(length(testInd),length(fileList))*nan;
% field={};
% 
% for k=1:length(fileList)
%     tic
%     k
%     fileName=fileList(k).name;
%     fieldName=fileName(1:end-4);
%     field=[field,fieldName];
%     temp=load([NLDASfolder,fileName]);
%     for i=1:length(testInd)
%         cellsize=0.125;
%         ind=find(temp.crd(:,1)>testX(i)-cellsize & ...
%             temp.crd(:,1)<testX(i)+cellsize & ...
%             temp.crd(:,2)>testY(i)-cellsize & ...
%             temp.crd(:,2)<testY(i)+cellsize);
%         if ~isempty(ind)
%             tempMean=meanALL(temp.(fieldName)(ind,:));
%             Data(i,k)=tempMean;
%         end
%     end
%     toc
% end
% 
% save([folder,'data.mat'],'Data','field')

%% write to csv
data=load([folder,'dataNLDAS.mat'],'Data','field');
xData=data.Data;
field=data.field;
load('Y:\Kuai\rnnSMAP\output\trainNA2\Nash_train_train.mat','nash_ys','nashAll')
yData=nashAll;
testMat=sum([xData,yData],2);
ind=find(~isnan(testMat)&~isinf(testMat));
xMat=xData(ind,:);
yMat=yData(ind,:);
yMat(yMat<-10)=-10;
crd=[testY(ind),testX(ind)];
save([folder,'data1.mat'],'xMat','yMat','crd','field')

yData=nash_ys';
testMat=sum([xData,yData],2);
ind=find(~isnan(testMat)&~isinf(testMat));
xMat=xData(ind,:);
yMat=yData(ind,:);
yMat(yMat<-10)=-10;
crd=[testY(ind),testX(ind)];
save([folder,'data0.mat'],'xMat','yMat','crd','field')

load('Y:\Kuai\rnnSMAP\output\trainNA3\stat_comb.mat')
[nashBest,bestModel]=max(nashLSTM,[],2);
yData=nashBest;
testMat=sum([xData,yData],2);
ind=find(~isnan(testMat)&~isinf(testMat));
xMat=xData(ind,:);
yMat=yData(ind,:);
yMat(yMat<-10)=-10;
crd=[testY(ind),testX(ind)];
save([folder,'data2.mat'],'xMat','yMat','crd','field')

load('Y:\Kuai\rnnSMAP\output\trainNA3\stat_comb.mat')
yData=nashBest-nashGLDAS;
testMat=sum([xData,yData],2);
ind=find(~isnan(testMat)&~isinf(testMat));
xMat=xData(ind,:);
yMat=yData(ind,:);
yMat(yMat<-10)=-10;
crd=[testY(ind),testX(ind)];
save([folder,'data3.mat'],'xMat','yMat','crd','field')



