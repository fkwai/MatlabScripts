function [ TRMM,t,lat,lon] = TRMMread_monthly(TRMMdir,daterange )
%TRMM2STATION Summary of this function goes here
%   Detailed explanation goes here

% TRMMdir='Y:\TRMM\daily';
% daterange=[200201,201408];

files = dir(fullfile(TRMMdir,'*.nc'));
C = strsplit(files(1).name,'.');
sd=[C{2:4}];
d1=str2num(C{4});
C = strsplit(files(end).name,'.');
ed=[C{2:4}];
d2=str2num(C{4});
d2e=eomday(str2num(C{2}),str2num(C{3}));
sdn=datenum(sd,'yyyymmdd');
edn=datenum(ed,'yyyymmdd');
ymall=str2num(datestr(sdn:edn,'yyyymm'));

if length(files)~=length(ymall)
    error('missing data');  %probably bug, order of files must be ascend. 
end

if isempty(daterange)
    ym=unique(ymall);
    if(d1~=1)
        ym=ym(2:end);
    end
    if(d2~=d2e)
        ym=ym(1:end-1);
    end
else
    sd=daterange(1);
    ed=daterange(2);
    sdn=datenum(num2str(sd),'yyyymm');
    edn=datenum(num2str(ed),'yyyymm');
    ym=unique(str2num(datestr(sdn:edn,'yyyymm')));
end

lat=ncread(fullfile(TRMMdir,files(1).name),'latitude');
lon=ncread(fullfile(TRMMdir,files(1).name),'longitude');

data=zeros(length(lon),length(lat),length(ym));
t=ym;
for i=1:length(ym)
    i
    ind=find(ymall==ym(i));    
    tempS=zeros(length(lon),length(lat));
    for j=1:length(ind)                
        temp=ncread(fullfile(TRMMdir,files(ind(j)).name),'r');
        tempS=tempS+temp;        
    end
    data(:,:,i)=tempS;
end
TRMM=rot90_3D(data,3,1);
lat=flipud(lat);
lon=lon';
end



