% read NLDAS hourly data, convert to daily SMAP grid and save as matfile
% default to convert all fields. see the -1 line 27

global kPath
sd=20150101;
ed=20170611;
dataLst={'FORA','FORB','NOAH'};
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tLst=sdn:edn;
maskSMAP=load([kPath.SMAP,'maskSMAP_CONUS.mat']);
ny=length(maskSMAP.lat);
nx=length(maskSMAP.lon);

for iData=1:length(dataLst)
	dataName=dataLst{iData};
	saveFolder=[kPath.NLDAS,'NLDAS_gridSMAP_CONUS_Daily',kPath.s,'NLDAS_',dataName,'_Daily',kPath.s];
	mkdir(saveFolder)

	for iT=1:length(tLst)
		tic
		t=tLst(iT);
		% read NLDAS
		[dataTemp,lat,lon,tnumTemp,field] = readNLDAS_Hourly(dataName,t,-1);
		disp([dataName,' ',datestr(t)])

		% init dataNLDAS
		if iT==1
			dataNLDAS=zeros(ny,nx,length(sdn:edn),length(field))*nan;
		end

		% average to daily
		dataDaily=nanmean(dataTemp,3);

		% intecept to SMAP grid
		for k=1:length(field)
			dataNLDAS(:,:,iT,k)=interpGridArea(lon,lat,dataDaily(:,:,1,k),maskSMAP.lon,maskSMAP.lat);
		end
		toc

	end

	% write output
	for k=1:length(field)
		data=dataNLDAS(:,:,:,k);
		tnum=tLst;
		fieldName=field{k};
		save([saveFolder,fieldName,'.mat'],'data','tnum','lat','lon','-v7.3')
	end
end