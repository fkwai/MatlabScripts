Data2csv_SMAP_script

scanDatabase('CONUS');

splitSubset_interval_All(4,2)

scanDatabase('CONUSs4f1');



%% subset for LSOIL
sLst=[4];
fLst=[2];
for k=1:length(sLst)
    ss=sLst(k);
    ff=fLst(k);
    dbName=['CONUSs',num2str(ss),'f',num2str(ff)];
    splitSubset_interval('LSOIL',dbName,ss,ff)

end

%%
sLstACD={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
sLstBCD={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionC.shp';...
    'H:\Kuai\map\physio_shp\rnnSMAP\regionD.shp'};
sLstA={'H:\Kuai\map\physio_shp\rnnSMAP\regionA.shp';};
sLstB={'H:\Kuai\map\physio_shp\rnnSMAP\regionB.shp';};

fieldLst={'SOILM_MOS','SOILM_VIC','LOIL_VIC'}
for k=1:length(fieldLst)
    fieldName=fieldLst{k}
    splitSubset_shapefile(fieldName,'regionACDs2',sLstACD,'interval',2,'offset',1)
    splitSubset_shapefile(fieldName,'regionBCDs2',sLstBCD,'interval',2,'offset',1)
    splitSubset_shapefile(fieldName,'regionAs2',sLstA,'interval',2,'offset',1)
    splitSubset_shapefile(fieldName,'regionBs2',sLstB,'interval',2,'offset',1)
end


%%
sLst={'H:\Kuai\map\State\GA.shp';...
    'H:\Kuai\map\State\SC.shp';...
    'H:\Kuai\map\State\NC.shp';};
splitSubset('GA-SC-NC','shape',2,1,sLst)

sLst={'H:\Kuai\map\State\AZ.shp';};
splitSubset('AZ','shape',2,1,sLst)

sLst={'H:\Kuai\map\State\NE.shp';};
splitSubset('NE','shape',2,1,sLst)

