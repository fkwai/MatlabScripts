function [grid,xx,yy] = data2grid3d( data,x,y )
%   This function will fit data into grid. The (1,1) cell of grid is
%   top-left cell. 

%   data: 2d array of computed data (ncell,ntime)
%   x: array of x coordinate
%   y: array of y coordinate
%   cellsize: grace is 1, nldas/gldas is 0.125
%   -9999 stands for nan values. 

[nc,nt]=size(data);
xx=VectorDim(sort(unique(x)),2);
yy=VectorDim(sort(unique(y),'descend'),1);
nx=length(xx);
ny=length(yy);

data(data==-9999)=nan;

grid=ones(ny,nx,nt).*nan;

for i=1:nc
	iy=find(y(i)==yy);
	ix=find(x(i)==xx);
	grid(iy,ix,:)=data(i,:);
end

end

