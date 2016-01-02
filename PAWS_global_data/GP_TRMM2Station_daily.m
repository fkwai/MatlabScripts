function [ Stations ] = TRMM2Station_daily(boundingbox,daterange,proj,TRMMdir)
%TRMM2STATION Summary of this function goes here
%   Detailed explanation goes here

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);
lon0=cmz((lon_left+lon_right)/2);

sd=datenum(num2str(daterange(1)),'yyyymmdd');
ed=datenum(num2str(daterange(2)),'yyyymmdd');
datenums=sd:ed;


for i=1:length(datenums)
    file = [TRMMdir,'\3B42_daily.', datestr(datenums(i), 'yyyy.mm.dd'), '.7.nc'];
    if ~exist(file,'file')
        file = [TRMMdir,'\3B42_daily.',datestr(datenums(i), 'yyyy.mm.dd'),'.7.mat'];
        if ~exist(file,'file')
            error('failed to find default TRMM file (3B42 daily)')
        end
    end
    if i==1        %initial
        lat=readGPdata(file,'latitude');
        lon=readGPdata(file,'longitude');
        if(~isempty(find(lon>180, 1)))
            lon(lon>180)=lon(lon>180)-360;
        end
        lonind = find(lon>lon_left & lon<lon_right);
        latind = find(lat>lat_bottom & lat<lat_up);
        long_range=[lonind(1)-2;lonind(1)-1;lonind;lonind(end)+1;lonind(end)+2];  % 1 cell buffer
        lati_range=[latind(1)-2;latind(1)-1;latind;latind(end)+1;latind(end)+2];
        Stations = struct('id',{},'XYElev',{},'LatLong',{},'datenums',{},'prcp',{},...
            'rrad',{},'tmax',{},'tmin',{},'hmd',{},'awnd',{},'hli',{},'Pa',{});
        n=0;
        for ii = long_range'
            for jj = lati_range'
                n=n+1;
                Stations(n).id = n;
                Stations(n).LatLong = [lat(jj), lon(ii)];
                [Stations(n).XYElev(1),Stations(n).XYElev(2)]=...
                    GP_latlon2utm(Stations(n).LatLong(1),Stations(n).LatLong(2),proj.lon0,proj.hs);
                Stations(n).XYElev(3)=-99.99;
                Stations(n).datenums=datenums';
                Stations(n).prcp=ones(length(datenums),1)*-99;
            end
        end
    end
    r = readGPdata(file, 'r');
    n = 0;
    for ii = long_range'
        for jj = lati_range'
            n=n+1;
            Stations(n).prcp(i)=r(ii,jj);
        end
    end
    
    
end

end

