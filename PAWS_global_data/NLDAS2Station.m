function [ Stations ] = NLDAS2Station( boundingbox,daterange,proj,FORAdir,NOAHdir )
% grab weather data from NLDAS FORA dataset for watershed
% input:
% boundingbox = [lon_left, lat_bottom;lon_right lat_bottom, lat_up], same
% as matlab shape bounding box
% daterange = [sd(yyyymmdd), ed(yyyymmdd)]
% NLDASdir = NLDAS forcing data folder. Hourly mat files.

% example:
% FORAdir='Y:\NLDAS\Hourly\FORA_Hourly_mat_raw';
% NOAHdir='Y:\NLDAS\Hourly\NOAH_Hourly_mat_raw';
% boundingbox=[-76,40;-75,41]; %domain bounding box
% daterange=[20100101,20100201]; %start date and end date in yyyymmdd
% proj.lon0=cmz((boundingbox(1,1)+boundingbox(2,1))/2);
% proj.hs='N';

lon_left = boundingbox(1, 1);
lon_right = boundingbox(2, 1);
lat_bottom = boundingbox(1, 2);
lat_up = boundingbox(2, 2);
sd=datenum(num2str(daterange(1)),'yyyymmdd');
ed=datenum(num2str(daterange(2)),'yyyymmdd');
date=datenumMulti(sd:ed,2);


%% initial
load([FORAdir,'\',num2str(daterange(1)),'\TMP.mat'],'crd');
lat=unique(crd(:,2));
lon=unique(crd(:,1));
latsize=lat(2)-lat(1);
lonsize=lon(2)-lon(1);
ind=find(crd(:,1)>lon_left-lonsize & crd(:,1)<lon_right+lonsize...
    & crd(:,2)>lat_bottom-latsize & crd(:,2)<lat_up+latsize );

Stations = struct('id',{},'XYElev',{},'LatLong',{},'datenums',{},'prcp',{},...
    'Rad',{},'tmax',{},'tmin',{},'sphm',{},'awnd',{},'Pa',{});

tmin=zeros(length(ind),length(date));
tmax=zeros(length(ind),length(date));
awnd=zeros(length(ind),length(date));
sphm=zeros(length(ind),length(date));
Rad=zeros(length(ind),length(date));
pres=zeros(length(ind),length(date));
prcp=zeros(length(ind),length(date));

%FORA
for i=1:length(date)
    FORAfolder=[FORAdir,'\',num2str(date(i))];
    NOAHfolder=[NOAHdir,'\',num2str(date(i))];
    
    % temp
    load([FORAfolder,'\TMP.mat'])
    temp=TMP(ind,:);
    for j=1:length(ind)
        T=temp(j,:);
        fo = fitoptions('Method','NonlinearLeastSquares');
        ft=fittype(@(a,s,M,n,t) M*(1+a*sin(2*pi*(t-s)/n)),...
            'problem',{'n'},'independent','t','options',fo);
        [ftobj,ftgof,output]=fit(h,T',ft,'problem',{24});
        a=ftobj.a;
        tmin(j,i)=mean(T)-a;
        tmax(j,i)=mean(T)+a;
        %         figure
        %         rst=ftgof.rsquare;
        %         plot(h,T,'-')
        %         hold on
        %         plot(ftobj)
        %         legend('tmp','fitted tmp')
        %         hold off
    end
    
    % wind speed
    load([FORAfolder,'\UGRD.mat'])
    load([FORAfolder,'\VGRD.mat'])
    w1=UGRD(ind,:);
    w2=VGRD(ind,:);
    awnd(:,i)=mean(sqrt(w1.^2+w2.^2),2);
    
    % specific humidity
    load([FORAfolder,'\SPFH.mat'])
    sphm(:,i)=mean(SPFH(ind,:),2);
    
    % radiation
    load([FORAfolder,'\DSWRF.mat'])
    Rad(:,i)=mean(DSWRF(ind,:),2);
    
    % pressure
    load([FORAfolder,'\DSWRF.mat'])
    pres(:,i)=sum(DSWRF(ind,:),2);
    
    % Precipitation
    load([NOAHfolder,'\ASNOW.mat'])
    load([NOAHfolder,'\ARAIN.mat'])
    prcp(:,i)=sum(ASNOW(ind,:)+ARAIN(ind,:),2);
end

for n=1:length(ind)
    Stations(n).id =n;
    Stations(n).LatLong = [crd(ind(n),2),crd(ind(n),1)];
    [Stations(n).XYElev(1),Stations(n).XYElev(2)]=latlon2utm(Stations(n).LatLong(1),Stations(n).LatLong(2),proj.lon0,proj.hs);
    Stations(n).XYElev(3)=-9999;
    Stations(n).datenums=[sd:ed]';
    Stations(n).prcp=prcp(n,:)';
    Stations(n).tmax=tmin(n,:)';
    Stations(n).tmin=tmin(n,:)';
    Stations(n).awnd=awnd(n,:)';
    Stations(n).sphm=sphm(n,:)';
    Stations(n).Rad=Rad(n,:)';
    Stations(n).Pa=pres(n,:)';
end





end

