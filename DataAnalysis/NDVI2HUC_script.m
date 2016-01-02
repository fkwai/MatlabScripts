% Add NDVI data to HUCstr / GRDCstr

% read NDVI data
file='E:\work\DataAnaly\GIMMS\avg.tif';
[NDVI,lon,lat,cellsize]=readNDVItif(file);
save E:\work\DataAnaly\GIMMS\NDVI_avg.mat lon lat cellsize 

% % calculate mask
% shpHUC='E:\Kuai\DataAnaly\HUC\HUC4_data_sel.shp';
% shpGRDC='E:\Kuai\DataAnaly\GRDC\grdc_basins_smoothed_sel.shp';
% 
% mask_HUC4_NDVI_2=GridMaskofHUC(shpHUC,lon,lat,cellsize,2);
% mask=mask_HUC4_NDVI_2;
% save mask_HUC4_NDVI_2 mask -v7.3;
% 
% mask_GRDC_NDVI_2=GridMaskofHUC(shpGRDC,lon,lat,cellsize,2);
% mask=mask_GRDC_NDVI_2;
% save mask_GRDC_NDVI_2 mask -v7.3;

HUC4=load('E:\work\DataAnaly\HUCstr_HUC4_32.mat');
GRDC=load('E:\work\DataAnaly\GRDCstr_sel');
maskGRDC=load('E:\work\DataAnaly\mask\mask_GRDC_NDVI_2.mat');
maskHUC=load('E:\work\DataAnaly\mask\mask_HUC4_NDVI_2.mat');
NDVIdata=load('E:\work\DataAnaly\GIMMS\NDVI_avg.mat');

HUCstr = grid2HUC_month( dataName,dataGrid,dataT,mask,HUCstr, strT)