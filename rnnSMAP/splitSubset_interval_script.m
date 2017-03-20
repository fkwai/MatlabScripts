varLst={'SMAP','SoilM','Evap','Rainf','Snowf','Tair','Wind','PSurf','Canopint',...
    'const_DEM','const_Slope','const_Aspect','const_Sand','const_Silt',...
    'const_Clay','const_Capa','const_Bulk','const_LULC','const_NDVI'};

interval=4;
offset=1;
saveFolder='E:\Kuai\rnnSMAP\Database\CONUS_sub4\';
for k=1:length(varLst)
    k
    tic
    splitSubset_interval(varLst{k},saveFolder,interval,offset)
    toc
end

interval=16;
offset=1;
saveFolder='E:\Kuai\rnnSMAP\Database\CONUS_sub16\';
for k=1:length(varLst)
    k
    tic
    splitSubset_interval(varLst{k},saveFolder,interval,offset)
    toc
end


