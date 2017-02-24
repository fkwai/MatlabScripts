function [ ras ] = interpGrid( ras1, ras0 )
%interpolate grid of Env.OBJ.rGrid formate, ras1 to resolution and
%corrdinate of ras0

global Env
ras = Env.OBJ.rGrid; % Uniformize the format

ras.col=ras0.col;
ras.row=ras0.row;
ras.xllcorner=ras0.xllcorner;
ras.yllcorner=ras0.yllcorner;
ras.cellsize=ras0.cellsize;
ras.x=ras0.x;
ras.y=ras0.y;

[x,y]=meshgrid(ras1.x,ras1.y);
[xq,yq]=meshgrid(ras0.x,ras0.y);
ras.z=interp2(x,y,ras1.z,xq,yq);


end


