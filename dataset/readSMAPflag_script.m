
%% read all smap flag data
global kPath
sd=20150331;
ed=20170614;
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tLst=sdn:edn;

load([kPath.SMAP,'SMAP_L3.mat'],'lat','lon')
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









