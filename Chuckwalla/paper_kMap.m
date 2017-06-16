% Maps of calibrated first-layer conductivity 
%load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')

caseLst={'f3','f4','f5','f6','f7'};
outDir='E:\Kuai\chuckwalla\GMS\chuckwalla\output\';

selID=[5,2;5,5;6,3;11,2];  
sel=4; 

K1=[];
legStr={};
for k=1:size(selID,1)
    simK=selID(k,1);
    caliK=selID(k,2);
    outFolder=[outDir,'simNewMount',num2str(simK),'\'];
    gridMat=load([outFolder,'grid.mat']);
    titleStr{k}=['Calibrated K of rch',num2str(simK),'-c',num2str(caliK),' (m/d)'];    
    K1(:,:,k)=gridMat.grid(caliK).K1;
end

maskGrid=readGrid('E:\Kuai\chuckwalla\GMS\chuckwalla\data\mount\mount_GMS_obs.tif');
mask=maskGrid.z;
mask(maskGrid.z==255)=nan;
shapeGMS=shaperead('E:\Kuai\chuckwalla\GMS\chuckwalla\data\mount\mount_GMS.shp');
shapeGMS.Geometry='Line';

figure('Position',[1,1,1800,1000])
for k=1:4
    subplot(2,2,k)
    mapshow(shapeGMS,'Color', 'k','LineWidth',2);hold on
    range=highlightPoints([],[],K1(:,:,k).*mask);
    title(titleStr{k})
    Colorbar_reset([0,30])
    
    ix=rem(k+1,2)+1;
    iy=ceil(k/2);
end
suffix = '.eps';
fname=['E:\Kuai\chuckwalla\paper\Fig_kMap'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

