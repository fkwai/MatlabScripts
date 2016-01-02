function [output,x,y] = upscaleNLDAS( Data)
%NLDAS_UPSCALE Summary of this function goes here
%  This function will upscale NLDAS data to 1 degree resolution

gpath;
global g

L=[(53-25) (125-67)];
gid=gDimInit(1,L,[25 -125],L*8,[0 0],1);
DM = g.DM; 
DM2 = scaleDM(DM,8,[0 0]);

[ny,nx,nt]=size(Data);
output=zeros(ny/8,nx/8,nt)*nan;
for i=1:nt
    output(:,:,i) = gCopyDataRef(Data(:,:,i), DM, DM2); 
end

x=DM2.x;
y=flipud(DM2.y');


end

