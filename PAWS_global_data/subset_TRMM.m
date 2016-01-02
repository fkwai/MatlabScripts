function subset_TRMM( boundingbox,daterange,TRMMdir,TRMMdirNEW)
%SUBSET_TRMM Summary of this function goes here
%   Detailed explanation goes here

if ~exist(TRMMdirNEW,'dir')
    mkdir(TRMMdirNEW);
end

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);

sd=datenum(num2str(daterange(1)),'yyyymmdd');
ed=datenum(num2str(daterange(2)),'yyyymmdd');
datenums=sd:ed;

for i=1:length(datenums)
    file = [TRMMdir,'\3B42_daily.',datestr(datenums(i), 'yyyy.mm.dd'),'.7.nc'];
    file=checkMatNc(file);
    lat=readGPdata(file,'latitude');
    lon=readGPdata(file,'longitude');
    rr = readGPdata(file, 'r');
    if(~isempty(find(lon>180, 1)))
        lon(lon>180)=lon(lon>180)-360;
    end
    long_range = find(lon>=lon_left & lon<=lon_right);
    lati_range = find(lat>=lat_bottom & lat<=lat_up);
    
    latitude=lat(lati_range);
    longitude=lon(long_range);
    r=rr(long_range,lati_range);
    
    [pathstr,name,ext]=fileparts(file);
    matfile=[TRMMdirNEW,'\',name,'.mat'];
    save(matfile,'r','latitude','longitude');
end

