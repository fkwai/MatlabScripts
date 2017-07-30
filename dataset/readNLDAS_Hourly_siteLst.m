% Read NLDAS data of a list of sites.

global kPath
sd=20150101;
ed=20170611;
dataLst={'FORA','FORB','NOAH'};
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tLst=sdn:edn;

tab = readtable('H:\Kuai\Data\SoilMoisture\SCAN\nwcc_inventory.csv');
latNLDAS=[52.9375:-0.125:25.0625]';
lonNLDAS=[-124.9375:0.125:-67.0625];
% remove AK and HI sites
latLst=tab.lat([18:68,77:end]);
lonLst=tab.lon([18:68,77:end]);
nS=length(latLst);
iyLst=zeros(nS,1);
ixLst=zeros(nS,1);
for k=1:nS
    lat=latLst(k);
    lon=lonLst(k);
    tmp1=abs(lat-latNLDAS);
    tmp2=abs(lon-lonNLDAS);
    [v,iy]=min(tmp1);
    [v,ix]=min(tmp2);
    iyLst(k)=iy;
    ixLst(k)=ix;
end


for iData=1:length(dataLst)
    dataName=dataLst{iData};
    saveFolder=[kPath.NLDAS,'NLDAS_SCAN_Daily',kPath.s,'NLDAS_',dataName,'_Daily',kPath.s];
    switch dataName
        case 'FORA'
            nField=11;
        case 'FORB'
            nField=10;
        case 'NOAH'
            nField=52;
        case 'VIC'
            nField=43;
        case 'MOS'
            nField=37;
    end    
    dataMat=zeros(nS,length(tLst),nField);    
    mkdir(saveFolder)    
    for iT=1:length(tLst)
        tic
        t=tLst(iT);
        % read NLDAS
        [dataTemp,lat,lon,tnumTemp,fieldLst] = readNLDAS_Hourly(dataName,t,-1);
        disp([dataName,' ',datestr(t)])
        
        % average to daily and save to site
        for k=1:nS            
            dataMat(k,iT,:)=nanmean(dataTemp(iyLst(k),ixLst(k),:,:),3);
        end        
        toc        
    end
    for k=1:nField
        data=dataMat(:,:,k);
        tnum=tLst;
        field=fieldLst{k};
        save([saveFolder,field,'.mat'],'data','tnum','lat','lon','-v7.3')
    end
    
end

