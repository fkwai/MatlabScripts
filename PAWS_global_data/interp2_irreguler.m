function [ vq ] = interp2_irreguler( x,y,v,xq,yq,opt )
%INTERP2_IRREGULER Summary of this function goes here
%   interp2 do not accept irreguler meshgrid now. This function will do the
%   job for irreguler mesh. 
%   opt is method: natural, linear, nearest
x1d=reshape(x,size(x,1)*size(x,2),1);
y1d=reshape(y,size(y,1)*size(y,2),1);
v1d=reshape(v,size(v,1)*size(v,2),1);
xq1d=reshape(xq,size(xq,1)*size(xq,2),1);
yq1d=reshape(yq,size(yq,1)*size(yq,2),1);

F = TriScatteredInterp(x1d,y1d,double(v1d),opt);
vq1d=F(xq1d,yq1d);
vq=reshape(vq1d,size(xq,1),size(xq,2));
end

