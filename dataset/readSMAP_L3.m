function [data,lat,lon] = readSMAP_L3(t)
%read SMAP L2 data from Y:\SMAP\SPL3SMP.003
% t: time num for a given date
% data: all swath contains in that day
% lat,lon,tnum: 1d vector for lat, lon and time (hour, min, second)

tt=datenumMulti(t,1);

global kPath
folder=[kPath.SMAP_L3,datestr(tt,'yyyy.mm.dd'),kPath.s];

files = dir([folder,'*.h5']);
nfiles=length(files);

if nfiles~=0
    filename=[folder,files(1).name];    
    [data,lat,lon]=readSMAP(filename,'AM');
else
    data=[];
    lat=[];
    lon=[];
    disp(['no file at ',num2str(t)]);
end

end

