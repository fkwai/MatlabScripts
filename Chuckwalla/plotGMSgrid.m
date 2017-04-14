function plotGMSgrid(outFolder,shpObs,fieldObs,titleStr)
% plot head comparison and map of K1 and K2
% PRISM matfile are required to be loaded outside of this function

% example:
% load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')
% outFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim0_3d\';
% shpObs='E:\Kuai\chuckwalla\GMS\chuckwalla\data\observation\usgs_mid_sel.shp';
% fieldObs='obsH';
% titleStr='sim0';

shape=shaperead(shpObs);
load([outFolder,'\simGrid.mat'])
global g

%% head comp plot
hobs=[];
hsim=[];
for i=1:length(shape)
    X=shape(i).X;
    Y=shape(i).Y;
    ind=round(([Y,X]-g.DM.origin)./g.DM.d+1);
    IY=ind(1);IX=ind(2);
    hobs=[hobs;shape(i).(fieldObs)];
    hsim=[hsim;grid.H1(IY,IX)];
end
f=figure('Position',[100,100,800,600]);

plot(hobs,hsim,'r*');hold on
plot121Line
xlabel('observation')
ylabel('simulation')
rmse=sqrt(mean((hobs-hsim).^2));
title([titleStr,'; rmse = ', num2str(rmse)]);
axis equal
xlim([70,150]);
ylim([70,150]);
suffix = '.eps';
fname=[outFolder,'\headComp'];
fixFigure([],[fname,suffix]);
saveas(gcf, fname);
close(f)

%% K1 and K2 map
f=figure('Position',[100,100,1300,800]);
range=highlightPoints([],[],grid.K1);
title([titleStr,'; K1']);
suffix = '.eps';
fname=[outFolder,'\K1'];
fixFigure([],[fname,suffix]);
Colorbar_reset(range)
saveas(gcf, fname);
close(f)

f=figure('Position',[100,100,1300,800]);
range=highlightPoints([],[],grid.K2);
title([titleStr,'; K2']);
suffix = '.eps';
fname=[outFolder,'\K2'];
fixFigure([],[fname,suffix]);
Colorbar_reset(range)
saveas(gcf, fname);
close(f)

end

