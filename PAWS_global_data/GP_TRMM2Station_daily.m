function [ Stations ] = GP_TRMM2Station_daily(boundingbox,daterange,proj,TRMMdir)
%TRMM2STATION Summary of this function goes here
%   Detailed explanation goes here
% TRMMdir='Y:\TRMM\daily\'
% boundingbox=[-60.375,-2.875;-58.875,-1.875]
% daterange=[20000115,20000315]; %start date and end date in yyyymmdd
% proj.lon0=cmz((boundingbox(1,1)+boundingbox(2,1))/2);
% lat0=(boundingbox(1,2)+boundingbox(2,2))/2;
% if(lat0>0)
%     proj.hs='N';
% else
%     proj.hs='S';
% end


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
        [long_range,lati_range]=bound2ind( boundingbox,lon,lat,0);
        Stations = struct('id',{},'XYElev',{},'LatLong',{},'datenums',{},'prcp',{},...
            'rrad',{},'tmax',{},'tmin',{},'hmd',{},'awnd',{},'hli',{},'Pa',{});
        n=0;
        for ii = long_range
            for jj = lati_range
                n=n+1;
                Stations(n).id = n;
                Stations(n).LatLong = [lat(jj), lon(ii)];
                [Stations(n).XYElev(1),Stations(n).XYElev(2)]=...
                    GP_latlon2utm(Stations(n).LatLong(1),Stations(n).LatLong(2),proj.lon0,proj.hs);
                Stations(n).XYElev(3)=-99.99;
                Stations(n).datenums=datenums';
                Stations(n).prcp=ones(length(datenums),1)*nan;
            end
        end
        h = waitbar(0, 'Reading TRMM... 0%');
        time_used = 0;
    end
    
    tic;
    
    r = readGPdata(file, 'r');
    n = 0;
    for ii = long_range
        for jj = lati_range
            n=n+1;
            Stations(n).prcp(i)=r(ii,jj);
        end
    end
    
    time_used = time_used + toc;
    pct_done = i / length(datenums);
    waitbar(pct_done, h, ['Reading TRMM...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
    
end
close(h)

end

