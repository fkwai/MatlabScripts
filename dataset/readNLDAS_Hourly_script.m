
% read all NLDAS data
sd=20150101;
ed=20170611;
ed=20150102
% dataLst={'FORA','FORB','NOAH'};
% indLst=[{1:11};{1:10};{[1:19,26,30:52]}];
dataLst={'NOAH'};
indLst=[{19:35}];
indLst=[{19}]
sdn=datenumMulti(sd,1);
edn=datenumMulti(ed,1);
tLst=sdn:edn;

global kPath

for iData=1:length(dataLst)
	dataName=dataLst{iData};
	dataIndLst=indLst{iData};
%try
	for iField=1:length(dataIndLst)
		indField=dataIndLst(iField);
		saveFolder=[kPath.NLDAS_SMAP_Mat,'NLDAS_',dataName,'_Daily',kPath.s];
		%mkdir(saveFolder)

		dataNLDAS=zeros(224,464,24*length(sdn:edn))*nan;
		tnumNLDAS=zeros(24*length(tLst));
		for iT=1:length(tLst)
			t=tLst(iT);
			[dataTemp,lat,lon,tnumTemp,field] = readNLDAS_Hourly(dataName,t,indField);
			field=field{1};
			disp([dataName,' ',field,' ',datestr(t)])
			dataNLDAS(:,:,(iT-1)*24+1:iT*24)=dataTemp;
			tnumNLDAS((iT-1)*24+1:iT*24)=tnumTemp;
		end
		data=dataNLDAS;
		tnum=tnumNLDAS;
		save([saveFolder,field,'.mat'],'data','tnum','lat','lon','-v7.3')
	end
%catch le
%	getReport(le)
%end
end

