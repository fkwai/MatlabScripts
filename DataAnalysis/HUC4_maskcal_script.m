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