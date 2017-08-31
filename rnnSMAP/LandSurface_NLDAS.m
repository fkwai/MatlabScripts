

%% Soil
global kPath
soilMat=load('H:\Kuai\Data\SoilGlobal\wise5by5min_v1b\soilMap.mat');
maskMat=load('Y:\NLDAS\maskNLDASv12f1.mat');

field={'Sand','Silt','Clay','Capa','Bulk'};
for k=1:length(field)
    data=soilMat.(field{k});
    vq=interpGridArea(soilMat.lon,soilMat.lat,data,maskMat.lon,maskMat.lat,'mean');    
    gridConst2csv_NLDAS(vq,'1516v12f1',maskMat,field{k})    
    gridConst2csv_NLDAS(vq,'1014v12f1',maskMat,field{k})    
end


%% crop irrigation
global kPath
irriFile='H:\Kuai\Data\UScrop\cropIrrigation.tif';
maskMat=load('Y:\NLDAS\maskNLDASv12f1.mat');
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

gridConst2csv_NLDAS(vq,'1516v12f1',maskMat,'Irri')
gridConst2csv_NLDAS(vq,'1014v12f1',maskMat,'Irri')
gridConst2csv_NLDAS(vq,'1516v12f1',maskMat,'IrriSq')
gridConst2csv_NLDAS(vq,'1014v12f1',maskMat,'IrriSq')

%% LULC (only CONUS)
LULCFile='Y:\NLCD\nlcd_2011_landcover_2011_edition_2014_10_10\nlcd_2011_landcover_proj_resample.tif';
maskMat=load('Y:\NLDAS\maskNLDASv12f1.mat');

[gridLULC,cmapLULC,refLULC]=geotiffread(LULCFile);
lonLULC=refLULC.LongitudeLimits(1)+refLULC.CellExtentInLongitude/2:...
    refLULC.CellExtentInLongitude:...
    refLULC.LongitudeLimits(2)-refLULC.CellExtentInLongitude/2;
latLULC=[refLULC.LatitudeLimits(2)-refLULC.CellExtentInLatitude/2:...
    -refLULC.CellExtentInLatitude:...
    refLULC.LatitudeLimits(1)+refLULC.CellExtentInLatitude/2]';
gridLULC=double(gridLULC);
vq=interpGridArea(lonLULC,latLULC,gridLULC,maskMat.lon,maskMat.lat,'mode');

lulc=vq;
lulc(vq==11|vq==12)=1;
lulc(vq==21|vq==22|vq==23|vq==24)=2;
lulc(vq==31)=3;
lulc(vq==41)=4;
lulc(vq==42|vq==43)=5;
lulc(vq==52)=6;
lulc(vq==71)=7;
lulc(vq==81|vq==82)=8;
lulc(vq==90|vq==95)=9;
lulc(vq<=1|vq>100)=nan;

gridConst2csv_NLDAS(lulc,'1516v12f1',maskMat,'lulc')
gridConst2csv_NLDAS(lulc,'1014v12f1',maskMat,'lulc')

%% rescan dataset
scanDatabaseNLDAS('1516v12f1',1);
scanDatabaseNLDAS('1014v12f1',1);





