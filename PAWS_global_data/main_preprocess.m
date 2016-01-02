
%input shapefile
shapefile='E:\work\PAWS_global\Clinton\shapefiles\Wtrshd_Clinton_deg.shp';  %need a deg watershed
shape=shaperead(shapefile);
boundingbox=shape.BoundingBox; 
daterange=[20100101,20110101]; 
proj.lon0=cmz((boundingbox(1,1)+boundingbox(2,1))/2);
proj.hs='N';
savedir='E:\work\PAWS_global\Clinton\Gdata\';


%CRUNCEP
prepdir='Y:\GlobalRawData\test\CLM_forcing\Precip6Hrly';
solardir='Y:\GlobalRawData\test\CLM_forcing\Solar6Hrly';
tempdir='Y:\GlobalRawData\test\CLM_forcing\TPHWL6Hrly';
CRUNCEPsta=CRUNCEP2Station(boundingbox,daterange,proj,prepdir,solardir,tempdir);
save([savedir,'CRUNCEPsta.mat'],'CRUNCEPsta');

%TRMM
TRMMdir='Y:\GlobalRawData\test\TRMM';
TRMMsta = TRMM2Station_daily(boundingbox,daterange,proj,TRMMdir);
save([savedir,'TRMMsta.mat'],'TRMMsta');

%combine TRMM and CRUNCEP
station=[CRUNCEPsta,TRMMsta];
for i=1:length(station)
    station(i).id=i;
    SS(i).Geometry='Point';
    SS(i).X=double(station(i).XYElev(1));
    SS(i).Y=double(station(i).XYElev(2));
    SS(i).ID=i;
    SS(i).LONGITUDE=double(station(i).LatLong(2));
    SS(i).LATITUDE=double(station(i).LatLong(1));
end
save([savedir,'WeaStation.mat'],'station');
shapewrite(SS,[savedir,'WeaStation.shp']);

% %STRM
% [xind,yind]=STRMrange(boundingbox);

%soil
rawdir='Y:\GlobalRawData\test\rawdata';
soil_properties(rawdir,boundingbox,proj,savedir);

%GWK from soil
GWKfile=[savedir,'\GW_K.mat'];
demfile='E:\work\PAWS_global\Clinton\NED.tif';
% E0=100;
% E1=500;
E0in='E:\work\PAWS_global\Clinton\gw\E_0.txt';
E1in='E:\work\PAWS_global\Clinton\gw\E_1.txt';
[K0,K1]=GWKcomp(GWKfile,demfile,E0in,E1in,savedir);

%lulc
lulcFolder='Y:\GlobalRawData\test\rawdata';
lulcCLM(boundingbox,lulcFolder,proj,savedir);
load('lulcTB_CLM.mat')
save([savedir,'lulcTB_CLM.mat'],'lulc');

% initial state
templatedir='E:\work\PAWS_global\template';
initdir='Y:\CLM_Forcing\initdata';


%test
run_Master_File('master_global.txt')
if ~isfield(g.VDZ,'soic') || isempty(g.VDZ.soic) || length(g.VDZ.VParm)<10
    mat_modify
end
cmd_Save('CL_global')
createCLMMChunk('CL_global')
