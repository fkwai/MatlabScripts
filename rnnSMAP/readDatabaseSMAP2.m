function [xOut,yOut,xStat,yStat] = readDatabaseSMAP2( dataName )
%read new SMAP database where each variable is saved in one file. 

%dataName='CONUS_sub4';

dataFolder='E:\Kuai\rnnSMAP\Database\Daily\';

% xField={'SoilM','Evap','Rainf','Tair','Wind','PSurf','Canopint','Snowf',...
%     'LWdown','SWdown','SWnet','LWnet','Wind'};
xField={'SoilM','Evap','Rainf','Tair','Wind','PSurf','Canopint','Snowf',...
    'SWnet','LWnet','Wind'};
% seems that NN only works for <18 fields...

%xField_const={'DEM','Slope','Sand','Silt','Clay','LULC','NDVI'};
xField_const={'DEM','Sand','Slope','LULC','NDVI'};
yField='SMAP';
nx=length(xField)+length(xField_const);

%% read t and crd
dirData=[dataFolder,dataName,'\'];
fileCrd=[dirData,'crd.csv'];
fileDate=[dirData,'date.csv'];
crd=csvread(fileCrd);
t=csvread(fileDate);
lat=crd(:,1);
lon=crd(:,2);

%% read Y
yFile=[dataFolder,dataName,'\',yField,'.csv'];
yStatFile=[dataFolder,dataName,'\',yField,'_stat.csv'];
yData=csvread(yFile);
yStatData=csvread(yStatFile);
yData(yData==-9999)=nan;
%[grid,xx,yy] = data2grid3d( yData,lon,lat);    % testify
yOut=yData;
yStat=yStatData;
[nt,ngrid]=size(yOut);

%% read X
xOut=zeros([nt,ngrid,nx]);
xStat=zeros([4,nx]);

for kk=1:length(xField)
    k=kk;
    xFile=[dataFolder,dataName,'\',xField{kk},'.csv'];
    xStatFile=[dataFolder,dataName,'\',xField{kk},'_stat.csv'];
    xData=csvread(xFile);
    xStatData=csvread(xStatFile);
    xOut(:,:,k)=xData;
    xStat(:,k)=xStatData;
end
for kk=1:length(xField_const)
    k=kk+length(xField);
    xFile=[dataFolder,dataName,'\const_',xField_const{kk},'.csv'];
    xStatFile=[dataFolder,dataName,'\const_',xField_const{kk},'_stat.csv'];
    xData=csvread(xFile);
    xStatData=csvread(xStatFile);
    xOut(:,:,k)=repmat(xData',[nt,1]);
    xStat(:,k)=xStatData;
    %[grid,xx,yy] = data2grid( xData,lon,lat);  
end

end

