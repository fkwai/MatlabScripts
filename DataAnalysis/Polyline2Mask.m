function [ grid ] = Polyline2Mask( x, y,buffersize, PolylineShp)
%POLYLINE2MASK Summary of this function goes here
%   This function will find cells that a polyline pass. 

% PolylineShp='E:\work\DataAnaly\HUC\ne_110m_rivers_lake_centerlines.shp';
% x=-179.5:179.5;
% y=[89.5:-1:-89.5]';

shape=shaperead(PolylineShp);
grid=ones(length(y),length(x));
s=buffersize;

for i=1:length(shape)
    tempshape=shape(i);
    for j=1:length(tempshape.X)-1
        xp=tempshape.X(j);
        yp=tempshape.Y(j);
        [minv,xgrid]=min(abs(x-xp));
        [minv,ygrid]=min(abs(y-yp));
        grid([ygrid-s:ygrid+s],[xgrid-s:xgrid+s])=nan;        
        %grid(ygrid,xgrid)=nan;        
    end
end



end

