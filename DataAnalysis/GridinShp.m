function output = GridinShp(shape, x,y,cellsize,factor )
%   return a mask of grid that percentage that inside a polygon

%   shape: shape of polygon
%   x: x coordinate of all cells (ordered)
%   y: y coordinate of all cells (ordered)
%   cellsize: cell size of degree
%   factor: finner factor. Ex, 16 means use a cellsize/16 grid to
%   approximate the percentage of grid in polygon.

indpoly=[0,find(isnan(shape.X))];
output=zeros(length(y),length(x));

for i=1:length(indpoly)-1
    
    X=shape.X(indpoly(i)+1:indpoly(i+1)-1);
    Y=shape.Y(indpoly(i)+1:indpoly(i+1)-1);
    
    indx1=find(x<min(X));indx1=indx1(end);
    indx2=find(x>max(X));indx2=indx2(1);
    indy1=find(y>max(Y));indy1=indy1(end);
    indy2=find(y<min(Y));indy2=indy2(1);
    indx=indx1:indx2;
    indy=indy1:indy2;
    
    xx=x(indx);
    yy=y(indy);

    global g
    gpath;
    L=[yy(1)-yy(end)+cellsize,xx(end)-xx(1)+cellsize];
    BS=[min(yy)-cellsize/2 min(xx)-cellsize/2];
    m=[length(yy) length(xx)];
    gid=gDimInit(1,L,BS,m.*factor,[0 0],1);
    DMf = g.DM;
    DMc = scaleDM(DMf,factor,[0 0]);
    
    [px,py]=meshgrid(DMf.x,DMf.y);
    
    inout = int32(zeros(size(px)));
    pnpoly(X,Y,px,py,inout);
    inout=double(inout);
    
    inout(inout~=1)=0;
    outsub = gCopyDataRef(inout, DMf, DMc);
    outsub=flipud(outsub);
    
    outputtemp=zeros(length(y),length(x));
    outputtemp(indy,indx)=outsub;
    
    if ~ispolycw(X,Y)
        outputtemp=-outputtemp;
    end
    
    output=output+outputtemp;
end

end

