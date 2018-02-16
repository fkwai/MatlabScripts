function data = readTRMM(t,varargin)
% read TRMM daily data for given date

% latTRMM=[-49.875:0.25:49.875]';
% lonTRMM=-179.875:0.25:179.875;

pnames={'field','dirTRMM'};
dflts={'precipitation',[]};
[fieldName,dirTRMM]=...
    internal.stats.parseArgs(pnames, dflts, varargin{:});

if isempty(dirTRMM)
    global kPath
    dirTRMM=kPath.TRMM_daily;
end

tnum=datenumMulti(t);
yStr=datestr(tnum,'yyyy');
mStr=datestr(tnum,'mm');
dStr=datestr(tnum,'yyyymmdd');

fileName=[dirTRMM,filesep,yStr,filesep,mStr,filesep,'3B42_Daily.',dStr,'.7.nc4'];
data = ncread(fileName,fieldName);

% lat=-49.875:0.25:49.875;
% lon=-179.875:0.25:179.875;
data(data<0)=nan;

end

