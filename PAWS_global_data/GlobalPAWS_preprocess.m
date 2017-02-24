function GlobalPAWS_preprocess(shapefileDeg,daterange,datafolder,savedir,demfile,gwE,varargin )
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
[fields,chars,file,Sdata]=load_settings_file(datalstfile);

% global dojie
% dojie=0;
% if dojie
%     disp('Doing precedure of Jie')
%     boundingbox=[-60.375,-2.875;-58.875,-1.875];
% end

if ~(Sdata.lon_left<=boundingbox(1, 1) && Sdata.lon_right>=boundingbox(2, 1)...
        && Sdata.lat_bottom<=boundingbox(1, 2) && Sdata.lat_top>=boundingbox(2, 2))
    error('not include in bounding box')
end
if ~(Sdata.sd<=daterange(1) && Sdata.ed>=daterange(2))
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

if ~exist(savedir)
    mkdir(savedir)
end

Sout=[];
%% weather data
% CRUNCEP
disp('Start CRUNCEP');
prepdir=[Sdata.CRUNCEP,'\Precip6Hrly'];
solardir=[Sdata.CRUNCEP,'\Solar6Hrly'];
tempdir=[Sdata.CRUNCEP,'\TPHWL6Hrly'];
CRUNCEPsta=GP_CRUNCEP2Station(boundingbox,daterange,proj,prepdir,solardir,tempdir);
save([savedir,'\CRUNCEPsta.mat'],'CRUNCEPsta');
disp('Finished CRUNCEP')


% TRMM
disp('Start TRMM');
TRMMdir=Sdata.TRMM;
TRMMsta = GP_TRMM2Station_daily(boundingbox,daterange,proj,TRMMdir);
save([savedir,'\TRMMsta.mat'],'TRMMsta');
disp('Finished TRMM')


% combine TRMM and CRUNCEP
disp('Combining CRUNCEP and TRMM')
[ Stations,SS ] = GP_comb_TRMM_CRUNCEP( CRUNCEPsta,TRMMsta );
save([savedir,'\WeaStation.mat'],'Stations');
shapewrite(SS,[savedir,'\WeaStation.shp']);
disp('Finished CRUNCEP and TRMM combining')
Sout.wdata_file=[savedir,'\WeaStation.mat'];
Sout.wea_file=[savedir,'\WeaStation.shp'];

clear CRUNCEPsta TRMMsta Stations

%% soil
disp('Start soil')
SoilFolder=Sdata.Soil_CLM;
GP_soil_properties(SoilFolder,boundingbox,proj,savedir);
disp('Finished soil')
Sout.soilsMap_file=[savedir,'\soil_properties.mat'];


%% GWK from soil
disp('Start GW')
tic
GWKfile=[savedir,'\GW_K.mat'];
K=GP_GWKcomp(GWKfile,demfile,gwE,savedir);
disp('Finished GW')
toc
Sout.gw_file=[savedir,'\GW'];


%% lulc
disp('Start LULC')
tic
lulcFolder=Sdata.LULC_CLM;
GP_lulcCLM(boundingbox,lulcFolder,proj,savedir);
load('lulcTB_CLM.mat')
save([savedir,'\lulcTB_CLM.mat'],'lulc');
disp('Finished LULC')
toc
Sout.lulc_file=[savedir,'\pft.mat'];
Sout.lulcTB_file=[savedir,'\lulcTB_CLM.mat'];


% %% initial Carbon State
% disp('Start Carbon State')
% tic
% initdir=Sdata.CS_CLM;
% GP_initialCStates_CLM( boundingbox,initdir,savedir)
% disp('Finished Carbon State')
% toc

%% projected watershed
np=length(shape.X);
X=zeros(1,np);
Y=zeros(1,np);
for i=1:np
    [X(i),Y(i)]=GP_latlon2utm(shape.Y(i),shape.X(i),proj.lon0,proj.hs);
end
shapeprj=shape;
shapeprj.Geometry='Polygon';
shapeprj.BoundingBox=[min(X),min(Y);max(X),max(Y)];
shapeprj.X=X;
shapeprj.Y=Y;
shapewrite(shapeprj,[savedir,'\watershed_prj.shp']);
Sout.wtrshd_file=[savedir,'\watershed_prj.shp'];

Sout.dem_file=demfile;
Sout.ned_file=demfile;
write_settings_file(Sout,[savedir,'\data_GP.txt']);


end

