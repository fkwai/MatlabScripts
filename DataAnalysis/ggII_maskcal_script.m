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
% 
% for i=1:18
%     ['basin',num2str(i)]
%     ns=sprintf('%02d',i);
%     maskfile=[ggIIdir,'\basins',ns,'\basins',ns,'_mask.mat'];
%     load(maskfile)
%     maskGRACE=maskGLDAS;
%     save(maskfile,'maskNLDAS','maskGRACE');
% 
% end
