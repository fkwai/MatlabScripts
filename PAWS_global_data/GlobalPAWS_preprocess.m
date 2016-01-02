function GlobalPAWS_preprocess(shapefileDeg,daterange,datafolder,savedir,demfile,E0,E1,varargin )
%GLOABLPAWS_PREPROCESS Summary of this function goes here
%   this function will do Global PAWS preprocessing and save processed
%   global data of matfile into a specified folder. 

%   2015/7/31: still need input dem, and a global nonprojected watershed
%   shapefile(in degree). Will empoly SRTM later and projection
%   transforming from meter to degree later. 

%   Example: 
% shapefileDeg='E:\work\PAWS_global\Clinton\shapefiles\Wtrshd_Clinton_deg.shp';  %need a deg watershed
% daterange=[20000101,20100101]; 
% datafolder='Y:\GlobalRawData\NA\';
% savedir='E:\work\PAWS_global\Clinton\Gdata\';
% demfile='E:\work\PAWS_global\Clinton\NED.tif';
% E0=100; 
% E1=500; 
% Or
% E0='E:\work\PAWS_global\Clinton\gw\E_0.txt';
% E1='E:\work\PAWS_global\Clinton\gw\E_1.txt';

% GlobalPAWS_preprocess(shapefileDeg,daterange,datafolder,savedir,demfile,E0,E1 )

if length(varargin)>0
    proj=varargin{1};   %probably add justify of right proj format here
else
    proj=[];
end

shape=shaperead(shapefileDeg);
boundingbox=shape.BoundingBox; 
datalstfile=[datafolder,'\datalist.txt'];
[fields,chars,file,S]=load_settings_file(datalstfile);

if ~(S.lon_left<boundingbox(1, 1) && S.lon_right>boundingbox(2, 1)...
        && S.lat_bottom<boundingbox(1, 2) && S.lat_top>boundingbox(2, 2))
    error('not include in bounding box')
end
if ~(S.sd<=daterange(1) && S.ed>=daterange(2))
    error('not include in date range')
end

if isempty(proj)
    %automatically setup proj
    proj.lon0=cmz((boundingbox(1,1)+boundingbox(2,1))/2);
    lat0=(boundingbox(1,2)+boundingbox(2,2))/2;
    if(lat0>0)
        proj.hs='N';
    else
        proj.hs='S';
    end
end

%CRUNCEP
disp('Start CRUNCEP');
tic
prepdir=[S.CRUNCEP,'\Precip6Hrly'];
solardir=[S.CRUNCEP,'\Solar6Hrly'];
tempdir=[S.CRUNCEP,'\TPHWL6Hrly'];
CRUNCEPsta=GP_CRUNCEP2Station(boundingbox,daterange,proj,prepdir,solardir,tempdir);
save([savedir,'CRUNCEPsta.mat'],'CRUNCEPsta');
disp('Finished CRUNCEP')
toc

%TRMM
disp('Start TRMM');
tic
TRMMdir=S.TRMM;
TRMMsta = GP_TRMM2Station_daily(boundingbox,daterange,proj,TRMMdir);
save([savedir,'TRMMsta.mat'],'TRMMsta');
disp('Finished TRMM')
toc

%combine TRMM and CRUNCEP
disp('Combining CRUNCEP and TRMM')
tic
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
disp('Finished CRUNCEP and TRMM combining')
toc

clear CRUNCEPsta TRMMsta station

%soil
disp('Start soil')
tic
SoilFolder=S.Soil_CLM;
GP_soil_properties(SoilFolder,boundingbox,proj,savedir);
disp('Finished soil')
toc

%GWK from soil
disp('Start GW')
tic
GWKfile=[savedir,'\GW_K.mat'];
[K0,K1]=GP_GWKcomp(GWKfile,demfile,E0,E1,savedir);
disp('Finished GW')
toc

%lulc
disp('Start LULC')
tic
lulcFolder=S.LULC_CLM;
GP_lulcCLM(boundingbox,lulcFolder,proj,savedir);
load('lulcTB_CLM.mat')
save([savedir,'lulcTB_CLM.mat'],'lulc');
disp('Finished LULC')
toc

%initial Carbon State
disp('Start LULC')
tic
initdir=S.CS_CLM;
GP_initialCStates_CLM( boundingbox,initdir,savedir)
disp('Finished LULC')
toc
end

