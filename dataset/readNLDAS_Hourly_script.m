
% read all NLDAS data
sd=20150101;
ed=20170612;
dataLst={'FORA','FORB','NOAH'};
indLst=[{1:11};{1:10};{[1:19,25,26,29:52]}];

global kPath

for iData=1:length(dataLst)
	dataName=dataLst{iData};
	dataIndLst=indLst{iData};
	for iField=1:length(dataIndLst)
		indField=dataIndLst(iField);
		saveFolder=[kPath.NLDAS_mat,'NLDAS_',dataName,'_Hourly',kPath.s];
		mkdir(saveFolder)

		sdn=datenumMulti(sd,1);
		edn=datenumMulti(ed,1);
		dataNLDAS=zeros(224,464,24*length(sdn:edn))*nan;
		tnumNLDAS=[];
		lat0=[];
		lon0=[];
		k=1;
		for t=sdn:edn
			tic
			disp(datestr(t))
			[data,lat,lon,tnum,field] = readNLDAS_Hourly(dataName,t,indField);
			dataNLDAS(:,:,k:k+23)=data;
			k=k+8;
			tnumNLDAS=cat(1,tnumNLDAS,tnum);
			toc
		end
		data=dataNLDAS;
		tnum=tnumNLDAS;
		save([saveFolder,field,'.mat'],'data','tnum','lat','lon','-v7.3')
	end
end

