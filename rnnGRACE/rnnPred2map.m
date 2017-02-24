function [ outGrid ] = data2map( data )
% data: 2d matrix of ngrid * ntime
% outGrid: 3d matrix of ny*nx*ntime

indMaskFile='E:\Kuai\Repo2\scripts\KF\rnnGRACE\indMask.mat';
load(indMaskFile);

ngrid=length(x);
ntime=size(data,2);

outMat=zeros([ngrid,ntime])*nan;
outMat(indMask,:)=data(:,:);

[outGrid,xx,yy] = data2grid3d( outMat,x,y,1 );


end

