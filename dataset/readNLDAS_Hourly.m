function [ data,lat,lon,tnum,fieldLst ] = readNLDAS_Hourly(productName,t,fieldind,varargin)
%read NLDASH data for given field number, which can be find from
%wgrib.

% productName - FORA, FORB, NOAH
% t - time num for a given date
% fieldInd - the index of field that can be find form wgrib or read_grib(filename,ParamTable,'invent')
%          - if -1 read all field. 
% data - grid output [ny,nx,nt,nfield]
% lat,lon,tnum - 1d vector for lat, lon and time (hour, min, second)

if isempty(varargin)
    global kPath    
    dirNLDAS=kPath.NLDAS;
else
    dirNLDAS=varargin{1};
end
switch productName
	case 'FORA'
		NLDASdir=[dirNLDAS,'NLDAS_FORA0125_H.002',filesep];
        ParamTable=[dirNLDAS,'gribtab_NLDAS_FORA_hourly.002.txt'];        
        nField=11;
    case 'FORB'
        NLDASdir=[dirNLDAS,'NLDAS_FORB0125_H.002',filesep];
        ParamTable=[dirNLDAS,'gribtab_NLDAS_FORB_hourly.002.txt'];
        nField=10;
    case 'NOAH'
        NLDASdir=[dirNLDAS,'NLDAS_NOAH0125_H.002',filesep];
        ParamTable=[dirNLDAS,'gribtab_NLDAS_NOAH.002.txt'];
        nField=52;
    case 'VIC'
        NLDASdir=[dirNLDAS,'NLDAS_VIC0125_H.002',filesep];
        ParamTable=[dirNLDAS,'gribtab_NLDAS_VIC.002.txt'];
        nField=43;
    case 'MOS'
        NLDASdir=[dirNLDAS,'NLDAS_MOS0125_H.002',filesep];
        ParamTable=[dirNLDAS,'gribtab_NLDAS_MOS.002.txt'];
        nField=37;
end

if fieldind~=-1
    nField=length(fieldind);
end

dn=datenumMulti(t,1);
Y=year(dn);
d1=datenumMulti(Y*10000+101,1);
D=dn-d1+1;

folder=[NLDASdir,num2str(Y),filesep,sprintf('%3.3d',D),filesep];
files = dir([folder,'*.grb']);
nfiles=length(files);
tnum=zeros(nfiles,1);

%% read data
if fieldind~=-1
    data=zeros(224,464,nfiles)*nan;
else
    data=zeros(224,464,nfiles,nField)*nan;
end

for i=1:nfiles
    filename=[folder,files(i).name];
    
    nldas=read_grib(filename,ParamTable,fieldind,'ScreenDiag',0);
    ttemp=datenum(nldas(1).pds.year,nldas(1).pds.month,nldas(1).pds.day,...
        nldas(1).pds.hour,nldas(1).pds.min,0);
    tnum(i)=ttemp;

    if fieldind~=-1
        data1D=nldas.fltarray;
        datatemp=reshape(data1D,[464,224]);
        data(:,:,i)=rot90(datatemp);
    else
        for k=1:nField
            data1D=nldas(k).fltarray;
            datatemp=reshape(data1D,[464,224]);
            data(:,:,i,k)=rot90(datatemp);
        end
    end
end

% filename=[folder,files(1).name];
% nldas=read_grib(filename,ParamTable,fieldind,'ScreenDiag',0);
% lat=[nldas.gds.La2:-gldas.gds.Dj:gldas.gds.La1]';
% lon=nldas.gds.Lo1:gldas.gds.Di:gldas.gds.Lo2;

% hard code lat and lon to improve efficiency
lat=[52.9375:-0.125:25.0625]';
lon=[-124.9375:0.125:-67.0625];

%% field Name
fieldLst={nldas.parameter};
for k=1:length(nldas)
    if ~strcmp(nldas(k).level,'surface')
        ind=find(nldas(k).level==' ');
        levStr=nldas(k).level(1:ind-1);
        fieldLst{k}=[fieldLst{k},'_',levStr];
    end
end

%% possible error
if length(nldas)~=nField
    error('wrong number of fields')
end

end

