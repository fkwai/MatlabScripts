function [ grid,xx,yy,t ] = csv2grid_SMAP( dirData,varName )

% dirData='H:\Kuai\rnnSMAP\Database\Daily\CONUS\';
% varName='SMAP';
% opt==1 -> sequence; 2-> constant

fileData=[dirData,varName,'.csv'];
fileCrd=[dirData,'crd.csv'];
fileDate=[dirData,'time.csv'];

data=csvread(fileData);
crd=csvread(fileCrd);
t=csvread(fileDate);
lat=crd(:,1);
lon=crd(:,2);

if ~startsWith(varName,'const_')
    [grid,xx,yy] = data2grid3d(data,lon,lat);
else
    [grid,xx,yy] = data2grid(data,lon,lat);
    t=1;
end



