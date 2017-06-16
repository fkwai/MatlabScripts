function maskInd = mask2Ind_SMAP
%From grid mask to 1:240003 gridInd

load('H:\Kuai\Data\GLDAS\maskGLDAS_025.mat');
mask1d=mask(:);
indMask=find(mask1d==1);
maskInd1d=1:length(indMask);
maskInd=mask;
maskInd(indMask)=maskInd1d;


end

