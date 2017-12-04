
%% read all smap flag data - L3
%{
global kPath
sd=20150331;
ed=20170614;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tLst=sdn:edn;

saveFolder=[kPath.SMAP,'SMAP_L3_flag',kPath.s];
mkdir(saveFolder)    
flagTab=readtable([kPath.SMAP,'SMAP_L3_flag.csv']);

for k=1:height(flagTab)
    fieldName=flagTab.Flag{k};
    saveName=[saveFolder,flagTab.Filename{k},'.mat'];
    layer=flagTab.Bit(k)+1;
    
    dataSMAP=zeros(406,964,length(tLst))*nan;
    for iT=1:length(tLst)
        t=tLst(iT);
        disp([fieldName,' ',datestr(t)])
        folder=[kPath.SMAP_L3,datestr(t,'yyyy.mm.dd'),kPath.s];
        files = dir([folder,'*.h5']);
		if length(files)~=0
			fileName=[folder,files(1).name];       
			dataTemp=readSMAPflag(fileName,fieldName,'AM');        
			if layer~=0
				dataSMAP(:,:,iT)=dataTemp(:,:,layer);
			else
				dataSMAP(:,:,iT)=dataTemp;
			end
		end
    end
    data=dataSMAP;
    tnum=tLst;
    save(saveName,'data','tnum','lat','lon','-v7.3')
end
%}

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









