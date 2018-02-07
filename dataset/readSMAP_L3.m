function [data,lat,lon] = readSMAP_L3(t,varargin)
%read SMAP L2 data from Y:\SMAP\SPL3SMP.003
% t: time num for a given date
% data: all swath contains in that day
% lat,lon,tnum: 1d vector for lat, lon and time (hour, min, second)

pnames={'readCrd','field','dataDir'};
dflts={0,[],[]};
[readCrd,fieldName,dataDir]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

tt=datenumMulti(t,1);

if isempty(dataDir)
    global kPath
    dataDir=kPath.SMAP_L3;
end
folder=[dataDir,datestr(tt,'yyyy.mm.dd'),filesep];

files = dir([folder,'*.h5']);
nfiles=length(files);

if nfiles~=0
    filename=[folder,files(1).name];    
    [data,lat,lon]=readSMAP(filename,'SPL3SMAP.004','readCrd',readCrd,'field',fieldName);
else
    data=[];
    lat=[];
    lon=[];
    disp(['no file at ',num2str(t)]);
end

end

