t=20150901;
[data,latGLDAS,lonGLDAS,tnum] = readGLDAS_NOAH(t,18);

lon1=-5.5;
lon2=-5.25;
lat1=41.5;
lat2=41.25;
sd=20070101;
ed=20071230;
t=datenumMulti(sd,1):datenumMulti(ed,1);
ix=find(lonGLDAS<=lon2&lonGLDAS>=lon1);
iy=find(latGLDAS>=lat2&latGLDAS<=lat1);
data=zeros(length(iy),length(ix),length(t));
tnum=zeros(length(t)*8,1);

tic
for i=1:length(t);
    [datatemp,lat,lon,tnumtemp] = readGLDAS_NOAH(t(i),18);
    data(:,:,i)=datatemp(iy,ix);
    if rem(i,10)==0
        disp([num2str(i),': ',num2str(toc)])
    end
end

for j=1:length(iy)
    for i=1:length(ix)
        ts.v=reshape(data(j,i,:),[length(t),1]);
        ts.t=t';
        plotTS(ts,'ro');hold on
    end
end
ylim([5,35]);
xlim([t(1),t(end)+1]);
ax=gca;
ax.XTick=[datenumMulti(20100801,1);...
    datenumMulti(20101101,1);...
    datenumMulti(20110201,1);...
    datenumMulti(20110501,1);...
    datenumMulti(20111101,1);...
    datenumMulti(20120201,1);...
    datenumMulti(20120501,1);...
    datenumMulti(20120801,1);...
    datenumMulti(20121101,1);];
datetick('x','mm','keepticks')
