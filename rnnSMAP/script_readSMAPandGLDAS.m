% read all smap data
sd=20150331;
ed=20160901;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
dataSMAP=[];
tnumSMAP=[];
lat0=[];
lon0=[];
for t=sdn:edn
    disp(datestr(t))
    [data,lat,lon,tnum] = readSMAP_L2(t);
    dataSMAP=cat(3,dataSMAP,data);
    tnumSMAP=cat(1,tnumSMAP,tnum);
    if ~isequal(lat,lat0)
        disp([datestr(t),' : lat not equal'])
    end
    if ~isequal(lon,lon0)
        disp([datestr(t),' : lon not equal'])
    end
    lat0=lat;
    lon0=lon;
end
data=dataSMAP;
tnum=tnumSMAP;
save Y:\SMAP\SMAP_L2.mat data lat lon tnum -v7.3


% interp to GLDAS
load('Y:\SMAP\SMAP_L2.mat')
dataSMAP_q=zeros(600,1440,length(tnumSMAP));
[dataGLDAS,latGLDAS,lonGLDAS,tnumGLDAS] = readGLDAS_NOAH( 20160101,18 );
for i=1:length(tnumSMAP)
    i
    tic
    dataSMAP_q(:,:,i)=interp_grid(lonSMAP,latSMAP,dataSMAP(:,:,i),lonGLDAS,latGLDAS)*100;
    toc
end

lon=lonGLDAS;
lat=latGLDAS;
data=dataSMAP_q;
tnum=tnumSMAP;
save Y:\SMAP\SMAP_L2_q.mat data lat lon tnum -v7.3

% read all GLDAS data
sd=20150331;
ed=20160901;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
dataGLDAS=zeros(600,1440,8*length(sdn:edn))*nan;
tnumGLDAS=[];
lat0=[];
lon0=[];
k=1;
for t=sdn:edn-1 % 
    tic
    disp(datestr(t))
    [data,lat,lon,tnum] = readGLDAS_NOAH(t,8);
    dataGLDAS(:,:,k:k+7)=data;
    k=k+8;
    tnumGLDAS=cat(1,tnumGLDAS,tnum);
    toc
end
data=dataGLDAS(:,:,1:end-8);
tnum=tnumGLDAS;
save Y:\GLDAS\Hourly\GLDAS_NOAH_mat\GLDAS_NOAH_Evp.mat data lat lon tnum -v7.3

