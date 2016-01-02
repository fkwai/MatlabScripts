function subset_LULC_CLM(boundingbox,LULC_CLMdir,LULC_CLMdirNEW)
%SUBSET_LULC_CLM Summary of this function goes here
%   Detailed explanation goes here

if ~exist(LULC_CLMdirNEW,'dir')
    mkdir(LULC_CLMdirNEW);
end

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);

% pft
pftfile=[LULC_CLMdir,'\mksrf_24pftNT_landuse_rc2000_c121207.nc'];
pftfile=checkMatNc(pftfile);
lat = readGPdata(pftfile, 'LAT');
lon = readGPdata(pftfile, 'LON');
latixy = readGPdata(pftfile, 'LATIXY');
longxy = readGPdata(pftfile, 'LONGXY');
pct_pft = readGPdata(pftfile, 'PCT_PFT');
long_range = find(lon>lon_left & lon<lon_right);
lati_range = find(lat>lat_bottom & lat<lat_up);
LAT=lat(lati_range);
LON=lon(long_range);
LATIXY=latixy(long_range,lati_range);
LONGXY=longxy(long_range,lati_range);
PCT_PFT=pct_pft(long_range,lati_range,:);
[pathstr,name,ext]=fileparts(pftfile);
pftfileNEW=[LULC_CLMdirNEW,'\',name,'.mat'];
save(pftfileNEW,'LAT','LON','LATIXY','LONGXY','PCT_PFT');

% lake
lakefile=[LULC_CLMdir,'\mksrf_LakePnDepth_3x3min_simyr2004_c111116.nc'];
lat = readGPdata(lakefile, 'LAT');
lon = readGPdata(lakefile, 'LON');
latixy = readGPdata(lakefile, 'LATIXY');
longxy = readGPdata(lakefile, 'LONGXY');
pct_lake = readGPdata(lakefile, 'PCT_LAKE');
long_range = find(lon>lon_left & lon<lon_right);
lati_range = find(lat>lat_bottom & lat<lat_up);
LAT=lat(lati_range);
LON=lon(long_range);
LATIXY=latixy(long_range,lati_range);
LONGXY=longxy(long_range,lati_range);
PCT_LAKE=pct_lake(long_range,lati_range);
[pathstr,name,ext]=fileparts(lakefile);
lakefileNEW=[LULC_CLMdirNEW,'\',name,'.mat'];
save(lakefileNEW,'LAT','LON','LATIXY','LONGXY','PCT_LAKE');

% wetland
wetlandfile=[LULC_CLMdir,'\mksrf_lanwat.060929.nc'];
lat = readGPdata(wetlandfile, 'LAT');
lon = readGPdata(wetlandfile, 'LON');
latixy = readGPdata(wetlandfile, 'LATIXY');
longxy = readGPdata(wetlandfile, 'LONGXY');
pct_wetland = readGPdata(wetlandfile, 'PCT_WETLAND');
long_range = find(lon>lon_left & lon<lon_right);
lati_range = find(lat>lat_bottom & lat<lat_up);
LAT=lat(lati_range);
LON=lon(long_range);
LATIXY=latixy(long_range,lati_range);
LONGXY=longxy(long_range,lati_range);
PCT_WETLAND=pct_wetland(long_range,lati_range);
[pathstr,name,ext]=fileparts(wetlandfile);
wetlandfileNEW=[LULC_CLMdirNEW,'\',name,'.mat'];
save(wetlandfileNEW,'LAT','LON','LATIXY','LONGXY','PCT_WETLAND');

% urban
urbanfile=[LULC_CLMdir,'\mksrf_urban_0.05x0.05_simyr2000.c120621.nc'];
lat = readGPdata(urbanfile, 'LAT');
lon = readGPdata(urbanfile, 'LON');
latixy = readGPdata(urbanfile, 'LATIXY');
longxy = readGPdata(urbanfile, 'LONGXY');
pct_urban = readGPdata(urbanfile, 'PCT_URBAN');
long_range = find(lon>lon_left & lon<lon_right);
lati_range = find(lat>lat_bottom & lat<lat_up);
LAT=lat(lati_range);
LON=lon(long_range);
LATIXY=latixy(long_range,lati_range);
LONGXY=longxy(long_range,lati_range);
PCT_URBAN=pct_urban(long_range,lati_range);
[pathstr,name,ext]=fileparts(urbanfile);
urbanfileNEW=[LULC_CLMdirNEW,'\',name,'.mat'];
save(urbanfileNEW,'LAT','LON','LATIXY','LONGXY','PCT_URBAN');

end

