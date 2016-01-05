function mask = GridMaskofHUC( shapefile,x,y,cellsize,factor )
%   return a mask of grid that percentage that inside each polygon of a shapefile

%   shapefile: name of .shp file of HUC. (E:\work\DataAnaly\HUC\HUC2 and HUC4)
%   x: x coordinate of all cells (ordered)
%   y: y coordinate of all cells (ordered)
%   cellsize: cell size of degree
%   factor: finner factor. Ex, 16 means use a cellsize/16 grid to
%   approximate the percentage of grid in polygon. 

shapeall=shaperead(shapefile);

mask = cell(length(shapeall),1);
parfor i=1:length(shapeall)
    i    
    shape=shapeall(i);    
    try
        mask{i} = GridinShp(shape,x,y,cellsize,factor );
    catch
        mask{i}=nan;
    end
end
end

