function [ Z,C ] = build3Dgrid(d,e0file,e1file,shapefile,PRISMmatfile,varargin)
% compute 3D grid elevation and cell bound. 

savefolder=[];
if ~isempty(varargin)
    savefolder=varargin{1};
end

e0=readGrid(e0file);
e1=readGrid(e1file);
shape=shaperead(shapefile);
load(PRISMmatfile,'g');
DM=g.DM;

[x,y]=meshgrid(DM.x,DM.y);
[x0,y0]=meshgrid(e0.x,e0.y);
[x1,y1]=meshgrid(e1.x,e1.y);
z0=interp2(x0,y0,e0.z,x,y);
z1=interp2(x1,y1,e1.z,x,y);
cshape=inpolygon(x,y,shape.X,shape.Y);
[ny,nx]=size(x);
nz=length(d);

C=zeros(ny,nx,nz+1);
Z=zeros(ny,nx,nz+1);

for i=1:length(d)+1
    if i==1
        d1=0;
    else
        d1=d(i-1);
    end
    if i==length(d)+1
        d2=nan;
    else
        d2=d(i);
    end
    c=zeros(ny,nx);
    ind=find(cshape==1&z1<z0-d1);
    c(ind)=1;
    
    z=zeros(ny,nx)*nan;
    if isnan(d2)
        z(ind)=z1(ind);
    else
        ind1=find(c==1&z1<z0-d2);
        z(ind1)=z0(ind1)-d2;
        ind2=find(c==1&z1>=z0-d2);
        z(ind2)=z1(ind2);
    end
    Z(:,:,i)=z;
    C(:,:,i)=z;
    
    if ~isempty(savefolder)
        filez=[savefolder,'\z',num2str(i-1),'.txt'];
        filec=[savefolder,'\c',num2str(i-1),'.txt'];
        grid.x=DM.x;
        grid.y=DM.y;
        grid.col=DM.msize(2);
        grid.row=DM.msize(1);
        grid.xllcorner = DM.origin(2)-DM.d(1)/2;
        grid.yllcorner = DM.origin(1)-DM.d(1)/2;
        grid.cellsize=DM.d(1);
        grid.z=z;
        writeASCIIGrid(filez,grid);
        grid.z=c;
        writeASCIIGrid(filec,grid);
    end
    
end

end

