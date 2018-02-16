

%% Soil
global kPath
soilMat=load('H:\Kuai\Data\SoilGlobal\wise5by5min_v1b\soilMap.mat');
maskMat=load(kPath.maskSMAP_CONUS);

field={'Sand','Silt','Clay','Capa','Bulk'};
for k=1:length(field)
    data=soilMat.(field{k});
    vq=interpGridArea(soilMat.lon,soilMat.lat,data,maskMat.lon,maskMat.lat,'mean');
    gridConst2csv_SMAP(vq,field{k})
end

% splitSubset
sLst=[4,4,16,16];
fLst=[1,3,1,9];
for k=1:length(sLst)
    for j=1:length(field)        
        ss=sLst(k);
        ff=fLst(k);
        splitSubset_interval(['const_',field{j}],['CONUSs',num2str(ss),'f',num2str(ff)],ss,ff)
    end
end

%% crop irrigation
global kPath
irriFile='H:\Kuai\Data\UScrop\cropIrrigation.tif';
maskMat=load(kPath.maskSMAP_CONUS);
[gridIrri,refIrri]=geotiffread(irriFile);

lonIrri=refIrri.LongitudeLimits(1)+refIrri.CellExtentInLongitude/2:...
    refIrri.CellExtentInLongitude:...
    refIrri.LongitudeLimits(2)-refIrri.CellExtentInLongitude/2;
latIrri=[refIrri.LatitudeLimits(2)-refIrri.CellExtentInLatitude/2:...
    -refIrri.CellExtentInLatitude:...
    refIrri.LatitudeLimits(1)+refIrri.CellExtentInLatitude/2]';
gridIrri=double(gridIrri);
gridIrri(gridIrri<0)=0;

% construct US grid
vq=interpGridArea(lonIrri,latIrri,gridIrri,maskMat.lon,maskMat.lat,'mean');
gridConst2csv_SMAP(vq,'Irri')
gridConst2csv_SMAP(vq.^0.5,'IrriSq')

% splitSubset
sLst=[4,4,16,16];
fLst=[1,3,1,9];
for k=1:length(sLst)
    ss=sLst(k);
    ff=fLst(k);
    splitSubset_interval('const_Irri',['CONUSs',num2str(ss),'f',num2str(ff)],ss,ff)
    splitSubset_interval('const_IrriSq',['CONUSs',num2str(ss),'f',num2str(ff)],ss,ff)
end

%% rescan dataset
sLst=[2,2,4,4,16,16];
fLst=[1,2,1,3,1,9];
for k=1:length(sLst)
    ss=sLst(k);
    ff=fLst(k);
    dbName=['CONUSs',num2str(ss),'f',num2str(ff)];
    scanDatabase(dbName);
end
scanDatabase('CONUS');




