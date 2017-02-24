function [Stations] = GP_CRUNCEP2Station(boundingbox,daterange,proj,prepdir,solardir,tempdir)
% grab weather data from CRUNCEP dataset for Amazonian watershed
% input:
% boundingbox = [lon_left, lat_bottom;lon_right, lat_up], same
% as matlab shape bounding box
% daterange = [sd(yyyymmdd), ed(yyyymmdd)]
% prepdir, solardir, tempdir = clm forcing data directory

% example:
% prepdir='Y:\CLM_Forcing\atm_forcing.datm7.cruncep_qianFill.0.5d.V4.c130305\Precip6Hrly';
% solardir='Y:\CLM_Forcing\atm_forcing.datm7.cruncep_qianFill.0.5d.V4.c130305\Solar6Hrly';
% tempdir='Y:\CLM_Forcing\atm_forcing.datm7.cruncep_qianFill.0.5d.V4.c130305\TPHWL6Hrly';
% boundingbox=[-76,40;-75,41]; %domain bounding box
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
datenumsH=sd+1/24:1/24:ed+1;
datenums=sd:ed;
indMatH=reshape(1:length(datenumsH),[24,length(datenums)]);
indMatH_month=reshape(1:31*24,[24,31]);



%% initial
files = dir(fullfile(prepdir,'clmforc*'));%Not that efficiency. Can modify later.
longxy = readGPdata(fullfile(prepdir,files(1).name),'LONGXY');
if(~isempty(find(longxy>180, 1)))
    longxy(longxy>180)=longxy(longxy>180)-360;
end
latixy = readGPdata(fullfile(prepdir,files(1).name),'LATIXY');

[longxy_range,latixy_range]=bound2ind( boundingbox,longxy(:,1),latixy(1,:),0);

Stations = struct('id',{},'XYElev',{},'LatLong',{},'datenums',{},'prcp',{},...
    'rrad',{},'tmax',{},'tmin',{},'hmd',{},'awnd',{},'hli',{},'Pa',{});
field={'prcp','rrad','tmax','tmin','hmd','awnd','hli','Pa'};

n = 0;
for i = longxy_range
    for j = latixy_range
        n = n + 1;
        Stations(n).id = n;
        Stations(n).LatLong = [latixy(i,j), longxy(i,j)];
        [Stations(n).XYElev(1),Stations(n).XYElev(2)]=GP_latlon2utm(Stations(n).LatLong(1),Stations(n).LatLong(2),proj.lon0,proj.hs);
        Stations(n).XYElev(3)=-99.99;
        Stations(n).datenums=datenums';
        for k=1:length(field)
            if k==1||k==3||k==4
                Stations(n).(field{k})=zeros(length(datenums),1)*nan;
            else
                Stations(n).(field{k})=zeros(length(datenumsH),1)*nan;
            end
        end
    end
end

