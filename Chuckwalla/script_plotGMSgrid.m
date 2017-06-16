
%% sim0, sim4 - sim10
% read grid.shp
simLst=[0,4:10];
for k=1:length(simLst)
    k
    tic
    outFolder=['E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim',num2str(simID),'_3d\'];
    grid=readGMSgrid(outFolder);
    toc
end
% plot figures
load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')
usgsShp='E:\Kuai\chuckwalla\GMS\chuckwalla\data\observation\usgs_mid_sel.shp';
simLst=[0,4:10];
for k=1:length(simLst)
    simID=simLst(k);
    outFolder=['E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim',num2str(simID),'_3d\'];
    titleStr=['sim',num2str(simID)];
    plotGMSgrid(outFolder,usgsShp,'obsH',titleStr)
end

%% sim0 rch, uniRch
load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')
usgsShp='E:\Kuai\chuckwalla\GMS\chuckwalla\data\observation\usgs_mid_sel.shp';

outFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim0_uniRch_3d_bCali';
grid=readGMSshape(outFolder);
titleStr=['sim0, uniRch, before Cali'];
plotGMSgrid(outFolder,usgsShp,'obsH',titleStr)

outFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\sim0_uniRch_3d';
grid=readGMSshape(outFolder);
titleStr=['sim0, uniRch'];
plotGMSgrid(outFolder,usgsShp,'obsH',titleStr)


%% simNew6 with multiple calibration
load('E:\Kuai\chuckwalla\Chuckwalla_kuai\matfile_V6_10yr\chuck_newsoil2.mat')
usgsShp='E:\Kuai\chuckwalla\GMS\chuckwalla\data\observation\usgs_mid_sel.shp';

outFolder='E:\Kuai\chuckwalla\GMS\chuckwalla\output\simNew6_3d\';
shapefile=[outFolder,'\grid_f10.shp'];

grid=readGMSshape(outFolder);
titleStr=['sim6, new mount'];
plotGMSgrid(outFolder,usgsShp,'obsH',titleStr)