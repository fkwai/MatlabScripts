function [grid,xx,yy] = data2grid( data,x,y)
%   This function will fit data into grid. The (1,1) cell of grid is
%   top-left cell. 

%   data: 1d array of computed data
%   x: array of x coordinate
%   y: array of y coordinate
%   cellsize: grace is 1, nldas/gldas is 0.125
%   -9999 stands for nan values. 

ncell=length(data);
xx=sort(unique(x))';
yy=sort(unique(y),'descend');
dx=xx(2:end)-xx(1:end-1);
dy=yy(1:end-1)-yy(2:end);
if length(unique(dx))>1 || length(unique(dy))>1 
    disp('Worning!! X or Y are not continuous');
end

cellsize=min([min(dx),min(dy)]);

minX=min(x);
maxX=max(x);
minY=min(y);
maxY=max(y);
ny=(maxY-minY)/cellsize;
nx=(maxX-minX)/cellsize;

grid=ones(ny,nx).*nan;

for i=1:ncell
    if ~isnan(data(i))
        iy=int64((maxY-y(i))/cellsize+1);
        ix=int64((x(i)-minX)/cellsize+1);
        grid(iy,ix)=data(i);
    end
end

end