%% Prep
%files = dir(fullfile(prepdir,'*.nc')); %read all files names on line 26
files = CRUNCEP_daterange( files,daterange );
h = waitbar(0, 'Reading CRUNCEP Prep... 0%');
time_used = 0;
for nf = 1 : length(files)
    tic;
    file = fullfile(prepdir,files(nf).name);
    time = double(readGPdata(file, 'time'));
    filename_split=strsplit(file,'.');
    file_time=filename_split{end-1};
    
    tempdatenumCRUNCEP = time + datenum([file_time,'-01 00:00:00']);
    tempdatenum=unique(floor(tempdatenumCRUNCEP));
    [C,indD1,indD2]=intersect(datenums,tempdatenum);
    
    prectmms = readGPdata(file,'PRECTmms');    % unit: mm/s
    n = 0;
    for i = longxy_range
        for j = latixy_range
            n = n + 1;
            prcp_temp = reshape(prectmms(i,j,:),[size(prectmms,3), 1]);
            prcp_tempD=h2d(prcp_temp);
            
            Stations(n).prcp(indD1)=prcp_tempD(indD2).*60*60*24;
        end
    end
    time_used = time_used + toc;
    pct_done = nf / length(files);
    waitbar(pct_done, h, ['Reading CRUNCEP Prep...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end
close(h)

%% Rad

% sunset
Rs=zeros(length(datenumsH),length(Stations));
h = waitbar(0, 'Calculating Sunset time.. 0%');
time_used = 0;
for ns = 1 : length(Stations)
    tic
    zd = timezone(Stations(ns).LatLong(2), 'degrees');
    cy=0;
    for i=1:length(datenumsH)
        dd=datenumsH(i);
        yr=year(dd);
        if yr~=cy
            cy=yr;
            [eccen, obliq, mvelp, obliqr, lambm0, mvelpp] = shr_orb_params(yr, 0, 0, 0, false);
        end
        d=floor(dd-datenumMulti(yr*10000+101,1)+1);
        hr=(dd-floor(dd))*24;
        JDG = d + (hr - 0.5 + zd) / 24;
        [decl, eccf] = shr_orb_decl(JDG, eccen, mvelpp, lambm0, obliqr);
        sDD = sin(decl);
        cosz = shr_orb_cosz(JDG, Stations(ns).LatLong(1)*pi/180.0, Stations(ns).LatLong(2)*pi/180.0, decl);
        Psi = acos(cosz);
        if(cosz < 0.0 || (cosz > 0.0D0 && Psi*180.0/pi >= 90.0))
            Rs(i,ns)=0;
        else
            Rs(i,ns)=1;
        end
    end
    
    time_used = time_used + toc;
    pct_done = ns / length(Stations);
    waitbar(pct_done, h, ['Calculating Sunset time...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end
close(h)


files = dir(fullfile(solardir,'clmforc*'));
files = CRUNCEP_daterange( files,daterange );

h = waitbar(0, 'Reading CRUNCEP Rad... 0%');
time_used = 0;
for nf = 1 : length(files)
    tic;
    file = fullfile(solardir,files(nf).name);
    time = double(readGPdata(file, 'time'));
    filename_split=strsplit(file,'.');
    file_time=filename_split{end-1};
    
    tempdatenumCRUNCEP = time + datenum([file_time,'-01 00:00:00']);
    tempdatenum=unique(floor(tempdatenumCRUNCEP));
    tempdatenumH=tempdatenum(1)+[1/24:1/24:length(tempdatenum)];
    [C,indD1,indD2]=intersect(datenums,tempdatenum);
    indH1=reshape(indMatH(:,indD1),[24*length(indD1),1]);
    indH2=reshape(indMatH_month(:,indD2),[24*length(indD2),1]);
    %[C,indH1,indH2]=intersect(datenumsH,tempdatenumH); % NOT WORK DUE TO
    %TOLORENCE
    
    fsds = readGPdata(file, 'FSDS');    % unit: W/m^2
    n = 0;
    for i = longxy_range
        for j = latixy_range
            n = n + 1;
            fsds_temp = reshape(fsds(i,j,:),[size(fsds,3), 1]);
            rs=Rs(indH1,n);
            rs_month=zeros(length(time)*6,1);
            rs_month(indH2)=rs;
            fsds_tempH=h2h_rad(fsds_temp,time,rs_month);
            Stations(n).rrad(indH1)=fsds_tempH(indH2);
        end
    end
    time_used = time_used + toc;
    pct_done = nf / length(files);
    waitbar(pct_done, h, ['Reading CRUNCEP Rad...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end
close(h)


%% Temp
files = dir(fullfile(tempdir,'clmforc*'));
files = CRUNCEP_daterange( files,daterange );

h = waitbar(0, 'Reading CRUNCEP Climate... 0%');
time_used = 0;
for nf = 1 : length(files)
    tic;
    file = fullfile(tempdir,files(nf).name);
    time = double(readGPdata(file, 'time'));
    filename_split=strsplit(file,'.');
    file_time=filename_split{end-1};
    
    tempdatenumCRUNCEP = time + datenum([file_time,'-01 00:00:00']);
    tempdatenum=unique(floor(tempdatenumCRUNCEP));
    tempdatenumH=tempdatenum(1)+[1/24:1/24:length(tempdatenum)];
    [C,indD1,indD2]=intersect(datenums,tempdatenum);
    indH1=reshape(indMatH(:,indD1),[24*length(indD1),1]);
    indH2=reshape(indMatH_month(:,indD2),[24*length(indD2),1]);
    
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
            
            tmax_tempD=h2d(tbot_temp,'max');
            tmin_tempD=h2d(tbot_temp,'min');
            qbot_tempH=h2h(qbot_temp,time);
            wind_tempH=h2h(wind_temp,time);
            flds_tempH=h2h(flds_temp,time);
            psrf_tempH=h2h(psrf_temp,time);
            
            Stations(n).tmax(indD1)=tmax_tempD(indD2)-273.15;
            Stations(n).tmin(indD1)=tmin_tempD(indD2)-273.15;
            Stations(n).hmd(indH1)=qbot_tempH(indH2);
            Stations(n).awnd(indH1)=wind_tempH(indH2);
            Stations(n).hli(indH1)=flds_tempH(indH2);
            Stations(n).Pa(indH1)=psrf_tempH(indH2);
        end
    end
    time_used = time_used + toc;
    pct_done = nf / length(files);
    waitbar(pct_done, h, ['Reading CRUNCEP Climate...',num2str(pct_done*100,'%.2f'), ...
        '%, time used: ', num2str(time_used,'%.1f'), ' sec'])
end
close(h)

%% fix leapyear
date=datevec(datenums);
indleapD=find(date(:,2)==2&date(:,3)==29);
indleapH=reshape(indMatH(:,indleapD),[24*length(indleapD),1]);
if indleapD(1)==1||indleapD(end)==length(datenums)
    error('do not put 2/29 as start or end date')
end
for n=1:length(Stations)
    for k=1:length(field)
        if k==1||k==3||k==4
            temp=Stations(n).(field{k});
            temp1=temp(indleapD-1);
            temp2=temp(indleapD+1);
            temp(indleapD)=(temp1+temp2)/2;
            Stations(n).(field{k})=temp;
        else
            temp=Stations(n).(field{k});
            temp1=temp(indleapH-24);
            temp2=temp(indleapH+24);
            temp(indleapH)=(temp1+temp2)/2;
            Stations(n).(field{k})=temp;
        end
    end
end

%% fix other nan
for k=1:length(field)
    for n=1:length(Stations)
        temp=Stations(n).(field{k});
        indnan=find(isnan(temp));
        if ~isempty(indnan)
            disp(['CRUNCEP Station ',num2str(i),' field ',field{k},' has '...
                ,num2str(length(indnan)),' nan values'])
            indv=find(~isnan(temp));
            vnan=interp1(indv,temp(indv),indnan);
            temp(indnan)=vnan;
            Stations(i).(field{k})=temp;
        end
    end
end


end

function [ out ] = h2d(data,varargin)
% 4h to day
temp=reshape(data,4,length(data)/4);
if ~isempty(varargin)   %use other operator
    opt=varargin{1};
    tempmean=eval([opt,'(temp)']);
else
    tempmean=mean(temp);
end
out=tempmean';

end

function [ out ] = h2h(data,time)
% 4h to 1h
nday=length(data)/4;
outtime=1/24:1/24:nday;
out = interp1(time, data, outtime, 'pchip');

end

function [ out ] = h2h_rad(data,time,rs)
% 4h to 1h - rad, rs is 0/1 of sunset or sunrise
nday=length(data)/4;
outtime=1/24:1/24:nday;

temptime=0:1/24:nday;
temp=ones(1+nday*24,1)*-99;
inddata=1+time*24;
temp(inddata)=data;
temp(2:end)=temp(2:end).*rs;
indNan=find(temp==-99);
temptime(indNan)=[];
temp(indNan)=[];

out = interp1(temptime, temp, outtime, 'pchip');

end
