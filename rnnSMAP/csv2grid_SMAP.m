function [ grid,xx,yy,t ] = csv2grid_SMAP( dirData,varName,opt )

% dirData='E:\Kuai\rnnSMAP\Database\CONUS\';
% varName='SMAP';
% opt==1 -> sequence; 2-> constant

fileData=[dirData,varName,'.csv'];
fileCrd=[dirData,'crd.csv'];
fileDate=[dirData,'date.csv'];

data=csvread(fileData);
crd=csvread(fileCrd);
t=csvread(fileDate);
lat=crd(:,1);
lon=crd(:,2);

if opt==1
    [grid,xx,yy] = data2grid3d( data,lon,lat);
elseif opt==2
    [grid,xx,yy] = data2grid(data,lon,lat);
    t=1;
end


end

