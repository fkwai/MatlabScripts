varLst={'AvgSurfT','Canopint','Evap','LWdown','LWnet','PSurf',...
    'Qair','Qg','Qh','Qle','Qs','Qsb','Qsm','Rainf','Snowf','SoilM',...
    'SoilTemp','SWdown','SWE','SWnet','Tair','Wind','SMAP',...
    'const_DEM','const_Slope','const_Aspect','const_Sand','const_Silt',...
    'const_Clay','const_Capa','const_Bulk','const_LULC','const_NDVI',...
    'const_Rockdep','const_Watertable','const_Irrigation','const_Irri_sq',...
    'SMAP_Anomaly','SoilM_Anomaly'}

%% interval
interval=4;
offset=1;
saveFolder='H:\Kuai\rnnSMAP\Database\Daily\CONUS_sub4\';
for k=1:length(varLst)
    k
    tic
    splitSubset_interval(varLst{k},saveFolder,interval,offset)
    toc
end

interval=16;
offset=1;
saveFolder='H:\Kuai\rnnSMAP\Database\Daily\CONUS_sub16\';
for k=1:length(varLst)
    k
    tic
    splitSubset_interval(varLst{k},saveFolder,interval,offset)
    toc
end

%% shapefile
shape=shaperead('Y:\Maps\State\OK.shp');
interval=2;
offset=1;
saveFolder='H:\Kuai\rnnSMAP\Database\Daily\OK_sub2\';
for k=1:length(varLst)
    k
    tic    
    splitSubset_shapefile(varLst{k},shape,saveFolder,interval,offset)
    toc
end

%% given coordinates
saveFolder='E:\Kuai\rnnSMAP\Database\Daily\cell_20000\';
%crdLst=[40.875,-88.125];
crdLst=[42.875,-106.875];
for k=1:length(varLst)
    k
    tic    
    splitSubset_crd(varLst{k},crdLst,saveFolder);
    toc
end

