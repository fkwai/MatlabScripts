function [ data,lat,lon,tnum ] = readGLDAS_NOAH( t,fieldind )
%read GLDAS NOAH (v1, 0.25 deg) data for given field number, which can be find from
%wgrib.
% hardcode to size 600,1440

% t: time num for a given date
% fieldnum: the index of field that can be find form wgrib or read_grib(filename,ParamTable,'invent')
% data: all swath contains in that day
% lat,lon,tnum: 1d vector for lat, lon and time (hour, min, second)

global kPath
GLDASdir=kPath.GLDAS;
% default to put parameter table inside GLDAS root folder
ParamTable='Y:\GLDAS\gribtab_GLDAS_NOAH.txt';

dn=datenumMulti(t,1);
Y=year(dn);
d1=datenumMulti(Y*10000+101,1);
D=dn-d1+1;

folder=[GLDASdir,num2str(Y),'\',sprintf('%3.3d',D),'\'];
files = dir([folder,'*.grb']);
nfiles=length(files);
tnum=zeros(nfiles,1);

data=zeros(600,1440,nfiles)*nan;
for i=1:nfiles
    filename=[folder,files(i).name];
%     if ~exist(filename)
%         error('wrong file name')
%     end
%     
    gldas=read_grib(filename,ParamTable,fieldind,'ScreenDiag',0);
    data1D=gldas.fltarray;
    datatemp=reshape(data1D,[1440,600]);
    ttemp=datenum(gldas.pds.year,gldas.pds.month,gldas.pds.day,...
        gldas.pds.hour,gldas.pds.min,0);
    data(:,:,i)=rot90(datatemp);
    tnum(i)=ttemp;
end

% filename=[folder,files(1).name];
% gldas=read_grib(filename,ParamTable,fieldind,'ScreenDiag',0);
% lat=[gldas.gds.La2:-gldas.gds.Dj:gldas.gds.La1]';
% lon=gldas.gds.Lo1:gldas.gds.Di:gldas.gds.Lo2;

% hard code lat and lon to improve efficiency
lat=[89.875:-0.25:-59.875]';
lon=[-179.875:0.25:179.875];

end

