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

h = waitbar(0, 'Subsetting CRUNCEP TRMM... 0%');
time_used = 0;
for i=1:length(datenums)
    tic
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
    
    time_used = time_used + toc;
    pct_done = i / length(datenums);
    waitbar(pct_done, h, ['Subsetting CRUNCEP TRMM...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end
close(h)

