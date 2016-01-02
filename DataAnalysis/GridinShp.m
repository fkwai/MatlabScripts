function output = GridinShp(shape, x,y,cellsize,factor )
%   return a mask of grid that percentage that inside a polygon

%   shape: shape of polygon
%   x: x coordinate of all cells (ordered)
%   y: y coordinate of all cells (ordered)
%   cellsize: cell size of degree
%   factor: finner factor. Ex, 16 means use a cellsize/16 grid to
%   approximate the percentage of grid in polygon. 

X=shape.X(1:end-1);
Y=shape.Y(1:end-1);


global g
gpath;
L=[y(1)-y(end)+cellsize,x(end)-x(1)+cellsize];
BS=[min(y)-cellsize/2 min(x)-cellsize/2];
m=[length(y) length(x)];
gid=gDimInit(1,L,BS,m.*factor,[0 0],1);
DMf = g.DM; 
DMc = scaleDM(DMf,factor,[0 0]);

[px,py]=meshgrid(DMf.x,DMf.y);
inout = int32(zeros(size(px)));
indx=find(DMf.x<max(X)&DMf.x>min(X));
indy=find(DMf.y<max(Y)&DMf.y>min(Y));
pxx=px(indy,indx);
pyy=py(indy,indx);
inoutsub=int32(zeros(size(pxx)));

pnpoly(X,Y,pxx,pyy,inoutsub);

inout(indy,indx)=inoutsub;
inout=double(inout);
inout(inout~=1)=0;
output = gCopyDataRef(inout, DMf, DMc); 
output=flipud(output);

end

