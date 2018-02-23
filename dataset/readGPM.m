function [ data,lat,lon ] = readGPM( t,varargin )
% read GPM daily data for given date


pnames={'field','dirGPM'};
dflts={'precipitationCal',[]};
[fieldName,dirGPM]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

if isempty(dirGPM)
    global kPath
    dirGPM=kPath.GPM;
end

tnum=datenumMulti(t);
yStr=datestr(tnum,'yyyy');
mStr=datestr(tnum,'mm');
dStr=datestr(tnum,'yyyymmdd');

lat=[89.95:-0.1:-89.95]';
lon=-179.95:0.1:179.95;

fileName=[dirGPM,yStr,filesep,mStr,filesep,'3B-DAY.MS.MRG.3IMERG.',dStr,'-S000000-E235959.V05.nc4'];

dataTemp=ncread(fileName,fieldName);
dataTemp(dataTemp<0)=nan;
data=flipud(dataTemp);
end

