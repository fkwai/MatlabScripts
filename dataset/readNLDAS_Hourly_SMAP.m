
% read NLDAS hourly data, convert to daily SMAP grid and save as matfile
global kPath
sd=20150101;
ed=20170611;
% dataLst={'FORA','FORB','NOAH'};
% indLst=[{1:11};{1:10};{[1:19,26,30:52]}];
dataLst={'NOAH'};
indLst=[{26}];
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tLst=sdn:edn;
maskSMAP=load([kPath.SMAP,'maskSMAP_CONUS.mat']);
ny=length(maskSMAP.lat);
nx=length(maskSMAP.lon);

global kPath

for iData=1:length(dataLst)
	dataName=dataLst{iData};
	dataIndLst=indLst{iData};
	for iField=1:length(dataIndLst)
		indField=dataIndLst(iField);
		saveFolder=[kPath.NLDAS,'NLDAS_gridSMAP_CONUS_Daily',kPath.s,'NLDAS_',dataName,'_Daily',kPath.s];
		mkdir(saveFolder)

		dataNLDAS=zeros(ny,nx,length(sdn:edn))*nan;
		for iT=1:length(tLst)
			tic
			t=tLst(iT);
			% read NLDAS
			[dataTemp,lat,lon,tnumTemp,field] = readNLDAS_Hourly(dataName,t,indField);
			disp([dataName,' ',field,' ',datestr(t)])

			% average to daily
			dataDaily=nanmean(dataTemp,3);

			% intecept to SMAP grid
    		dataNLDAS(:,:,iT)=interpGridArea(lon,lat,dataDaily,maskSMAP.lon,maskSMAP.lat);
			toc

		end
		data=dataNLDAS;
		tnum=tLst;
		save([saveFolder,field,'.mat'],'data','tnum','lat','lon','-v7.3')
	end
end

