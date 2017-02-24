function [grid,xx,yy] = data2grid( data,x,y,cellsize)
%   This function will fit data into grid. The (1,1) cell of grid is
%   top-left cell. 

%   data: 1d array of computed data
%   x: array of x coordinate
%   y: array of y coordinate
%   cellsize: grace is 1, nldas/gldas is 0.125
%   -9999 stands for nan values. 

ncell=length(data);
nx=length(unique(x));
ny=length(unique(y));
xx=sort(unique(x))';
yy=sort(unique(y),'descend');
minx=min(x);
maxy=max(y);

grid=ones(ny,nx).*nan;

for i=1:ncell
    if ~isnan(data(i))
        iy=int64((maxy-y(i))/cellsize+1);
        ix=int64((x(i)-minx)/cellsize+1);
        grid(iy,ix)=data(i);
    end
end

end

