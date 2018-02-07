function [data,lat,lon,tnum] = readSMAP_L2(t,varargin)
%read SMAP L2 data from Y:\SMAP\SPL2SMP.003
% t: time num for a given date
% data: all swath contains in that day
% lat,lon,tnum: 1d vector for lat, lon and time (hour, min, second)

pnames={'readCrd','lat','lon'};
dflts={1,[],[]};
[readCrd,lat,lon]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

tt=datenumMulti(t,1);

global kPath
folder=[kPath.SMAP_L2,datestr(tt,'yyyy.mm.dd'),kPath.s];
file = dir([folder,'*.h5']);
nfile=length(file);
tnum=zeros(nfile,1);

%% init grid from ease grid, see datasetGrid.m
if isempty(lat) || isempty(lon)
    gridFile=[kPath.SMAP,filesep,'gridEASE_36'];
    gridEASE=load(gridFile);
    lat=gridEASE.lat;
    lon=gridEASE.lon;
end
ny=length(lat);
nx=length(lon);
data=zeros(ny,nx,nfile)*nan;
tnum=zeros(nfile,1)*nan;

%% read data
for i=1:nfile
    filename=[folder,file(i).name];
    C=strsplit(filename,'_');
    tstr=C{7};
    t=datenum(strrep(tstr,'T','-'),'yyyymmdd-HHMMSS');
    
    [ datai,lati,loni ]=readSMAP(filename,'SPL2SMP.004','readCrd',readCrd);
    datai2d=zeros(ny,nx)*nan;
    
    val=find(~isnan(datai));
    for j=1:length(val)
        templat=lati(val(j));
        templon=loni(val(j));
        tempdata=datai(val(j));
        datai2d(lat==templat,lon==templon)=tempdata;
    end
    data(:,:,i)=datai2d;
    tnum(i)=t;
end

end

