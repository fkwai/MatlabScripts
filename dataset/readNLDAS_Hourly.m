function [ data,lat,lon,tnum,field ] = readNLDAS_Hourly(productName,t,fieldind)
%read NLDASH data for given field number, which can be find from
%wgrib.

% productName - FORA, FORB, NOAH
% t - time num for a given date
% fieldInd - the index of field that can be find form wgrib or read_grib(filename,ParamTable,'invent')

% data - grid output 
% lat,lon,tnum - 1d vector for lat, lon and time (hour, min, second)

global kPath

switch productName
	case 'FORA'
		NLDASdir=[kPath.NLDAS,'NLDAS_FORA0125_H.002',kPath.s];
		ParamTable=[kPath.NLDAS,'gribtab_NLDAS_FORA_hourly.002.txt'];
	case 'FORB'
		NLDASdir=[kPath.NLDAS,'NLDAS_FORB0125_H.002',kPath.s];
		ParamTable=[kPath.NLDAS,'gribtab_NLDAS_FORB_hourly.002.txt'];
	case 'NOAH'
		NLDASdir=[kPath.NLDAS,'NLDAS_NOAH0125_H.002',kPath.s];
		ParamTable=[kPath.NLDAS,'gribtab_NLDAS_NOAH.002.txt'];
end

dn=datenumMulti(t,1);
Y=year(dn);
d1=datenumMulti(Y*10000+101,1);
D=dn-d1+1;

folder=[NLDASdir,num2str(Y),kPath.s,sprintf('%3.3d',D),kPath.s];
files = dir([folder,'*.grb']);
nfiles=length(files);
tnum=zeros(nfiles,1);

data=zeros(224,464,nfiles)*nan;
for i=1:nfiles
    filename=[folder,files(i).name];
%     if ~exist(filename)
%         error('wrong file name')
%     end
%     
    nldas=read_grib(filename,ParamTable,fieldind,'ScreenDiag',0);
    data1D=nldas.fltarray;
    datatemp=reshape(data1D,[464,224]);
    ttemp=datenum(nldas.pds.year,nldas.pds.month,nldas.pds.day,...
        nldas.pds.hour,nldas.pds.min,0);
    data(:,:,i)=rot90(datatemp);
    tnum(i)=ttemp;
end

% filename=[folder,files(1).name];
% nldas=read_grib(filename,ParamTable,fieldind,'ScreenDiag',0);
% lat=[nldas.gds.La2:-gldas.gds.Dj:gldas.gds.La1]';
% lon=nldas.gds.Lo1:gldas.gds.Di:gldas.gds.Lo2;

% hard code lat and lon to improve efficiency
lat=[52.9375:-0.125:25.0625]';
lon=[-124.9375:0.125:-67.0625];
field=nldas.parameter;

end

