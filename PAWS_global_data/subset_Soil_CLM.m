function [ output_args ] = subset_Soil_CLM( boundingbox,Soil_CLMdir,Soil_CLMdirNEW )
%SUBSET_SOIL_CLM Summary of this function goes here
%   Detailed explanation goes here

if ~exist(Soil_CLMdirNEW,'dir')
    mkdir(Soil_CLMdirNEW);
end

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);

soitexfile=[Soil_CLMdir,'\mksrf_soitex.10level.c010119.nc'];
soitexfile=checkMatNc(soitexfile);
orgnicfile=[Soil_CLMdir,'\mksrf_organic_10level_5x5min_ISRIC-WISE-NCSCD_nlev7_c120830.nc'];
orgnicfile=checkMatNc(orgnicfile);

longxy = readGPdata(soitexfile, 'LONGXY');
latixy = readGPdata(soitexfile, 'LATIXY');
zsoi = readGPdata(soitexfile, 'ZSOI');
mapunits = readGPdata(soitexfile, 'MAPUNITS');
pct_sand = readGPdata(soitexfile, 'PCT_SAND');
pct_clay = readGPdata(soitexfile, 'PCT_CLAY');
om = readGPdata(orgnicfile, 'ORGANIC');   % kg OM/m3

lonind=find(longxy(:,1)>lon_left & longxy(:,1)<lon_right);
latind=find(latixy(1,:)>lat_bottom & latixy(1,:)<lat_up);

LONGXY=longxy(lonind,latind);
LATIXY=latixy(lonind,latind);
ZSOI=zsoi;
MAPUNITS=mapunits(lonind,latind);
PCT_SAND=pct_sand;
PCT_CLAY=pct_clay;
ORGANIC=om(lonind,latind,:);

[pathstr,name,ext]=fileparts(soitexfile);
soitexfileNEW=[Soil_CLMdirNEW,'\',name,'.mat'];
save(soitexfileNEW,'LONGXY','LATIXY','ZSOI','MAPUNITS','PCT_SAND','PCT_CLAY');

[pathstr,name,ext]=fileparts(orgnicfile);
orgnicfileNEW=[Soil_CLMdirNEW,'\',name,'.mat'];
save(orgnicfileNEW,'ORGANIC')



end

