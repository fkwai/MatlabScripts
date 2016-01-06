

%% HUC4
crdNLDASfile='Y:\DataAnaly\crd\crd_NLDAS_NA.mat';
crdGRACEfile='Y:\DataAnaly\crd\crd_GRACE_global.mat';
crdNDVIfile='Y:\DataAnaly\crd\crd_NDVI_NA.mat';
crdNLDAS=load(crdNLDASfile);
crdGRACE=load(crdGRACEfile);
crdNDVI=load(crdNDVIfile);

maskfile='Y:\DataAnaly\mask\mask_HUC4.mat';
shpfile='Y:\HUCs\HUC4_main_data.shp';
maskNLDAS=GridMaskofHUC(shpfile,crdNLDAS.x,crdNLDAS.y,crdNLDAS.cellsize,8);
maskGRACE=GridMaskofHUC(shpfile,crdGRACE.x,crdGRACE.y,crdGRACE.cellsize,8);
maskNDVI=GridMaskofHUC(shpfile,crdNDVI.x,crdNDVI.y,crdNDVI.cellsize,4);
save(maskfile,'maskNLDAS','maskGRACE','maskNDVI','-v7.3');

%% ggII
ggIIdir='Y:\ggII';
crdNLDASfile='Y:\DataAnaly\crd\crd_NLDAS_NA.mat';
crdGRACEfile='Y:\DataAnaly\crd\crd_GRACE_global.mat';
crdNDVIfile='Y:\DataAnaly\crd\crd_NDVI_NA.mat';
crdNLDAS=load(crdNLDASfile);
crdGRACE=load(crdGRACEfile);
crdNDVI=load(crdNDVIfile);
for i=1:18
    disp(['basin',num2str(i)]);tic
    ns=sprintf('%02d',i);
    maskfile=[ggIIdir,'\basins',ns,'\basins',ns,'_mask.mat'];
    %if ~exist(maskfile)
        shpfile=[ggIIdir,'\basins_project\basins',ns,'.shp'];
        maskNLDAS=GridMaskofHUC(shpfile,crdNLDAS.x,crdNLDAS.y,crdNLDAS.cellsize,8);
        maskGRACE=GridMaskofHUC(shpfile,crdGRACE.x,crdGRACE.y,crdGRACE.cellsize,8);
        maskNDVI=GridMaskofHUC(shpfile,crdNDVI.x,crdNDVI.y,crdNDVI.cellsize,4);
        save(maskfile,'maskNLDAS','maskGRACE','maskNDVI','-v7.3');        
    %end
    toc
end

%% GRDC
crdGRACEfile='Y:\DataAnaly\crd\crd_GRACE_global.mat';
crdNDVIfile='Y:\DataAnaly\crd\crd_NDVI_global.mat';
crdGRACE=load(crdGRACEfile);
crdNDVI=load(crdNDVIfile);
crdGLDAS=crdGRACE;

maskfile='Y:\DataAnaly\mask\mask_GRDC.mat';
shpfile='Y:\GRDC_UNH\GIS_dataset\grdc_basins_smoothed_sel.shp';

maskGRACE=GridMaskofHUC(shpfile,crdGRACE.x,crdGRACE.y,crdGRACE.cellsize,8);
maskGLDAS=maskGRACE;
maskNDVI=GridMaskofHUC(shpfile,crdNDVI.lon,crdNDVI.lat,crdNDVI.cellsize,4);
for i=1:length(maskGLDAS)
    mask=maskGLDAS{i};
    maskGLDAS{i}=mask(1:150,:);
end
crdGLDAS.y=crdGLDAS.y(1:150);
save(maskfile,'maskGLDAS','maskGRACE','maskNDVI','crdGRACE','crdNDVI','crdGLDAS','-v7.3');
save Y:\DataAnaly\crd\crd_GLDAS_global.mat crdGLDAS