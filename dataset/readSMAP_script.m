
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
gridFile=[kPath.SMAP,filesep,'gridEASE_36'];
gridEASE=load(gridFile);

sd=20150331;
ed=20180410;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tLst=[sdn:edn]';
tErr=[];
dataSMAP=zeros(406,964,length(tLst))*nan;
dataDir=kPath.SMAP_L3;
dataFieldLst={'Soil_Moisture_Retrieval_Data_AM/soil_moisture',...
    'Soil_Moisture_Retrieval_Data_PM/soil_moisture_pm'};
for i=1:length(dataFieldLst)
    dataField=dataFieldLst{i};
    parfor k=1:length(tLst)
        t=tLst(k);
        disp(datestr(t))
        tic
        [data,lat,lon] = readSMAP_L3(t,'field',dataField,'dataDir',dataDir);
        if ~isempty(data)
            dataSMAP(:,:,k)=data;
        else
            tErr=[tErr,t];
        end
        toc
    end    
    lat=gridEASE.lat;
    lon=gridEASE.lon;
    data=dataSMAP;
    tnum=tLst';
    if i==1
        save([kPath.SMAP,'SMAP_L3_AM'],'data','lat','lon','tnum','-v7.3')
    else
        save([kPath.SMAP,'SMAP_L3_PM'],'data','lat','lon','tnum','-v7.3')
    end
end


%% read all smap L4 data and to daily

fieldLst={'Geophysical_Data/sm_profile','Geophysical_Data/sm_surface','Geophysical_Data/sm_rootzone'};
saveLst={'SPL4SMGPv3_profile','SPL4SMGPv3_surface','SPL4SMGPv3_rootzone'};

for kk=2:length(fieldLst)
    version='SPL4SMGP.003';
    fieldName=fieldLst{kk};
    dirSMAP=kPath.SMAP;
    sd=20150331;
    ed=20180410;
    sdn=datenumMulti(sd,1);
    edn=datenumMulti(ed,1);
    tLst=[sdn:edn]';
    tErr=[];
    
    % init
    tt=datenumMulti(20150401,1);
    folder=[kPath.SMAP,version,filesep,datestr(tt,'yyyy.mm.dd'),filesep];
    files = dir([folder,'*.h5']);
    filename=[folder,files(1).name];
    [dataTemp,latTemp,lonTemp] = readSMAP(filename,version,'readCrd',1,'field',fieldName);
    lat=nanmean(latTemp,2);
    lon=nanmean(lonTemp,1);
    
    dataSMAP=zeros(length(lat),length(lon),length(tLst))*nan;
    parfor k=1:length(tLst)
        t=tLst(k);
        disp(datestr(t))
        tic
        data = readSMAP_L4(t,dirSMAP,'field',fieldName);
        dataDaily=nanmean(data,3);
        if ~isempty(data)
            dataSMAP(:,:,k)=dataDaily;
        else
            tErr=[tErr,t];
        end
        toc
    end
    data=dataSMAP;
    tnum=tLst;
    disp(tErr)
    save([kPath.SMAP,saveLst{kk}],'data','lat','lon','tnum','-v7.3')
end


