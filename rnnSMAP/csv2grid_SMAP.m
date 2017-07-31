function [ grid,xx,yy,t ] = csv2grid_SMAP(dirData,varName)
% convert csv which torch can learn from to grid
% read directory are hard coded as kPath.DBSMAP_L3 
% mask are hard coded to kPath.maskSMAP_CONUS 

% dirData='H:\Kuai\rnnSMAP\Database_SMAPgrid\Daily\CONUS';
% varName='SMAP';

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

end

function b = startsWith(s, pat)
sl = length(s);
pl = length(pat);
b = (sl >= pl && strcmp(s(1:pl), pat)) || isempty(pat);
end

function b = endsWith(s, pat)
sl = length(s);
pl = length(pat);
b = (sl >= pl && strcmp(s(end-pl+1:end), pat)) || isempty(pat);
end



