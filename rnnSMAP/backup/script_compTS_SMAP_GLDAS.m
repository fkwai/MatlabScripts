% compare TS from SMAP and GLDAS SoilM
% tic
% SMAP=load('Y:\SMAP\SMAP_L2_q.mat');
% toc
% tic
% GLDAS=load('Y:\GLDAS\Hourly\GLDAS_NOAH_mat\GLDAS_NOAH_SoilM.mat');
% toc

lat=24;
lon=6;
%shapefile='Y:\SMAP\testingShape\PA.shp';
%shapefile='Y:\SMAP\testingShape\CA.shp';
shapefile='Y:\SMAP\testingShape\sahara.shp';

%% map comparison
shape=shaperead(shapefile);
mask = GridinShp(shape,SMAP.lon,SMAP.lat,0.25,1 );
mask(mask==0)=nan;
% find swath that covers mask
swath=[];
nsw=[];
tic
for i=1:length(SMAP.tnum)
    temp=SMAP.data(:,:,i).*mask;
    if ~isempty(find(~isnan(temp)))
        swath=[swath;i];
        nsw=[nsw;length(find(~isnan(temp)))];
    end
    if rem(i,1000)==0
        disp([num2str(i),': ',num2str(toc)])
    end
end
[temp,ix]=min(abs(SMAP.lon-lon));
[temp,iy]=min(abs(SMAP.lat-lat));

[temp,iswath]=max(nsw);
iSMAP=swath(iswath);
[temp,iGLDAS]=min(abs(SMAP.tnum(iSMAP)-GLDAS.tnum));
datestr(SMAP.tnum(iSMAP))
datestr(GLDAS.tnum(iGLDAS))
mapSMAP=SMAP.data(:,:,iSMAP);
mapGLDAS=GLDAS.data(:,:,iGLDAS);
tnum=SMAP.tnum(iSMAP);

mrange=[0,20];
mapSMAP_mask=mapSMAP.*mask;
mapGLDAS_mask=mapGLDAS.*mask;
mapGLDAS_mask(isnan(mapSMAP_mask))=nan;
showMap(mapGLDAS_mask,SMAP.lat,SMAP.lon)
title(['GLDAS: ',datestr(tnum)])
colorbar;caxis(mrange);colormap(flipud(jet))
showMap(mapSMAP_mask,GLDAS.lat,GLDAS.lon)
title(['SMAP: ',datestr(tnum)])
colorbar;caxis(mrange);colormap(flipud(jet))

figure
plot(mapSMAP_mask(:),mapGLDAS_mask(:),'b.');hold on
plot121Line
xlabel('SMAP')
ylabel('GLDAS')

v=reshape(SMAP.data(iy,ix,:),[length(SMAP.tnum),1]);
t=SMAP.tnum;
ind=find(~isnan(v));
tsSMAP.v=v(ind);
tsSMAP.t=t(ind);
tsGLDAS.v=reshape(GLDAS.data(iy,ix,1:end-8),[length(GLDAS.tnum),1]);
tsGLDAS.t=GLDAS.tnum;
plotTS(tsSMAP,'r-o');hold on
plotTS(tsGLDAS,'b');hold off
legend('SMAP','GLDAS')
title(['lat = ',num2str(SMAP.lat(iy)),'; ','lon = ',num2str(SMAP.lon(ix))])









