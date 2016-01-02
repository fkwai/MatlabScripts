function [grid,lon,lat,cellsize]= readNDVItif( file )
% read NDVI grid file. 
% readGrid.m can not deal with it now. 

% example:
%   file='E:\Kuai\DataAnaly\GIMMS\avg.tif';

[grid, info] = geotiffread(file);

%matlab2014
% cellsize=info.CellExtentInLatitude; 
% lon=info.LongitudeLimits(1)+cellsize/2:cellsize:...
%     info.LongitudeLimits(2)-cellsize/2;
% lat=info.LatitudeLimits(2)-cellsize/2:-cellsize:...
%     info.LatitudeLimits(1);

%matlab2013a
cellsize=info.DeltaLon;
lon=info.Lonlim(1)+cellsize/2:cellsize:...
    info.Lonlim(2)-cellsize/2;
lat=info.Latlim(2)-cellsize/2:-cellsize:...
    info.Latlim(1);
end

