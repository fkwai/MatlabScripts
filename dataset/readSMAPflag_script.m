
%% read all smap flag data - L3
global kPath
sd=20150331;
ed=20170614;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tLst=sdn:edn;

saveFolder=[kPath.SMAP,'SMAP_L3_flag',kPath.s];
mkdir(saveFolder)    
flagTab=readtable([kPath.SMAP,'flagTable_SMAP_L3.csv']);

mLst={'AM','PM'};
maskSMAP=cell(length(mLst),1);
for iM=1:length(mLst)
    matSMAP=load([kPath.SMAP,'SMAP_L3_',mLst{iM},'.mat']);
    temp=zeros(size(matSMAP.data))*nan;
    temp(~isnan(matSMAP.data))=1;
    maskSMAP{iM}=temp;
end

for iM=1:length(mLst)
    %for k=1:height(flagTab)
    for k=8:8
        tic
        fieldName=flagTab.Flag{k};
        saveName=[saveFolder,flagTab.Filename{k},'_',mLst{iM},'.mat'];
        layer=flagTab.Bit(k)+1;
        
        dataSMAP=zeros(406,964,length(tLst))*nan;
        parfor iT=1:length(tLst)
            t=tLst(iT);
            disp([fieldName,' ',datestr(t)])
            folder=[kPath.SMAP_L3,datestr(t,'yyyy.mm.dd'),kPath.s];
            files = dir([folder,'*.h5']);
            if ~isempty(files)
                fileName=[folder,files(1).name];
                if strcmp(mLst{iM},'AM')
                    dataTemp=readSMAPflag(fileName,fieldName,'SPL3SMP.004');
                elseif strcmp(mLst{iM},'PM')
                    fieldNamePM=['Soil_Moisture_Retrieval_Data_PM/',fieldName,'_pm'];
                    dataTemp=readSMAPflag(fileName,fieldName,'SPL3SMP.004','DATAFIELD_NAME',fieldNamePM);
                end
                if layer~=0
                    dataSMAP(:,:,iT)=dataTemp(:,:,layer);
                else
                    dataSMAP(:,:,iT)=dataTemp;
                end
            end
        end
        data=dataSMAP.*maskSMAP{iM};        
        tnum=tLst;
        save(saveName,'data','tnum','lat','lon','-v7.3')
        toc
    end
end



%% save constant flags to single matfile
global kPath
saveFolder=[kPath.SMAP,'SMAP_L3_flag',kPath.s];

% pick out constant fields. vegDense is also picked as few of them are
% different.
fieldLst={'flag_albedo';'flag_coast';'flag_ice';...
    'flag_landcover';'flag_mount';'flag_roughness';...
    'flag_staWater';'flag_urban';'flag_waterbody';'flag_vegDense'};

nF=length(fieldLst);
data=zeros(406,964,nF)*nan;
mLst={'AM','PM'};
for iM=1:2
    for k=1:nF
        tic
        mat=load([saveFolder,fieldLst{k},'_',mLst{iM},'.mat']);
        temp=nanstd(mat.data,0,3);
        if ~isempty(find(temp(~isnan(temp))~=0, 1))
            disp(['look at ',fieldLst{k},' ',num2str(k)])
        end
        data(:,:,k)=nanmean(mat.data,3);
        toc
    end
    save([kPath.SMAP,'SMAP_L3_flag_',mLst{iM},'.mat'],'data','fieldLst','lat','lon')
end



%% read all smap flag data - L4
global kPath
saveFolder=[kPath.SMAP,'SMAP_L4_modelConst',kPath.s];
mkdir(saveFolder)    
flagTab=readtable([kPath.SMAP,'SMAP_L4_modelConst.csv']);
fileName=[kPath.SMAP,filesep,'SPL4SMLM.003',filesep,'2015.03.31',...
    filesep,'SMAP_L4_SM_lmc_00000000T000000_Vv3030_001.h5'];
latM=readSMAPflag(fileName,'cell_lat','SPL4SMLM.003','DATAFIELD_NAME','cell_lat');
lonM=readSMAPflag(fileName,'cell_lon','SPL4SMLM.003','DATAFIELD_NAME','cell_lon');
lat=nanmean(latM,2);
lon=nanmean(lonM,1);


for k=1:height(flagTab)
    fieldName=flagTab.DataFieldName{k};
    disp(fieldName)
    saveName=[saveFolder,flagTab.DataFieldName{k},'.mat'];
        
    dataTemp=readSMAPflag(fileName,fieldName,'SPL4SMLM.003');
    vMin=flagTab.ValidMin(k);
    vMax=flagTab.ValidMax(k);
    vFill=flagTab.FillValue(k);
    dataTemp(dataTemp<vMin)=nan;
    dataTemp(dataTemp>vMax)=nan;
    dataTemp(dataTemp==vFill)=nan;
    data=dataTemp;
    save(saveName,'data','lat','lon','-v7.3')
end









