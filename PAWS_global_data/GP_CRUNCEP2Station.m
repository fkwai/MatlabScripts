 function [Stations] = CRUNCEP2Station(boundingbox,daterange,proj,prepdir,solardir,tempdir)
% grab weather data from CRUNCEP dataset for Amazonian watershed
% input: 
% boundingbox = [lon_left, lat_bottom;lon_right lat_bottom, lat_up], same
% as matlab shape bounding box
% daterange = [sd(yyyymmdd), ed(yyyymmdd)]
% prepdir, solardir, tempdir = clm forcing data directory

% example:
% prepdir='Y:\CLM_Forcing\atm_forcing.datm7.cruncep_qianFill.0.5d.V4.c130305\Precip6Hrly';
% boundingbox=[-76,40;-75,41]; %domain bounding box
% daterange=[19900101,19900201]; %start date and end date in yyyymmdd

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);

sd=datenum(num2str(daterange(1)),'yyyymmdd');
ed=datenum(num2str(daterange(2)),'yyyymmdd');
datenumsH=sd+0.125:0.25:ed+0.875;
datenums=sd:ed;


%% initial
files = dir(fullfile(prepdir,'clmforc*'));%Not that efficiency. Can modify later. 
longxy = readGPdata(fullfile(prepdir,files(1).name),'LONGXY');
if(~isempty(find(longxy>180, 1)))
    longxy(longxy>180)=longxy(longxy>180)-360;
end
%longxy(longxy > 180) = longxy(longxy > 180) - 360;
latixy = readGPdata(fullfile(prepdir,files(1).name),'LATIXY');
lonind = find(longxy(:,1)>lon_left & longxy(:,1)<lon_right)';
latind = find(latixy(1,:)>lat_bottom & latixy(1,:)<lat_up);
longxy_range=[lonind(1)-2,lonind(1)-1,lonind,lonind(end)+1,lonind(end)+2];  % 1 cell buffer
latixy_range=[latind(1)-2,latind(1)-1,latind,latind(end)+1,latind(end)+2];
Stations = struct('id',{},'XYElev',{},'LatLong',{},'datenums',{},'prcp',{},...
    'rrad',{},'tmax',{},'tmin',{},'hmd',{},'awnd',{},'hli',{},'Pa',{});
n = 0;
for i = longxy_range
    for j = latixy_range
        n = n + 1;
        Stations(n).id = n;
        Stations(n).LatLong = [latixy(i,j), longxy(i,j)];
        [Stations(n).XYElev(1),Stations(n).XYElev(2)]=GP_latlon2utm(Stations(n).LatLong(1),Stations(n).LatLong(2),proj.lon0,proj.hs);
        Stations(n).XYElev(3)=-99.99;
        Stations(n).datenums=datenums';     
    end
end

%% Prep
%files = dir(fullfile(prepdir,'*.nc')); %read all files names on line 26
files = CRUNCEP_daterange( files,daterange );
h = waitbar(0, 'Reading Prep... 0%');
time_used = 0;
for nf = 1 : length(files)
    tic;
    file = fullfile(prepdir,files(nf).name);
    time = double(readGPdata(file, 'time'));
    tempdatenum = time + datenum([file(end-9:end-3),'-01 00:00:00']);
    [C,ind1,ind2]=intersect(datenumsH,tempdatenum);
    prectmms = readGPdata(file,'PRECTmms');    % unit: mm/s
    n = 0;
    for i = longxy_range
        for j = latixy_range
            n = n + 1;
            prcp_temp = reshape(prectmms(i,j,:),[size(prectmms,3), 1]);
            prcp=zeros(length(datenumsH),1)*nan;
            prcp(ind1) = prcp_temp(ind2);
            Stations(n).prcp=h2d(prcp).*60*60*24;
        end
    end
    time_used = time_used + toc;
    pct_done = nf / length(files);
    waitbar(pct_done, h, ['Reading Prep...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end


%%Rad
files = dir(fullfile(solardir,'clmforc*'));
files = CRUNCEP_daterange( files,daterange );

h = waitbar(0, 'Reading Rad... 0%');
time_used = 0;
for nf = 1 : length(files)
    tic;
    file = fullfile(solardir,files(nf).name);
    time = double(readGPdata(file, 'time'));
    tempdatenum = time + datenum([file(end-9:end-3),'-01 00:00:00']);
    [C,ind1,ind2]=intersect(datenumsH,tempdatenum);
    fsds = readGPdata(file, 'FSDS');    % unit: W/m^2
    n = 0;
    for i = longxy_range
        for j = latixy_range
            n = n + 1;
            fsds_temp = reshape(fsds(i,j,:),[size(fsds,3), 1]);
            rrad=zeros(length(datenumsH),1)*nan;
            rrad(ind1) = fsds_temp(ind2);
            Stations(n).rrad=h2d(rrad);
        end
    end
    time_used = time_used + toc;
    pct_done = nf / length(files);
    waitbar(pct_done, h, ['Reading Rad...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end

%%Temp
files = dir(fullfile(tempdir,'clmforc*'));
files = CRUNCEP_daterange( files,daterange );

h = waitbar(0, 'Reading Temp... 0%');
time_used = 0;
for nf = 1 : length(files)
    tic;
    file = fullfile(tempdir,files(nf).name);
    time = double(readGPdata(file, 'time'));
    tempdatenum = time + datenum([file(end-9:end-3),'-01 00:00:00']);
    [C,ind1,ind2]=intersect(datenumsH,tempdatenum);
    tbot = readGPdata(file, 'TBOT');    % unit: K
    qbot = readGPdata(file, 'QBOT');    % unit: kg/kg
    wind = readGPdata(file, 'WIND');    % unit: m/s
    flds = readGPdata(file, 'FLDS');    % unit: W/m^2
    psrf = readGPdata(file, 'PSRF');    % unit: Pa
    n = 0;
    for i = longxy_range
        for j = latixy_range
            n = n + 1;
            tbot_temp = reshape(tbot(i,j,:),[size(tbot,3), 1]);
            qbot_temp = reshape(qbot(i,j,:),[size(qbot,3), 1]);
            wind_temp = reshape(wind(i,j,:),[size(wind,3), 1]);
            flds_temp = reshape(flds(i,j,:),[size(flds,3), 1]);
            psrf_temp = reshape(psrf(i,j,:),[size(psrf,3), 1]);
            
            tmp=zeros(length(datenumsH),1)*nan;
            hmd=zeros(length(datenumsH),1)*nan;
            awnd=zeros(length(datenumsH),1)*nan;
            hli=zeros(length(datenumsH),1)*nan;
            Pa=zeros(length(datenumsH),1)*nan;
            
            tmp(ind1) = tbot_temp(ind2)-273.15;
            hmd(ind1) = qbot_temp(ind2);
            awnd(ind1) = wind_temp(ind2);
            hli = flds_temp(ind2);
            Pa = psrf_temp(ind2);
            
            Stations(n).tmax = h2d(tmp,'max');
            Stations(n).tmin = h2d(tmp,'min');
            Stations(n).hmd = h2d(hmd);
            Stations(n).awnd = h2d(awnd);
            Stations(n).hli = h2d(hli);
            Stations(n).Pa = h2d(Pa);
        end
    end
    time_used = time_used + toc;
    pct_done = nf / length(files);
    waitbar(pct_done, h, ['Reading Temp...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end
end

function [ out ] = h2d(data,varargin)
temp=reshape(data,4,length(data)/4);
if length(varargin)>0   %use other operator
    opt=varargin{1};
    tempmean=eval([opt,'(temp)']);
else    
    tempmean=mean(temp);
end
    out=tempmean';
end
