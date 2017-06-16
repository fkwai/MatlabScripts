% Groundwater head map and flow patterns

%load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')

outDir='E:\Kuai\chuckwalla\GMS\chuckwalla\output\';
gridMat=load([outDir,'simNewMount6\grid.mat']);
H=gridMat.grid(3).H1;
H(H==-999)=nan;

shapeGMS=shaperead('E:\Kuai\chuckwalla\GMS\chuckwalla\data\mount\mount_GMS.shp');
shapeGMS.Geometry='Line';

figure('Position',[1,1,1800,1000])
mapshow(shapeGMS,'Color', 'k','LineWidth',2);hold on
% global contourTick
% contourTick=[65,80,90,100,120,140,160,180,200,300,500];
range=highlightPoints([],[],H);
title('Groundwater Head Map (m)')
%Colorbar_reset(range)
h = colorbar;
set(h,'fontsize',15);

suffix = '.eps';
fname=['E:\Kuai\chuckwalla\paper\Fig_hMap'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);

%writeASCIIGrid('E:\Kuai\chuckwalla\GMS\chuckwalla\output\simNewMount6\head_f5.txt',H)