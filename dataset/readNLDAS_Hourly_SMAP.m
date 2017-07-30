
% read NLDAS hourly data, convert to daily SMAP grid and save as matfile
global kPath
sd=20150101;
ed=20170611;
% dataLst={'FORA','FORB','NOAH'};
% indLst=[{1:11};{1:10};{[1:19,26,30:52]}];
dataLst={'MOS','NOAH'};
indLst=[{[21:25,28]};{[23,25:33]}];
fieldNameLst={{'SOILM_MOS_0_10','SOILM_MOS_10_40','SOILM_MOS_40_200','SOILM_MOS_0_100','SOILM_MOS_0_200','SOILM_MOS_0_40'};...
{'SOILM_NOAH_0_200','SOILM_NOAH_0_100','SOILM_NOAH_0_10','SOILM_NOAH_10_40','SOILM_NOAH_40_100','SOILM_NOAH_100_200','LSOIL_NOAH_0_10','LSOIL_NOAH_10_40','LSOIL_NOAH_40_100','LSOIL_NOAH_100_200'};...
};
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
		fieldName=fieldNameLst{iData}{iField};
		save([saveFolder,fieldName,'.mat'],'data','tnum','lat','lon','-v7.3')
	end
end

