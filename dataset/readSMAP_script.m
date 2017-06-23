
global kPath

%% read all smap L2 data
%{
sd=20150331;
ed=20170614;
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
end
lat=nanmean(lat,2);
lon=nanmean(lon,1);
data=dataSMAP;
tnum=tnumSMAP;
save([kPath.SMAP,'SMAP_L2'],'data','lat','lon','tnum','-v7.3')
%}

%% read all smap L3 data
sd=20150331;
ed=20170614;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
dataSMAP=[];
tnumSMAP=[];
dataSMAP=zeros(406,964,length(tLst))*nan;
for t=sdn:edn
    disp(datestr(t))
    [data,lat,lon] = readSMAP_L3(t);
	if ~isempty(data)
		dataSMAP(:,:,iT)=dataTemp(:,:,layer);
	end
end
lat=nanmean(lat,2);
lon=nanmean(lon,1);
data=dataSMAP;
tnum=[sdn:edn]';
save([kPath.SMAP,'SMAP_L3'],'data','lat','lon','tnum','-v7.3')


