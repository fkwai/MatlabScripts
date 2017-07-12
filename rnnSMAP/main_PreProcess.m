Data2csv_SMAP_script

scanDatabase('CONUS');

splitSubset_interval_All(4,1)

scanDatabase('CONUSs4f1');


%% subset for LSOIL
sLst=[2,2,4,4,16,16];
fLst=[1,2,1,3,1,9];
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

splitSubset_shapefile('LSOIL','regionACDs2',sLstACD,'interval',2,'offset',1)
splitSubset_shapefile('LSOIL','regionBCD',sLstBCD,'interval',2,'offset',1)
splitSubset_shapefile('LSOIL','regionAs2',sLstA,'interval',2,'offset',1)
splitSubset_shapefile('LSOIL','regionBs2',sLstB,'interval',2,'offset',1)


