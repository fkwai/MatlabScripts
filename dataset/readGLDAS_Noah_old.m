function [ data,lat,lon,tnum,fieldLst ] = readGLDAS_Noah_old( t,fieldind )
%read GLDAS NOAH (v1, 0.25 deg) data for given field number, which can be find from
%wgrib.
% hardcode to size 600,1440

% t: time num for a given date
% fieldnum: the index of field that can be find form wgrib or read_grib(filename,ParamTable,'invent')
% data: all swath contains in that day
% lat,lon,tnum: 1d vector for lat, lon and time (hour, min, second)


GLDASdir='/mnt/sdb1/Database/GLDAS/';
% default to put parameter table inside GLDAS root folder
ParamTable=['GLDASdir',filesep,'gribtab_GLDAS_NOAH.txt'];

dn=datenumMulti(t,1);
Y=year(dn);
d1=datenumMulti(Y*10000+101,1);
D=dn-d1+1;

folder=[GLDASdir,filesep,'GLDAS_NOAH025_3H.2.1',filesep,num2str(Y),filesep,sprintf('%3.3d',D),filesep];
files = dir([folder,'*.grb']);
nfiles=length(files);
tnum=zeros(nfiles,1);

if fieldind~=-1
    nField=length(fieldind);
else
    nField=38;
end

%% read data
if fieldind~=-1
    data=zeros(600,1440,nfiles)*nan;
else
    data=zeros(600,1440,nfiles,nField)*nan;
end

for i=1:nfiles
    filename=[folder,files(i).name];
    %     if ~exist(filename)
    %         error('wrong file name')
    %     end
    %
    gldas=read_grib(filename,ParamTable,fieldind,'ScreenDiag',0);
    ttemp=datenum(gldas.pds.year,gldas.pds.month,gldas.pds.day,...
        gldas.pds.hour,gldas.pds.min,0);
    tnum(i)=ttemp;
    
    if fieldind~=-1
        data1D=gldas.fltarray;
        datatemp=reshape(data1D,[1440,600]);
        data(:,:,i)=rot90(datatemp);
    else
        for k=1:nField
            data1D=gldas(k).fltarray;
            datatemp=reshape(data1D,[1440,600]);
            data(:,:,i,k)=rot90(datatemp);
        end
    end
end

% hard code lat and lon to improve efficiency
lat=[89.875:-0.25:-59.875]';
lon=[-179.875:0.25:179.875];

%% field Name
fieldLst={gldas.parameter};
for k=1:length(gldas)
    if ~strcmp(gldas(k).level,'surface')
        ind=find(gldas(k).level==' ');
        levStr=gldas(k).level(1:ind-1);
        fieldLst{k}=[fieldLst{k},'_',levStr];
    end
end

end

