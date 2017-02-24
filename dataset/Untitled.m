t=20160323;
[dataSMAP,latSMAP,lonSMAP,tnumSMAP] = readSMAP_L2(t);
[dataGLDAS,latGLDAS,lonGLDAS,tnumGLDAS] = readGLDAS_NOAH( t,18 );

% intep for all smap
dataSMAP_q=zeros(length(latGLDAS),length(lonGLDAS),length(tnumSMAP))*nan;
for i=1:length(tnumSMAP)
    i
    tic
    dataSMAP_q(:,:,i)=interp_grid(lonSMAP,latSMAP,dataSMAP(:,:,i),lonGLDAS,latGLDAS)*100;
    toc
end

iSMAP=4;
[temp,iGLDAS]=min(abs(tnumSMAP(iSMAP)-tnumGLDAS));
datestr(tnumSMAP(iSMAP))
datestr(tnumGLDAS(iGLDAS))
mapSMAP=dataSMAP(:,:,iSMAP);
mapSMAP_q=dataSMAP_q(:,:,iSMAP);
mapGLDAS=dataGLDAS(:,:,iGLDAS);

figure
plot(mapSMAP_q(:),mapGLDAS(:),'b.');hold on
plot121Line
xlabel('interpolated SMAP')
ylabel('GLDAS')


% compare to region
shapefile='Y:\SMAP\testingShape\PA.shp';
%shapefile='Y:\SMAP\testingShape\chuckwalla.shp';
%shapefile='Y:\SMAP\testingShape\sahara.shp';
shape=shaperead(shapefile);
mask = GridinShp(shape,lonGLDAS,latGLDAS,0.25,1 );
mask(mask==0)=nan;
% find swath that covers mask
swath=[];
for i=1:length(tnumSMAP)
    temp=dataSMAP_q(:,:,i).*mask;
    if ~isempty(find(~isnan(temp)))
        swath=[swath,i];
    end
end
swath
iSMAP=swath(1);
[temp,iGLDAS]=min(abs(tnumSMAP(iSMAP)-tnumGLDAS));
datestr(tnumSMAP(iSMAP))
datestr(tnumGLDAS(iGLDAS))
mapSMAP=dataSMAP(:,:,iSMAP);
mapSMAP_q=dataSMAP_q(:,:,iSMAP);
mapGLDAS=dataGLDAS(:,:,iGLDAS);

mapSMAP_q_mask=mapSMAP_q.*mask;
mapGLDAS_mask=mapGLDAS.*mask;
mapGLDAS_mask(isnan(mapSMAP_q_mask))=nan;
showMap(mapSMAP_q_mask,latGLDAS,lonGLDAS,'interpoloated SMAP')
showMap(mapGLDAS_mask,latGLDAS,lonGLDAS,'GLDAS')

figure
plot(mapSMAP_q_mask(:),mapGLDAS_mask(:),'b.');hold on
plot121Line
xlabel('interpolated SMAP')
ylabel('GLDAS')
